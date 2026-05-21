public with sharing class JobPortalController {
  @AuraEnabled(cacheable=true)
  public static List<Job__c> getAllJobs() {
    // Enforce FLS and CRUD security checks using WITH USER_MODE
    return [
      SELECT
        Id,
        Name,
        Job_Title__c,
        Company__c,
        Location__c,
        Job_Type__c,
        Salary_Range__c,
        Description__c,
        Required_Skills__c,
        CreatedDate
      FROM Job__c
      WITH USER_MODE
      ORDER BY CreatedDate DESC
    ];
  }

  @AuraEnabled
  public static void createApplication(
    Id jobId,
    String resumeUrl,
    String coverLetter
  ) {
    if (jobId == null) {
      throw new AuraHandledException('Job Id is missing.');
    }

    try {
      // Query logged-in user ContactId securely in system mode
      User u = [
        SELECT ContactId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH SYSTEM_MODE
      ];

      // Duplicate Check: Check if user has already applied for this job
      List<Application__c> duplicates;
      if (u.ContactId != null) {
        duplicates = [
          SELECT Id
          FROM Application__c
          WHERE Job__c = :jobId AND Candidate__c = :u.ContactId
          WITH USER_MODE
          LIMIT 1
        ];
      } else {
        duplicates = [
          SELECT Id
          FROM Application__c
          WHERE Job__c = :jobId AND CreatedById = :UserInfo.getUserId()
          WITH USER_MODE
          LIMIT 1
        ];
      }

      if (duplicates != null && !duplicates.isEmpty()) {
        throw new AuraHandledException(
          'You have already applied for this job.'
        );
      }

      Application__c app = new Application__c();
      app.Job__c = jobId;

      if (u.ContactId != null) {
        app.Candidate__c = u.ContactId;
      }

      app.Resume_URL__c = resumeUrl;
      app.Cover_Letter__c = coverLetter;
      app.Application_Status__c = 'Applied';

      // Insert securely enforcing standard user object and field-level permissions (CRUD/FLS)
      insert as user app;
    } catch (AuraHandledException e) {
      throw e;
    } catch (DmlException e) {
      // Capture custom trigger errors and pass cleanly to LWC
      String errMsg = e.getDmlMessage(0);
      throw new AuraHandledException(errMsg);
    } catch (Exception e) {
      throw new AuraHandledException(
        'An unexpected error occurred: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled
  public static List<Application__c> getMyApplications() {
    try {
      // Query logged-in user ContactId securely in system mode
      User u = [
        SELECT ContactId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH SYSTEM_MODE
      ];

      if (u.ContactId != null) {
        return [
          SELECT
            Id,
            Name,
            Job__r.Job_Title__c,
            Job__r.Company__c,
            Application_Status__c,
            Applied_Date__c
          FROM Application__c
          WHERE Candidate__c = :u.ContactId
          WITH USER_MODE
          ORDER BY Applied_Date__c DESC, CreatedDate DESC
        ];
      } else {
        return [
          SELECT
            Id,
            Name,
            Job__r.Job_Title__c,
            Job__r.Company__c,
            Application_Status__c,
            Applied_Date__c
          FROM Application__c
          WHERE CreatedById = :UserInfo.getUserId()
          WITH USER_MODE
          ORDER BY Applied_Date__c DESC, CreatedDate DESC
        ];
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void syncJobs() {
    try {
      JobApiService.fetchAndSaveJobs();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
