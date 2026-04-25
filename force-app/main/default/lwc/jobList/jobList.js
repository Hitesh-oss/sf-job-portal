import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllJobs from '@salesforce/apex/JobPortalController.getAllJobs';
import createApplication from '@salesforce/apex/JobPortalController.createApplication';

export default class JobList extends LightningElement {
    jobs;
    error;

    showForm = false;
    selectedJobId;
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

    handleResumeChange(event) {
        this.resumeUrl = event.target.value;
    }

    handleCoverChange(event) {
        this.coverLetter = event.target.value;
    }

    submitApplication() {
        createApplication({
            jobId: this.selectedJobId,
            resumeUrl: this.resumeUrl,
            coverLetter: this.coverLetter
        })
            .then(() => {
                this.showForm = false;
                this.resumeUrl = '';
                this.coverLetter = '';

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Application Submitted Successfully!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error(error);

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