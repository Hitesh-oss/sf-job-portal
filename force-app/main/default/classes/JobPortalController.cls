public with sharing class JobPortalController {

    @AuraEnabled(cacheable=true)
    public static List<Job__c> getAllJobs() {
        return [
            SELECT Id, Name, Job_Title__c, Company__c, Location__c, Job_Type__c, Salary_Range__c
            FROM Job__c
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static void createApplication(Id jobId) {
        Application__c app = new Application__c();
        app.Job__c = jobId;
        app.Application_Status__c = 'Applied';
        insert app;
    }
}