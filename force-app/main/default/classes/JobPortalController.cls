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
    public static void createApplication(Id jobId, String candidateId, String resumeUrl, String coverLetter) {
        if (jobId == null) {
            throw new AuraHandledException('Job Id missing');
        }

        Application__c app = new Application__c();
        app.Job__c = jobId;

        if (String.isNotBlank(candidateId)) {
            app.Candidate__c = candidateId;
        }

        app.Resume_URL__c = resumeUrl;
        app.Cover_Letter__c = coverLetter;
        app.Application_Status__c = 'Applied';

        insert app;
    }
}
