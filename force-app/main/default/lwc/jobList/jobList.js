import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllJobs from '@salesforce/apex/JobPortalController.getAllJobs';
import createApplication from '@salesforce/apex/JobPortalController.createApplication';

export default class JobList extends LightningElement {
    jobs;
    error;

    showForm = false;
    selectedJobId;
    candidateId = '';
    resumeUrl = '';
    coverLetter = '';

    @wire(getAllJobs)
    wiredJobs({ error, data }) {
        if (data) {
            this.jobs = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.jobs = undefined;
        }
    }

    handleApply(event) {
        this.selectedJobId = event.target.dataset.id;
        this.showForm = true;
    }

    handleCandidateChange(event) {
        this.candidateId = event.target.value;
    }

    handleResumeChange(event) {
        this.resumeUrl = event.target.value;
    }

    handleCoverChange(event) {
        this.coverLetter = event.target.value;
    }

    submitApplication() {
        createApplication({
            jobId: this.selectedJobId,
            candidateId: this.candidateId,
            resumeUrl: this.resumeUrl,
            coverLetter: this.coverLetter
        })
            .then(() => {
                this.showForm = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Application Submitted Successfully!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error('Full Error:', JSON.stringify(error));

                let message = 'Application submit nahi hua';

                if (error && error.body && error.body.message) {
                    message = error.body.message;
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: message,
                        variant: 'error'
                    })
                );
            });
    }
}