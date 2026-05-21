import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import getAllJobs from "@salesforce/apex/JobPortalController.getAllJobs";
import createApplication from "@salesforce/apex/JobPortalController.createApplication";
import getMyApplications from "@salesforce/apex/JobPortalController.getMyApplications";
import syncJobs from "@salesforce/apex/JobPortalController.syncJobs";

export default class JobList extends LightningElement {
  jobs = [];
  filteredJobs = [];
  error;
  isLoading = false;

  // Apply Form Modal states
  showForm = false;
  selectedJobId;
  resumeUrl = "";
  coverLetter = "";

  // Advanced features states
  activeTab = "jobs";
  showDetailsModal = false;
  applications = [];

  // Search and Filter states
  searchTerm = "";
  selectedJobType = "";
  selectedLocation = "";
  sortBy = "createdDate";
  sortOrder = "desc";

  // Pagination states
  currentPage = 1;
  pageSize = 10;
  totalPages = 1;

  // Animated counter state
  displayMetrics = [];
  animationComplete = false;

  connectedCallback() {
    this.fetchApplications();
  }

  // Retrieve submitted applications securely via Apex
  async fetchApplications() {
    try {
      const data = await getMyApplications();
      if (!data || !Array.isArray(data)) {
        this.applications = [];
        return;
      }
      this.applications = data.map((app) => {
        let statusClass = "status-badge ";
        const status = app.Application_Status__c
          ? app.Application_Status__c.toLowerCase()
          : "";
        if (status === "applied") {
          statusClass += "status-badge_applied";
        } else if (status === "shortlisted") {
          statusClass += "status-badge_shortlisted";
        } else if (status === "selected") {
          statusClass += "status-badge_selected";
        } else if (status === "rejected") {
          statusClass += "status-badge_rejected";
        } else {
          statusClass += "status-badge_applied";
        }

        let formattedDate = "";
        if (app.Applied_Date__c) {
          const dateObj = new Date(app.Applied_Date__c);
          formattedDate = dateObj.toLocaleDateString("en-US", {
            year: "numeric",
            month: "short",
            day: "numeric",
            timeZone: "UTC"
          });
        }

        return {
          ...app,
          statusClass,
          formattedDate
        };
      });
    } catch (err) {
      console.error("Error fetching applications:", err);
    }
  }

  get jobTypes() {
    return [
      { label: "All Types", value: "" },
      { label: "Full-time", value: "Full-time" },
      { label: "Part-time", value: "Part-time" },
      { label: "Internship", value: "Internship" },
      { label: "Remote", value: "Remote" },
      { label: "Contract", value: "Contract" }
    ];
  }

  get locations() {
    const defaultLocations = [
      "All Locations",
      "Bhubaneswar",
      "Bengaluru",
      "Hyderabad",
      "Pune",
      "Mumbai",
      "Delhi",
      "Noida",
      "Gurgaon",
      "Chennai",
      "Kolkata",
      "Remote",
      "India"
    ];
    let options = defaultLocations.map((loc) => ({
      label: loc,
      value: loc === "All Locations" ? "" : loc
    }));

    if (this.jobs && Array.isArray(this.jobs)) {
      const uniqueLocs = [
        ...new Set(this.jobs.map((job) => job.Location__c))
      ].filter(Boolean);
      uniqueLocs.forEach((loc) => {
        if (!defaultLocations.includes(loc)) {
          options.push({ label: loc, value: loc });
        }
      });
    }
    return options;
  }

  get sortOptions() {
    return [
      { label: "Posted Date (Newest)", value: "createdDate_desc" },
      { label: "Posted Date (Oldest)", value: "createdDate_asc" },
      { label: "Salary (High to Low)", value: "salary_desc" },
      { label: "Salary (Low to High)", value: "salary_asc" }
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

  get selectedJob() {
    if (!this.jobs || !this.selectedJobId) return null;
    return this.jobs.find((job) => job.Id === this.selectedJobId);
  }

  get showPagination() {
    return this.totalPages > 1;
  }

  get isFirstPage() {
    return this.currentPage <= 1;
  }

  get isLastPage() {
    return this.currentPage >= this.totalPages;
  }

  get isJobsTabActive() {
    return this.activeTab === "jobs";
  }

  get isApplicationsTabActive() {
    return this.activeTab === "applications";
  }

  get activeJobsTabClass() {
    return this.activeTab === "jobs"
      ? "custom-tab-item active"
      : "custom-tab-item";
  }

  get activeApplicationsTabClass() {
    return this.activeTab === "applications"
      ? "custom-tab-item active"
      : "custom-tab-item";
  }

  wiredJobsResult;

  @wire(getAllJobs)
  wiredJobs(result) {
    this.wiredJobsResult = result;
    const { error, data } = result;
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
    const metrics = this.activityMetrics;
    this.displayMetrics = metrics.map((metric) => ({
      ...metric,
      displayValue: metric.value
    }));
    this.animationComplete = true;
  }

  parseSalary(salaryStr) {
    if (!salaryStr) return 0;
    const lower = salaryStr.toLowerCase();
    const firstPart = lower.split("-")[0].trim();
    const digits = parseFloat(firstPart.replace(/[^0-9.]/g, ""));
    if (isNaN(digits)) return 0;
    if (lower.includes("lpa")) return digits * 100000;
    if (firstPart.includes("k")) return digits * 1000;
    return digits;
  }

  applyFiltersAndSort() {
    let filtered = [...this.jobs];

    if (this.searchTerm) {
      const term = this.searchTerm.toLowerCase();
      filtered = filtered.filter(
        (job) =>
          (job.Job_Title__c || "").toLowerCase().includes(term) ||
          (job.Company__c || "").toLowerCase().includes(term) ||
          (job.Location__c || "").toLowerCase().includes(term) ||
          (job.Description__c || "").toLowerCase().includes(term) ||
          (job.Required_Skills__c || "").toLowerCase().includes(term)
      );
    }

    if (this.selectedJobType) {
      filtered = filtered.filter((job) => {
        if (this.selectedJobType === "Remote") {
          return (
            (job.Job_Type__c || "").toLowerCase().includes("remote") ||
            (job.Location__c || "").toLowerCase().includes("remote")
          );
        }
        if (this.selectedJobType === "Contract") {
          return (job.Job_Type__c || "").startsWith("Contract");
        }
        return job.Job_Type__c === this.selectedJobType;
      });
    }

    if (this.selectedLocation) {
      if (this.selectedLocation === "India") {
        const indiaCities = [
          "Bhubaneswar",
          "Bengaluru",
          "Hyderabad",
          "Pune",
          "Mumbai",
          "Delhi",
          "Noida",
          "Gurgaon",
          "Chennai",
          "Kolkata",
          "India"
        ];
        filtered = filtered.filter((job) =>
          indiaCities.includes(job.Location__c)
        );
      } else {
        filtered = filtered.filter(
          (job) => job.Location__c === this.selectedLocation
        );
      }
    }

    const [sortField, sortDirection] = this.sortValue.split("_");
    filtered.sort((a, b) => {
      let aValue;
      let bValue;

      switch (sortField) {
        case "createdDate":
          aValue = new Date(a.Posted_Date__c || a.CreatedDate).getTime();
          bValue = new Date(b.Posted_Date__c || b.CreatedDate).getTime();
          break;
        case "salary":
          aValue = this.parseSalary(a.Salary_Range__c);
          bValue = this.parseSalary(b.Salary_Range__c);
          break;
        default:
          aValue = 0;
          bValue = 0;
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

  // Tab Selection Switcher
  handleTabChange(event) {
    event.preventDefault();
    this.activeTab = event.target.dataset.tab;
    if (this.activeTab === "applications") {
      this.fetchApplications();
    }
  }

  // Modal view handlers for details and applications
  handleViewDetails(event) {
    this.selectedJobId = event.target.dataset.id;
    this.showDetailsModal = true;
  }

  handleCloseDetails() {
    this.showDetailsModal = false;
  }

  handleApplyFromDetails() {
    this.showDetailsModal = false;
    this.showForm = true;
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

      // Instantly refresh application list dynamically on success
      await this.fetchApplications();

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

  async handleSyncJobs() {
    this.isLoading = true;
    try {
      await syncJobs();
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Real jobs synchronized successfully!",
          variant: "success"
        })
      );
      await refreshApex(this.wiredJobsResult);
    } catch (error) {
      let message = "Failed to sync jobs.";
      if (error?.body?.message) {
        message = error.body.message;
      } else if (error?.message) {
        message = error.message;
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
