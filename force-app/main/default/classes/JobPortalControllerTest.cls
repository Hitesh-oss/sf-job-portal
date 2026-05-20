@isTest
public class JobPortalControllerTest {
  @TestSetup
  static void setupTestData() {
    // Create standard Job record
    Job__c job = new Job__c(
      Job_Title__c = 'Salesforce Architect',
      Company__c = 'Google',
      Location__c = 'Remote',
      Job_Type__c = 'Full-Time',
      Salary_Range__c = '$180k - $220k',
      Required_Skills__c = 'Apex, LWC, Cloud Computing',
      Posted_Date__c = System.today()
    );
    insert job;

    // Create standard Contact record
    Contact candidate = new Contact(
      FirstName = 'Hitesh',
      LastName = 'Candidate',
      Email = 'hitesh@candidate.com'
    );
    insert candidate;
  }

  @isTest
  static void testGetAllJobs() {
    Test.startTest();
    List<Job__c> jobs = JobPortalController.getAllJobs();
    Test.stopTest();

    System.assertNotEquals(
      0,
      jobs.size(),
      'Should return the created job record'
    );
    System.assertEquals(
      'Salesforce Architect',
      jobs[0].Job_Title__c,
      'Correct job details returned'
    );
  }

  @isTest
  static void testCreateApplication() {
    Job__c job = [SELECT Id FROM Job__c LIMIT 1];

    Test.startTest();
    // Since we are running in standard context where User.ContactId is null,
    // it should successfully insert the application with null Candidate securely
    JobPortalController.createApplication(
      job.Id,
      'https://myresume.com/resume.pdf',
      'This is my cover letter.'
    );
    Test.stopTest();

    List<Application__c> apps = [
      SELECT
        Id,
        Resume_URL__c,
        Cover_Letter__c,
        Application_Status__c,
        Applied_Date__c
      FROM Application__c
    ];
    System.assertEquals(
      1,
      apps.size(),
      'One application record should be successfully created'
    );
    System.assertEquals(
      'https://myresume.com/resume.pdf',
      apps[0].Resume_URL__c,
      'Resume URL saved correctly'
    );
    System.assertEquals(
      'This is my cover letter.',
      apps[0].Cover_Letter__c,
      'Cover letter saved correctly'
    );
    System.assertEquals(
      'Applied',
      apps[0].Application_Status__c,
      'Default status set to Applied'
    );
    System.assertEquals(
      System.today(),
      apps[0].Applied_Date__c,
      'Applied Date auto-populated by Trigger on insert'
    );
  }

  @isTest
  static void testCreateApplicationMissingJobId() {
    Test.startTest();
    try {
      JobPortalController.createApplication(
        null,
        'https://resume.com',
        'Letter'
      );
      System.assert(
        false,
        'Exception should have been thrown for missing Job Id'
      );
    } catch (AuraHandledException e) {
      // In Apex unit tests, AuraHandledException messages are stripped and default to 'Script-thrown exception'
      System.assertEquals(
        'Script-thrown exception',
        e.getMessage(),
        'AuraHandledException successfully caught'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testTriggerDuplicateCheck() {
    Job__c job = [SELECT Id FROM Job__c LIMIT 1];
    Contact candidate = [SELECT Id FROM Contact LIMIT 1];

    // Insert first application directly
    Application__c app1 = new Application__c(
      Job__c = job.Id,
      Candidate__c = candidate.Id,
      Resume_URL__c = 'https://res.pdf',
      Cover_Letter__c = 'Cover letter content here'
    );
    insert app1;

    // Insert duplicate application should fail
    Application__c app2 = new Application__c(
      Job__c = job.Id,
      Candidate__c = candidate.Id,
      Resume_URL__c = 'https://res.pdf',
      Cover_Letter__c = 'Cover letter content here'
    );

    Test.startTest();
    try {
      insert app2;
      System.assert(
        false,
        'DmlException expected due to duplicate check trigger'
      );
    } catch (DmlException e) {
      System.assert(
        e.getDmlMessage(0).contains('already applied'),
        'Trigger should throw already applied message'
      );
    }
    Test.stopTest();
  }
}
