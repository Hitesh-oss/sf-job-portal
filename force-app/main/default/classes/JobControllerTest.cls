@isTest
public class JobControllerTest {
  // Mock for successful JSearch Callout
  public class JSearchSuccessMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{' +
          '"status": "OK",' +
          '"data": [{' +
          '"job_id": "jsearch_123",' +
          '"employer_name": "Rapid Corp",' +
          '"job_title": "Salesforce Developer",' +
          '"job_city": "Bengaluru",' +
          '"job_state": "Karnataka",' +
          '"job_country": "IN",' +
          '"job_min_salary": 80000,' +
          '"job_max_salary": 120000,' +
          '"job_salary_currency": "USD",' +
          '"job_apply_link": "https://apply.jsearch.com",' +
          '"job_employment_type": "full-time",' +
          '"job_description": "We are looking for a developer.",' +
          '"job_posted_at_datetime_utc": "2026-06-26T10:00:00.000Z"' +
          '}]' +
          '}'
      );
      res.setStatusCode(200);
      return res;
    }
  }

  // Mock for JSearch Failure (falling back to Adzuna Success)
  public class JSearchFailureAdzunaSuccessMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');

      if (req.getEndpoint().contains('JSearch_API')) {
        res.setStatusCode(500);
        res.setStatus('Internal Server Error');
        res.setBody('{"error": "JSearch Failed"}');
      } else if (req.getEndpoint().contains('Adzuna_API')) {
        res.setStatusCode(200);
        res.setBody(
          '{' +
            '"results": [{' +
            '"id": "adzuna_999",' +
            '"title": "Java Architect",' +
            '"company": { "display_name": "Adzuna Tech" },' +
            '"location": { "display_name": "Pune, India" },' +
            '"salary_min": 1200000,' +
            '"salary_max": 1800000,' +
            '"redirect_url": "https://apply.adzuna.com",' +
            '"contract_time": "full_time",' +
            '"description": "Senior Java Architect role.",' +
            '"created": "2026-06-26T08:00:00Z"' +
            '}]' +
            '}'
        );
      }
      return res;
    }
  }

  // Mock for both API failures
  public class BothAPIsFailureMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setStatusCode(500);
      res.setStatus('Internal Server Error');
      res.setBody('{"error": "Failed"}');
      return res;
    }
  }

  @isTest
  static void testJSearchSuccess() {
    Test.setMock(HttpCalloutMock.class, new JSearchSuccessMock());

    Test.startTest();
    List<JobWrapper> jobs = JobController.getJobs(
      'salesforce',
      'India',
      'Full-time'
    );
    Test.stopTest();

    System.assertNotEquals(null, jobs, 'Jobs list should not be null');
    System.assertEquals(1, jobs.size(), 'Should return exactly 1 job');
    System.assertEquals('jsearch_123', jobs[0].id);
    System.assertEquals('Salesforce Developer', jobs[0].jobTitle);
    System.assertEquals('Rapid Corp', jobs[0].companyName);
    System.assertEquals('Bengaluru, Karnataka, IN', jobs[0].location);
    System.assertEquals('USD 80000 - 120000', jobs[0].salary);
    System.assertEquals('https://apply.jsearch.com', jobs[0].applyLink);
    System.assertEquals('Full-time', jobs[0].jobType);
  }

  @isTest
  static void testJSearchFailureAdzunaSuccess() {
    Test.setMock(HttpCalloutMock.class, new JSearchFailureAdzunaSuccessMock());

    Test.startTest();
    List<JobWrapper> jobs = JobController.getJobs(null, null, null); // Test default values as well
    Test.stopTest();

    System.assertNotEquals(null, jobs, 'Jobs list should not be null');
    System.assertEquals(
      1,
      jobs.size(),
      'Should return exactly 1 job from fallback'
    );
    System.assertEquals('adzuna_999', jobs[0].id);
    System.assertEquals('Java Architect', jobs[0].jobTitle);
    System.assertEquals('Adzuna Tech', jobs[0].companyName);
    System.assertEquals('Pune, India', jobs[0].location);
  }

  @isTest
  static void testBothAPIsFailure() {
    Test.setMock(HttpCalloutMock.class, new BothAPIsFailureMock());

    Test.startTest();
    List<JobWrapper> jobs = JobController.getJobs('developer', 'India', null);
    Test.stopTest();

    System.assertNotEquals(
      null,
      jobs,
      'Jobs list should not be null even on failure'
    );
    System.assertEquals(
      0,
      jobs.size(),
      'Should return empty list on total failure'
    );
  }
}
