import { LightningElement, wire } from 'lwc';
import getAllJobs from '@salesforce/apex/JobPortalController.getAllJobs';

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
}