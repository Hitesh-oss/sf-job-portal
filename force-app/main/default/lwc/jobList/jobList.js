import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllJobs from '@salesforce/apex/JobPortalController.getAllJobs';
import createApplication from '@salesforce/apex/JobPortalController.createApplication';

export default class JobList extends LightningElement {
    jobs;
    error;

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
        const jobId = event.target.dataset.id;

        createApplication({ jobId: jobId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Application Submitted!',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Application failed',
                        variant: 'error'
                    })
                );
            });
    }
}