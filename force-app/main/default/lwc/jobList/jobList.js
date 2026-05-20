import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAllJobs from "@salesforce/apex/JobPortalController.getAllJobs";
import createApplication from "@salesforce/apex/JobPortalController.createApplication";

export default class JobList extends LightningElement {
  jobs = [];
  filteredJobs = [];
  error;
  isLoading = false;

  showForm = false;
  selectedJobId;
  resumeUrl = "";
  coverLetter = "";

  searchTerm = "";
  selectedJobType = "";
  selectedLocation = "";
  sortBy = "createdDate";
  sortOrder = "desc";

  currentPage = 1;
  pageSize = 10;
  totalPages = 1;

  // Animated counter state
  displayMetrics = [];
  animationComplete = false;

  get jobTypes() {
    if (!this.jobs || !Array.isArray(this.jobs)) return [];
    const types = [...new Set(this.jobs.map((job) => job.Job_Type__c))].filter(
      Boolean
    );
    return types.map((type) => ({ label: type, value: type }));
  }

  get locations() {
    if (!this.jobs || !Array.isArray(this.jobs)) return [];
    const locs = [...new Set(this.jobs.map((job) => job.Location__c))].filter(
      Boolean
    );
    return locs.map((loc) => ({ label: loc, value: loc }));
  }

  get sortOptions() {
    return [
      { label: "Posted Date (Newest)", value: "createdDate_desc" },
      { label: "Posted Date (Oldest)", value: "createdDate_asc" },
      { label: "Job Title (A-Z)", value: "title_asc" },
      { label: "Job Title (Z-A)", value: "title_desc" },
      { label: "Company (A-Z)", value: "company_asc" },
      { label: "Company (Z-A)", value: "company_desc" }
    ];
  }

  get sortValue() {
    return `${this.sortBy}_${this.sortOrder}`;
  }

  get featuredJobs() {
    if (!this.jobs || !Array.isArray(this.jobs)) return [];
    return this.jobs.slice(0, 3);
  }

  get activityMetrics() {
    if (!this.jobs || !Array.isArray(this.jobs)) return [];
    const newPostings = this.jobs.filter((job) => job.isNew).length;
    const companies = new Set(
      this.jobs.map((job) => job.Company__c).filter(Boolean)
    ).size;
    const remoteRoles = this.jobs.filter((job) =>
      (job.Location__c || "").toLowerCase().includes("remote")
    ).length;
    const maxJobs = this.jobs.length || 1;

    return [
      {
        label: "New This Week",
        value: newPostings,
        extra: "Fresh roles added recently",
        icon: "standard:record",
        percentage: Math.round((newPostings / Math.max(maxJobs, 5)) * 100)
      },
      {
        label: "Active Companies",
        value: companies,
        extra: "Hiring across companies",
        icon: "standard:account",
        percentage: Math.round((companies / Math.max(maxJobs, 5)) * 100)
      },
      {
        label: "Remote-Friendly",
        value: remoteRoles,
        extra: "Roles with remote options",
        icon: "standard:home",
        percentage: Math.round((remoteRoles / maxJobs) * 100)
      }
    ];
  }

  get paginatedJobs() {
    if (!this.filteredJobs || !Array.isArray(this.filteredJobs)) return [];
    const startIndex = (this.currentPage - 1) * this.pageSize;
    return this.filteredJobs.slice(startIndex, startIndex + this.pageSize);
  }

  get showPagination() {
    return this.totalPages > 1;
  }

  get hasPreviousPage() {
    return this.currentPage <= 1;
  }

  get hasNextPage() {
    return this.currentPage >= this.totalPages;
  }

  @wire(getAllJobs)
  wiredJobs({ error, data }) {
    this.isLoading = true;
    if (data) {
      const jobsWithMetadata = data.map((job) => {
        const relativeTime = this.getRelativeTime(job.CreatedDate);
        return {
          ...job,
          skillTags: job.Required_Skills__c
            ? job.Required_Skills__c.split(",").map((s) => s.trim())
            : [],
          relativeTime,
          isNew: relativeTime === "Today" || relativeTime === "Yesterday"
        };
      });
      this.jobs = jobsWithMetadata;
      this.error = undefined;
      this.applyFiltersAndSort();
      // Trigger animation after data loads
      this.animateMetrics();
    } else if (error) {
      this.error = error;
      this.jobs = [];
      this.filteredJobs = [];
      this.totalPages = 1;
    }
    this.isLoading = false;
  }

  animateMetrics() {
    // Set display metrics to final values
    const metrics = this.activityMetrics;
    this.displayMetrics = metrics.map((metric) => ({
      ...metric,
      displayValue: metric.value
    }));
    this.animationComplete = true;
  }

  applyFiltersAndSort() {
    let filtered = [...this.jobs];

    if (this.searchTerm) {
      const term = this.searchTerm.toLowerCase();
      filtered = filtered.filter(
        (job) =>
          (job.Job_Title__c || "").toLowerCase().includes(term) ||
          (job.Company__c || "").toLowerCase().includes(term) ||
          (job.Description__c || "").toLowerCase().includes(term) ||
          (job.Required_Skills__c || "").toLowerCase().includes(term)
      );
    }

    if (this.selectedJobType) {
      filtered = filtered.filter(
        (job) => job.Job_Type__c === this.selectedJobType
      );
    }

    if (this.selectedLocation) {
      filtered = filtered.filter(
        (job) => job.Location__c === this.selectedLocation
      );
    }

    const [sortField, sortDirection] = this.sortValue.split("_");
    filtered.sort((a, b) => {
      let aValue;
      let bValue;

      switch (sortField) {
        case "createdDate":
          aValue = new Date(a.CreatedDate);
          bValue = new Date(b.CreatedDate);
          break;
        case "title":
          aValue = (a.Job_Title__c || "").toLowerCase();
          bValue = (b.Job_Title__c || "").toLowerCase();
          break;
        case "company":
          aValue = (a.Company__c || "").toLowerCase();
          bValue = (b.Company__c || "").toLowerCase();
          break;
        default:
          aValue = "";
          bValue = "";
      }

      if (aValue < bValue) {
        return sortDirection === "desc" ? 1 : -1;
      }
      if (aValue > bValue) {
        return sortDirection === "desc" ? -1 : 1;
      }
      return 0;
    });

    this.filteredJobs = filtered;
    this.totalPages = Math.max(
      1,
      Math.ceil(this.filteredJobs.length / this.pageSize)
    );
    this.currentPage = Math.min(this.currentPage, this.totalPages);
  }

  handleSearchChange(event) {
    this.searchTerm = event.target.value;
    this.currentPage = 1;
    this.applyFiltersAndSort();
  }

  handleJobTypeChange(event) {
    this.selectedJobType = event.target.value;
    this.currentPage = 1;
    this.applyFiltersAndSort();
  }

  handleLocationChange(event) {
    this.selectedLocation = event.target.value;
    this.currentPage = 1;
    this.applyFiltersAndSort();
  }

  handleSortChange(event) {
    const [field, order] = event.target.value.split("_");
    this.sortBy = field;
    this.sortOrder = order;
    this.currentPage = 1;
    this.applyFiltersAndSort();
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage -= 1;
    }
  }

  handleNextPage() {
    if (this.currentPage < this.totalPages) {
      this.currentPage += 1;
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

  handleCancel() {
    this.showForm = false;
    this.resumeUrl = "";
    this.coverLetter = "";
    this.clearValidationErrors();
  }

  clearValidationErrors() {
    const inputs = this.template.querySelectorAll(
      "lightning-input, lightning-textarea"
    );
    inputs.forEach((input) => {
      input.setCustomValidity("");
      input.reportValidity();
    });
  }

  validateForm() {
    let isValid = true;
    const resumeInput = this.template.querySelector(
      'lightning-input[data-field="resume"]'
    );
    const coverInput = this.template.querySelector(
      'lightning-textarea[data-field="cover"]'
    );

    if (!resumeInput || !coverInput) {
      return false;
    }

    if (!this.resumeUrl || !this.resumeUrl.trim()) {
      resumeInput.setCustomValidity("Resume URL is required");
      isValid = false;
    } else if (!this.isValidUrl(this.resumeUrl)) {
      resumeInput.setCustomValidity("Please enter a valid URL");
      isValid = false;
    } else {
      resumeInput.setCustomValidity("");
    }

    if (!this.coverLetter || !this.coverLetter.trim()) {
      coverInput.setCustomValidity("Cover letter is required");
      isValid = false;
    } else if (this.coverLetter.trim().length < 50) {
      coverInput.setCustomValidity(
        "Cover letter must be at least 50 characters"
      );
      isValid = false;
    } else {
      coverInput.setCustomValidity("");
    }

    resumeInput.reportValidity();
    coverInput.reportValidity();

    return isValid;
  }

  isValidUrl(value) {
    try {
      const url = new URL(value);
      return url !== null;
    } catch {
      return false;
    }
  }

  getRelativeTime(dateString) {
    if (!dateString) return "";
    const now = new Date();
    const date = new Date(dateString);
    const diff = Math.floor((now - date) / (1000 * 60 * 60 * 24));

    if (diff === 0) {
      return "Today";
    }
    if (diff === 1) {
      return "Yesterday";
    }
    if (diff < 7) {
      return `${diff} days ago`;
    }
    if (diff < 30) {
      const weeks = Math.floor(diff / 7);
      return `${weeks} week${weeks > 1 ? "s" : ""} ago`;
    }
    const months = Math.floor(diff / 30);
    return `${months} month${months > 1 ? "s" : ""} ago`;
  }

  async submitApplication() {
    if (!this.validateForm()) {
      return;
    }

    this.isLoading = true;

    try {
      await createApplication({
        jobId: this.selectedJobId,
        resumeUrl: this.resumeUrl.trim(),
        coverLetter: this.coverLetter.trim()
      });

      this.showForm = false;
      this.resumeUrl = "";
      this.coverLetter = "";
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Application submitted successfully!",
          variant: "success"
        })
      );
    } catch (error) {
      let message = "Failed to submit application. Please try again.";
      if (error?.body?.message) {
        message = error.body.message;
      }
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message,
          variant: "error"
        })
      );
    } finally {
      this.isLoading = false;
    }
  }

  handleJobClick(event) {
    event.preventDefault();
    const jobId = event.target.dataset.id;
    console.log("Job clicked:", jobId);
  }
}
