public with sharing class JobController {
  @AuraEnabled(cacheable=true)
  public static List<JobWrapper> getJobs(
    String query,
    String location,
    String type
  ) {
    // Set defaults if inputs are null or blank
    String finalQuery = String.isNotBlank(query) ? query : 'software developer';
    String finalLocation = String.isNotBlank(location) ? location : 'India';
    String finalType = type; // Can be null

    try {
      return JobService.fetchJobs(finalQuery, finalLocation, finalType);
    } catch (Exception e) {
      throw new AuraHandledException('Error fetching jobs: ' + e.getMessage());
    }
  }
}
