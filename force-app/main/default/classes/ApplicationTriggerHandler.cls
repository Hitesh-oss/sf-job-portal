public with sharing class ApplicationTriggerHandler {
  public static void handleBeforeInsert(List<Application__c> newApplications) {
    setAppliedDate(newApplications);
    preventDuplicateApplications(newApplications);
  }

  public static void handleBeforeUpdate(
    List<Application__c> newApplications,
    Map<Id, Application__c> oldApplicationsMap
  ) {
    preventDuplicateApplications(newApplications);
  }

  /**
   * Automatically sets the Applied_Date__c to today's date on insert if not provided.
   */
  private static void setAppliedDate(List<Application__c> newApplications) {
    for (Application__c app : newApplications) {
      if (app.Applied_Date__c == null) {
        app.Applied_Date__c = System.today();
      }
    }
  }

  /**
   * Prevents multiple applications from the same candidate (Contact) for the same Job.
   * Evaluates only when both Job__c and Candidate__c are specified.
   */
  private static void preventDuplicateApplications(
    List<Application__c> newApplications
  ) {
    Set<Id> jobIds = new Set<Id>();
    Set<Id> candidateIds = new Set<Id>();

    for (Application__c app : newApplications) {
      if (app.Job__c != null && app.Candidate__c != null) {
        jobIds.add(app.Job__c);
        candidateIds.add(app.Candidate__c);
      }
    }

    if (jobIds.isEmpty()) {
      return;
    }

    // Query existing applications for the same jobs & candidates securely in user mode
    List<Application__c> existingApps = [
      SELECT Id, Job__c, Candidate__c
      FROM Application__c
      WHERE Job__c IN :jobIds AND Candidate__c IN :candidateIds
      WITH USER_MODE
    ];

    // Create a unique composite key map of existing apps: "JobId_CandidateId" -> Record Id
    Map<String, Id> existingAppKeys = new Map<String, Id>();
    for (Application__c app : existingApps) {
      existingAppKeys.put(app.Job__c + '_' + app.Candidate__c, app.Id);
    }

    for (Application__c app : newApplications) {
      if (app.Job__c != null && app.Candidate__c != null) {
        String key = app.Job__c + '_' + app.Candidate__c;
        if (existingAppKeys.containsKey(key)) {
          // On update, allow the transaction if the matching record is the current record itself
          if (app.Id == null || existingAppKeys.get(key) != app.Id) {
            app.Job__c.addError('You have already applied for this job.');
          }
        }
      }
    }
  }
}
