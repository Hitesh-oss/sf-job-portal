@isTest
public class JobPortalControllerTest {
  @TestSetup
  static void setupTestData() {
    Job__c job = new Job__c(
      Name = 'Salesforce Architect',
      Job_Title__c = 'Salesforce Architect',
      Company__c = 'Google',
      Location__c = 'Remote',
      Job_Type__c = 'Full-time',
      Salary_Range__c = '$180k - $220k',
      Required_Skills__c = 'Apex, LWC, Cloud Computing',
      Posted_Date__c = System.today(),
      Status__c = 'Active,',
      External_Job_Id__c = 'test_ext_001',
      Source__c = 'External API'
    );
    insert job;

    Contact candidate = new Contact(
      FirstName = 'Hitesh',
      LastName = 'Candidate',
      Email = 'hitesh@candidate.com'
    );
    insert candidate;
  }

  // ── getAllJobs ─────────────────────────────────────────────
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
      'Job title matches'
    );
  }

  // ── createApplication with JSON (real-time flow) ─────────
  @isTest
  static void testCreateApplicationWithJson() {
    // Build job JSON for a NEW external job (not yet in org)
    String jobJson =
      '{"id":"ext_new_999","jobTitle":"Backend Developer",' +
      '"companyName":"TechCorp","location":"Bengaluru",' +
      '"jobType":"Full-time","salary":"$120k",' +
      '"description":"Build scalable APIs.",' +
      '"applyLink":"https://apply.example.com"}';

    Test.startTest();
    JobPortalController.createApplication(
      jobJson,
      'https://myresume.com/resume.pdf',
      'This is a detailed cover letter that is more than fifty characters long.'
    );
    Test.stopTest();

    List<Application__c> apps = [SELECT Id, Resume_URL__c FROM Application__c];
    System.assertEquals(1, apps.size(), 'Application created');
    System.assertEquals(
      'https://myresume.com/resume.pdf',
      apps[0].Resume_URL__c,
      'Resume URL correct'
    );

    // Shadow job should have been created
    List<Job__c> shadowJobs = [
      SELECT Id
      FROM Job__c
      WHERE External_Job_Id__c = 'ext_new_999'
    ];
    System.assertEquals(1, shadowJobs.size(), 'Shadow job record created');
  }

  // ── createApplication against existing Job__c ─────────────
  @isTest
  static void testCreateApplicationExistingJob() {
    String jobJson =
      '{"id":"test_ext_001","jobTitle":"Salesforce Architect",' +
      '"companyName":"Google","location":"Remote",' +
      '"jobType":"Full-time","salary":"$180k",' +
      '"description":"Role details.",' +
      '"applyLink":"https://apply.google.com"}';

    Test.startTest();
    JobPortalController.createApplication(
      jobJson,
      'https://resume.link/file.pdf',
      'My cover letter is detailed and longer than fifty characters for validation.'
    );
    Test.stopTest();

    List<Application__c> apps = [SELECT Id FROM Application__c];
    System.assertEquals(1, apps.size(), 'Application created for existing job');
    // Job record count should still be 1 (no duplicate)
    List<Job__c> jobs = [
      SELECT Id
      FROM Job__c
      WHERE External_Job_Id__c = 'test_ext_001'
    ];
    System.assertEquals(1, jobs.size(), 'No duplicate Job__c created');
  }

  // ── createApplication null guard ──────────────────────────
  @isTest
  static void testCreateApplicationMissingJson() {
    Test.startTest();
    try {
      JobPortalController.createApplication(
        null,
        'https://resume.com',
        'Letter'
      );
      System.assert(false, 'Exception should have been thrown');
    } catch (AuraHandledException e) {
      System.assertEquals(
        'Script-thrown exception',
        e.getMessage(),
        'AuraHandledException caught correctly'
      );
    }
    Test.stopTest();
  }

  // ── Duplicate application guard ───────────────────────────
  @isTest
  static void testTriggerDuplicateCheck() {
    Job__c job = [SELECT Id FROM Job__c LIMIT 1];
    Contact candidate = [SELECT Id FROM Contact LIMIT 1];

    Application__c app1 = new Application__c(
      Job__c = job.Id,
      Candidate__c = candidate.Id,
      Resume_URL__c = 'https://res.pdf',
      Cover_Letter__c = 'Cover letter content here that is long enough'
    );
    insert app1;

    Application__c app2 = new Application__c(
      Job__c = job.Id,
      Candidate__c = candidate.Id,
      Resume_URL__c = 'https://res.pdf',
      Cover_Letter__c = 'Cover letter content here that is long enough'
    );

    Test.startTest();
    try {
      insert app2;
      System.assert(false, 'DmlException expected');
    } catch (DmlException e) {
      System.assert(
        e.getDmlMessage(0).contains('already applied'),
        'Trigger fires correctly'
      );
    }
    Test.stopTest();
  }

  // ── syncJobs (uses JobApiServiceTest mock) ────────────────
  @isTest
  static void testSyncJobsSuccess() {
    String jsonPayload =
      '{"jobs":[{"id":112233,"url":"https://remotive.com/jobs/112233",' +
      '"title":"Salesforce Specialist","company_name":"Antigravity Corp",' +
      '"job_type":"full_time","publication_date":"2026-05-21","description":"Role Details"}]}';

    Test.setMock(
      HttpCalloutMock.class,
      new JobApiServiceTest.JobServiceMock(200, 'OK', jsonPayload)
    );

    Test.startTest();
    JobPortalController.syncJobs();
    Test.stopTest();

    List<Job__c> synced = [
      SELECT Id
      FROM Job__c
      WHERE External_Job_Id__c = '112233'
    ];
    System.assertEquals(1, synced.size(), 'Sync created 1 job');
  }

  @isTest
  static void testSyncJobsError() {
    Test.setMock(
      HttpCalloutMock.class,
      new JobApiServiceTest.JobServiceMock(true)
    );

    Test.startTest();
    try {
      JobPortalController.syncJobs();
      System.assert(false, 'Expected AuraHandledException');
    } catch (AuraHandledException e) {
      System.assert(e.getMessage() != null, 'Exception thrown');
    }
    Test.stopTest();
  }
}
