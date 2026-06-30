public with sharing class JobPortalController {
  // ── Get all cached Salesforce Job__c records ─────────────
  @AuraEnabled(cacheable=true)
  public static List<Job__c> getAllJobs() {
    return [
      SELECT
        Id,
        Name,
        Job_Title__c,
        Company__c,
        Location__c,
        Job_Type__c,
        Salary_Range__c,
        Experience_Level__c,
        Description__c,
        Required_Skills__c,
        Posted_Date__c,
        Status__c,
        Apply_URL__c,
        External_Job_Id__c,
        Source__c,
        CreatedDate
      FROM Job__c
      WHERE Status__c = 'Active,'
      WITH SYSTEM_MODE
      ORDER BY Posted_Date__c DESC NULLS LAST
    ];
  }

  // ── Create Application (accepts real-time job JSON) ───────
  @AuraEnabled
  public static void createApplication(
    String jobJson,
    String resumeUrl,
    String coverLetter
  ) {
    if (String.isBlank(jobJson)) {
      throw new AuraHandledException('Job details are missing.');
    }

    try {
      Map<String, Object> jobMap = (Map<String, Object>) JSON.deserializeUntyped(
        jobJson
      );
      String externalId = (String) jobMap.get('id');
      String jobTitle = (String) jobMap.get('jobTitle');
      String company = (String) jobMap.get('companyName');
      String location = (String) jobMap.get('location');
      String jobType = (String) jobMap.get('jobType');
      String salary = (String) jobMap.get('salary');
      String description = (String) jobMap.get('description');
      String applyUrl = (String) jobMap.get('applyLink');

      // Upsert shadow Job__c record
      List<Job__c> existing = [
        SELECT Id
        FROM Job__c
        WHERE External_Job_Id__c = :externalId
        WITH SYSTEM_MODE
        LIMIT 1
      ];

      Id sfdcJobId;
      if (!existing.isEmpty()) {
        sfdcJobId = existing[0].Id;
      } else {
        Job__c newJob = new Job__c();
        newJob.External_Job_Id__c = externalId;
        newJob.Job_Title__c = jobTitle;
        newJob.Name = String.isNotBlank(jobTitle)
          ? (jobTitle.length() > 80
              ? jobTitle.substring(0, 77) + '...'
              : jobTitle)
          : 'Job Position';
        newJob.Company__c = company;
        newJob.Location__c = String.isNotBlank(location) ? location : 'Remote';

        String normalized = String.isNotBlank(jobType)
          ? jobType.toLowerCase()
          : '';
        if (normalized.contains('contract'))
          newJob.Job_Type__c = 'Contract,';
        else if (normalized.contains('part'))
          newJob.Job_Type__c = 'Part-time';
        else if (normalized.contains('intern'))
          newJob.Job_Type__c = 'Internship';
        else
          newJob.Job_Type__c = 'Full-time';

        newJob.Salary_Range__c = salary;
        newJob.Description__c = description;
        newJob.Apply_URL__c = applyUrl;
        newJob.Posted_Date__c = System.today();
        newJob.Status__c = 'Active,';
        newJob.Source__c = 'External API';

        insert as system newJob;
        sfdcJobId = newJob.Id;
      }

      // Logged-in user
      User u = [
        SELECT ContactId
        FROM User
        WHERE Id = :UserInfo.getUserId()
        WITH SYSTEM_MODE
      ];

      // Duplicate check
      List<Application__c> dupes;
      if (u.ContactId != null) {
        dupes = [
          SELECT Id
          FROM Application__c
          WHERE Job__c = :sfdcJobId AND Candidate__c = :u.ContactId
          WITH SYSTEM_MODE
          LIMIT 1
        ];
      } else {
        dupes = [
          SELECT Id
          FROM Application__c
          WHERE Job__c = :sfdcJobId AND CreatedById = :UserInfo.getUserId()
          WITH SYSTEM_MODE
          LIMIT 1
        ];
      }

      if (dupes != null && !dupes.isEmpty()) {
        throw new AuraHandledException(
          'You have already applied for this job.'
        );
      }

      Application__c app = new Application__c();
      app.Job__c = sfdcJobId;
      if (u.ContactId != null)
        app.Candidate__c = u.ContactId;
      app.Resume_URL__c = resumeUrl;
      app.Cover_Letter__c = coverLetter;
      app.Application_Status__c = 'Applied';
      insert as system app;
    } catch (AuraHandledException e) {
      throw e;
    } catch (DmlException e) {
      throw new AuraHandledException(e.getDmlMessage(0));
    } catch (Exception e) {
      throw new AuraHandledException(
        'An unexpected error occurred: ' + e.getMessage()
      );
    }
  }

  // ── Get My Applications ───────────────────────────────────
  @AuraEnabled
  public static List<Application__c> getMyApplications() {
    try {
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
          WITH SYSTEM_MODE
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
          WITH SYSTEM_MODE
          ORDER BY Applied_Date__c DESC, CreatedDate DESC
        ];
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // ── Sync Jobs from Remotive (legacy) ─────────────────────
  @AuraEnabled
  public static void syncJobs() {
    try {
      JobApiService.fetchAndSaveJobs();
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
