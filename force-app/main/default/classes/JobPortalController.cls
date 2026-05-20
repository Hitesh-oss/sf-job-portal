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
      // (since standard users may not have full read permission on internal User metadata fields)
      User u = [
        SELECT ContactId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH SYSTEM_MODE
      ];

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
    } catch (DmlException e) {
      // Capture custom trigger errors (like duplicate application validations) and pass cleanly to LWC
      String errMsg = e.getDmlMessage(0);
      throw new AuraHandledException(errMsg);
    } catch (Exception e) {
      throw new AuraHandledException(
        'An unexpected error occurred: ' + e.getMessage()
      );
    }
  }
}
