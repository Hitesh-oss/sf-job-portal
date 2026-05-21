public with sharing class JobApiService {
  /**
   * Callout to Remotive remote jobs API and upsert into Job__c.
   */
  public static void fetchAndSaveJobs() {
    Http http = new Http();
    HttpRequest request = new HttpRequest();

    // Use Named Credential callout to follow security best practices
    request.setEndpoint('callout:Remotive_Jobs_API/remote-jobs?limit=20');
    request.setMethod('GET');
    request.setHeader('Accept', 'application/json');

    HttpResponse response;
    try {
      response = http.send(request);
    } catch (Exception e) {
      throw new CalloutException(
        'Failed to connect to the external jobs API: ' + e.getMessage()
      );
    }

    if (response.getStatusCode() != 200) {
      throw new CalloutException(
        'External jobs API returned status code ' +
          response.getStatusCode() +
          ': ' +
          response.getStatus()
      );
    }

    String responseBody = response.getBody();
    if (String.isBlank(responseBody)) {
      throw new CalloutException(
        'Received an empty response from the external jobs API.'
      );
    }

    // Parse the JSON safely
    RemotiveResponse parsedResponse;
    try {
      parsedResponse = (RemotiveResponse) JSON.deserialize(
        responseBody,
        RemotiveResponse.class
      );
    } catch (Exception e) {
      throw new JSONException(
        'Failed to parse the job listings JSON response: ' + e.getMessage()
      );
    }

    if (
      parsedResponse == null ||
      parsedResponse.jobs == null ||
      parsedResponse.jobs.isEmpty()
    ) {
      return; // No jobs to process
    }

    List<Job__c> jobsToUpsert = new List<Job__c>();

    for (RemotiveJob apiJob : parsedResponse.jobs) {
      if (apiJob.id == null || String.isBlank(apiJob.title)) {
        continue; // Skip invalid records
      }

      Job__c job = new Job__c();

      // Standard Name field is Text(80). Clip the title safely to prevent truncation issues.
      String jobTitle = apiJob.title;
      job.Job_Title__c = jobTitle;
      if (jobTitle.length() > 80) {
        job.Name = jobTitle.substring(0, 77) + '...';
      } else {
        job.Name = jobTitle;
      }

      job.Company__c = apiJob.company_name;
      job.Location__c = String.isNotBlank(apiJob.candidate_required_location)
        ? apiJob.candidate_required_location
        : 'Remote';

      // Safe picklist value mapping
      job.Job_Type__c = mapJobType(apiJob.job_type);

      job.Salary_Range__c = apiJob.salary;

      // Parse comma-separated skills
      if (apiJob.tags != null && !apiJob.tags.isEmpty()) {
        job.Required_Skills__c = String.join(apiJob.tags, ', ');
      }

      // Strip HTML tags for LWC plain-text compatibility
      job.Description__c = stripHtmlTags(apiJob.description);

      // Parse posted date securely (required field)
      job.Posted_Date__c = parseDate(apiJob.publication_date);

      job.Apply_URL__c = apiJob.url;
      job.External_Job_Id__c = String.valueOf(apiJob.id);
      job.Source__c = 'Remotive';

      // Set standard active status
      job.Status__c = 'Active,';

      jobsToUpsert.add(job);
    }

    if (!jobsToUpsert.isEmpty()) {
      // Perform bulk upsert securely enforcing user CRUD/FLS permissions
      try {
        upsert as user jobsToUpsert External_Job_Id__c;
      } catch (DmlException e) {
        throw new DmlException(
          'Failed to save synced job listings: ' + e.getDmlMessage(0)
        );
      } catch (Exception e) {
        throw new AuraHandledException(
          'Error during job synchronization: ' + e.getMessage()
        );
      }
    }
  }

  /**
   * Map Remotive's job type to custom object's Picklist values safely.
   */
  public static String mapJobType(String apiJobType) {
    if (String.isBlank(apiJobType)) {
      return 'Full-time';
    }

    String normalized = apiJobType.toLowerCase().replaceAll('[_-]', ' ');
    if (normalized.contains('full time')) {
      return 'Full-time';
    } else if (normalized.contains('part time')) {
      return 'Part-time';
    } else if (normalized.contains('contract')) {
      return 'Contract,'; // Matches 'Contract,' with trailing comma in metadata definition
    } else if (normalized.contains('internship')) {
      return 'Internship';
    }

    return 'Full-time'; // Safe default picklist fallback
  }

  /**
   * Strips HTML tags and decodes common entities to prepare clean plaintext for LWC.
   */
  public static String stripHtmlTags(String htmlText) {
    if (String.isBlank(htmlText)) {
      return '';
    }

    // Simple regex to clear HTML tags
    String plainText = htmlText.replaceAll('<[^>]*>', '');

    // Decode common HTML entities
    plainText = plainText.replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', '\'');

    // Trim double spaces/newlines to keep LWC presentation tight
    plainText = plainText.replaceAll('\\s+', ' ');

    // Substring to stay within 32,768 LongTextArea boundary just in case
    if (plainText.length() > 32000) {
      plainText = plainText.substring(0, 31997) + '...';
    }

    return plainText.trim();
  }

  /**
   * Parses ISO 8601 publication timestamps into standard Dates safely.
   */
  public static Date parseDate(String dateStr) {
    if (String.isBlank(dateStr)) {
      return System.today();
    }

    try {
      // e.g., '2026-05-21T00:00:00' -> '2026-05-21'
      if (dateStr.length() >= 10) {
        String isoDate = dateStr.substring(0, 10);
        return Date.valueOf(isoDate);
      }
    } catch (Exception e) {
      System.debug('Error parsing publication date: ' + e.getMessage());
    }

    return System.today(); // Safe fallback for required Posted_Date__c
  }

  // JSON response mapping classes
  public class RemotiveResponse {
    public List<RemotiveJob> jobs { get; set; }
  }

  public class RemotiveJob {
    public Long id { get; set; }
    public String url { get; set; }
    public String title { get; set; }
    public String company_name { get; set; }
    public String category { get; set; }
    public String job_type { get; set; }
    public String publication_date { get; set; }
    public String candidate_required_location { get; set; }
    public String salary { get; set; }
    public String description { get; set; }
    public List<String> tags { get; set; }
  }
}
