@isTest
public class JobApiServiceTest {
  // Helper implementation of HttpCalloutMock for dynamic test scenarios
  public class JobServiceMock implements HttpCalloutMock {
    private Integer statusCode;
    private String status;
    private String body;
    private Boolean throwException;

    public JobServiceMock(Integer statusCode, String status, String body) {
      this.statusCode = statusCode;
      this.status = status;
      this.body = body;
      this.throwException = false;
    }

    public JobServiceMock(Boolean throwException) {
      this.throwException = throwException;
    }

    public HTTPResponse respond(HTTPRequest req) {
      if (throwException) {
        throw new CalloutException('Simulated network failure.');
      }
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(body);
      res.setStatusCode(statusCode);
      res.setStatus(status);
      return res;
    }
  }

  @isTest
  static void testFetchAndSaveJobsSuccess() {
    // Construct a sample Remotive JSON payload
    String jsonPayload =
      '{' +
      '"job-count": 1,' +
      '"jobs": [' +
      '{' +
      '"id": 889911,' +
      '"url": "https://remotive.com/jobs/salesforce-engineer-889911",' +
      '"title": "Senior Salesforce Engineer (LWC & Apex) with extremely long title that exceeds eighty characters just to test the standard name clipping logic in Apex service",' +
      '"company_name": "Antigravity Corp",' +
      '"category": "Software Development",' +
      '"job_type": "full_time",' +
      '"publication_date": "2026-05-21T10:00:00",' +
      '"candidate_required_location": "Remote, USA",' +
      '"salary": "$150k - $180k",' +
      '"description": "<p>We are seeking a <strong>Salesforce Developer</strong> to join us.&nbsp;Must know LWC!</p>",' +
      '"tags": ["Apex", "LWC", "Salesforce"]' +
      '}' +
      ']' +
      '}';

    Test.setMock(
      HttpCalloutMock.class,
      new JobServiceMock(200, 'OK', jsonPayload)
    );

    Test.startTest();
    JobApiService.fetchAndSaveJobs();
    Test.stopTest();

    // Verify record was created
    List<Job__c> jobs = [
      SELECT
        Name,
        Job_Title__c,
        Company__c,
        Location__c,
        Job_Type__c,
        Salary_Range__c,
        Required_Skills__c,
        Description__c,
        Posted_Date__c,
        Apply_URL__c,
        External_Job_Id__c,
        Source__c,
        Status__c
      FROM Job__c
      WHERE External_Job_Id__c = '889911'
    ];

    System.assertEquals(1, jobs.size(), 'One job record should be created.');
    Job__c job = jobs[0];

    // Assert standard Name field is safely truncated under 80 characters
    System.assert(
      job.Name.length() <= 80,
      'Standard Name must be under 80 chars.'
    );
    System.assert(
      job.Name.endsWith('...'),
      'Name should be truncated with ellipses.'
    );

    // Assert all fields mapped perfectly
    System.assertEquals(
      'Senior Salesforce Engineer (LWC & Apex) with extremely long title that exceeds eighty characters just to test the standard name clipping logic in Apex service',
      job.Job_Title__c
    );
    System.assertEquals('Antigravity Corp', job.Company__c);
    System.assertEquals('Remote, USA', job.Location__c);
    System.assertEquals('Full-time', job.Job_Type__c);
    System.assertEquals('$150k - $180k', job.Salary_Range__c);
    System.assertEquals('Apex, LWC, Salesforce', job.Required_Skills__c);

    // Assert HTML tag stripping and decoding are clean and formatted as LWC plain text
    System.assertEquals(
      'We are seeking a Salesforce Developer to join us. Must know LWC!',
      job.Description__c
    );

    // Assert publication date parsing matches standard Date value
    System.assertEquals(Date.newInstance(2026, 5, 21), job.Posted_Date__c);
    System.assertEquals(
      'https://remotive.com/jobs/salesforce-engineer-889911',
      job.Apply_URL__c
    );
    System.assertEquals('Remotive', job.Source__c);
    System.assertEquals('Active,', job.Status__c);
  }

  @isTest
  static void testFetchAndSaveJobsUpsertAvoidsDuplicates() {
    String jsonPayload =
      '{' +
      '"jobs": [' +
      '{' +
      '"id": 554433,' +
      '"url": "https://remotive.com/jobs/554433",' +
      '"title": "Salesforce Developer",' +
      '"company_name": "Alpha Co",' +
      '"job_type": "contract",' +
      '"publication_date": "2026-05-21",' +
      '"description": "Original Description"' +
      '}' +
      ']' +
      '}';

    // 1st Mock: Initial Sync
    Test.setMock(
      HttpCalloutMock.class,
      new JobServiceMock(200, 'OK', jsonPayload)
    );

    Test.startTest();
    JobApiService.fetchAndSaveJobs();

    // Verify initial record insertion
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Job__c WHERE External_Job_Id__c = '554433']
    );
    Job__c origJob = [
      SELECT Job_Type__c, Description__c
      FROM Job__c
      WHERE External_Job_Id__c = '554433'
      LIMIT 1
    ];
    System.assertEquals('Contract,', origJob.Job_Type__c); // Mapped Contract
    System.assertEquals('Original Description', origJob.Description__c);

    // 2nd Mock: Sync again with updated details for the same Job ID
    String updatedPayload =
      '{' +
      '"jobs": [' +
      '{' +
      '"id": 554433,' +
      '"url": "https://remotive.com/jobs/554433",' +
      '"title": "Salesforce Developer",' +
      '"company_name": "Alpha Co",' +
      '"job_type": "contract",' +
      '"publication_date": "2026-05-21",' +
      '"description": "Updated Description Content"' +
      '}' +
      ']' +
      '}';

    Test.setMock(
      HttpCalloutMock.class,
      new JobServiceMock(200, 'OK', updatedPayload)
    );
    JobApiService.fetchAndSaveJobs();
    Test.stopTest();

    // Verify count is still exactly 1 (upsert matched external ID instead of duplicating)
    List<Job__c> jobs = [
      SELECT Job_Type__c, Description__c
      FROM Job__c
      WHERE External_Job_Id__c = '554433'
    ];
    System.assertEquals(
      1,
      jobs.size(),
      'Upsert should update the record, not create duplicates.'
    );
    System.assertEquals(
      'Updated Description Content',
      jobs[0].Description__c,
      'Details should be updated successfully.'
    );
  }

  @isTest
  static void testFetchAndSaveJobsNetworkFailure() {
    // Set mock to throw an HTTP Exception
    Test.setMock(HttpCalloutMock.class, new JobServiceMock(true));

    Test.startTest();
    try {
      JobApiService.fetchAndSaveJobs();
      System.assert(
        false,
        'Should throw a CalloutException on network failure.'
      );
    } catch (CalloutException e) {
      System.assert(
        e.getMessage().contains('Failed to connect'),
        'Correct exception thrown.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testFetchAndSaveJobsNon200Response() {
    // Set mock to return a 500 Server Error
    Test.setMock(
      HttpCalloutMock.class,
      new JobServiceMock(500, 'Server Error', 'Internal Error')
    );

    Test.startTest();
    try {
      JobApiService.fetchAndSaveJobs();
      System.assert(
        false,
        'Should throw CalloutException on non-200 responses.'
      );
    } catch (CalloutException e) {
      System.assert(
        e.getMessage().contains('status code 500'),
        'Correct status exception thrown.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testFetchAndSaveJobsEmptyResponseBody() {
    Test.setMock(HttpCalloutMock.class, new JobServiceMock(200, 'OK', ''));

    Test.startTest();
    try {
      JobApiService.fetchAndSaveJobs();
      System.assert(false, 'Should throw exception on empty response body.');
    } catch (CalloutException e) {
      System.assert(
        e.getMessage().contains('empty response'),
        'Correct exception thrown.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testFetchAndSaveJobsInvalidJSON() {
    Test.setMock(
      HttpCalloutMock.class,
      new JobServiceMock(200, 'OK', '{invalid-json}')
    );

    Test.startTest();
    try {
      JobApiService.fetchAndSaveJobs();
      System.assert(false, 'Should throw exception on bad JSON syntax.');
    } catch (JSONException e) {
      System.assert(
        e.getMessage().contains('Failed to parse'),
        'Correct JSONException thrown.'
      );
    }
    Test.stopTest();
  }
}
