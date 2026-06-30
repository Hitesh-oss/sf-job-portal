import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getJobs from "@salesforce/apex/JobController.getJobs";
import createApplication from "@salesforce/apex/JobPortalController.createApplication";
import getMyApplications from "@salesforce/apex/JobPortalController.getMyApplications";

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
  selectedExperience = "";
  sortBy = "createdDate";
  sortOrder = "desc";

  // Pagination states
  currentPage = 1;
  pageSize = 10;
  totalPages = 1;

  // Animated counter state
  displayMetrics = [];
  animationComplete = false;

  // Dark mode state
  isDarkMode = false;

  // Debounce timer handle
  searchTimeout;

  connectedCallback() {
    const savedTheme = localStorage.getItem("jobPortalTheme");
    this.isDarkMode = savedTheme === "dark";
    this.fetchApplications();
    this.loadJobs();
  }

  renderedCallback() {
    const wrapper = this.template.querySelector(".theme-wrapper");
    if (wrapper) {
      if (this.isDarkMode) {
        wrapper.classList.add("dark-theme");
        wrapper.classList.remove("light-theme");
      } else {
        wrapper.classList.add("light-theme");
        wrapper.classList.remove("dark-theme");
      }
    }
  }

  // ── Theme ────────────────────────────────────────────────
  handleThemeToggle() {
    this.isDarkMode = !this.isDarkMode;
    localStorage.setItem("jobPortalTheme", this.isDarkMode ? "dark" : "light");
    const wrapper = this.template.querySelector(".theme-wrapper");
    if (wrapper) {
      if (this.isDarkMode) {
        wrapper.classList.add("dark-theme");
        wrapper.classList.remove("light-theme");
      } else {
        wrapper.classList.add("light-theme");
        wrapper.classList.remove("dark-theme");
      }
    }
  }

  get themeToggleIcon() {
    return "utility:brightness";
  }

  get themeWrapperClass() {
    return this.isDarkMode
      ? "theme-wrapper dark-theme"
      : "theme-wrapper light-theme";
  }

  // ── Applications ─────────────────────────────────────────
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

        return { ...app, statusClass, formattedDate };
      });
    } catch (err) {
      console.error("Error fetching applications:", err);
    }
  }

  // ── Real-time Job Loading ─────────────────────────────────
  loadJobs() {
    this.isLoading = true;
    getJobs({
      query: this.searchTerm || null,
      location: this.selectedLocation || null,
      type: this.selectedJobType || null
    })
      .then((result) => {
        if (!result || result.length === 0) {
          this.jobs = [];
          this.filteredJobs = [];
          this.totalPages = 1;
          this.currentPage = 1;
          this.animateMetrics();
          this.error = undefined;
          return;
        }

        this.jobs = result.map((job) => ({
          Id: job.id,
          Job_Title__c: job.jobTitle,
          Company__c: job.companyName,
          Location__c: job.location,
          Job_Type__c: job.jobType,
          Salary_Range__c: job.salary,
          Description__c: job.description,
          Required_Skills__c: job.requiredSkills || "",
          Posted_Date__c: job.postedDate,
          Apply_URL__c: job.applyLink,
          relativeTime: this.getRelativeTime(job.postedDate) || "Today",
          isNew: job.isNew,
          skillTags:
            job.requiredSkills && job.requiredSkills !== "N/A"
              ? job.requiredSkills.split(",").map((s) => s.trim())
              : []
        }));

        this.error = undefined;
        this.applyFiltersAndSort();
        this.animateMetrics();
      })
      .catch((err) => {
        this.error = err;
        this.jobs = [];
        this.filteredJobs = [];
        this.totalPages = 1;
        this.currentPage = 1;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "API Error",
            message:
              err?.body?.message ||
              "Failed to fetch real-time jobs. Please try again.",
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  // ── Combobox Options ──────────────────────────────────────
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

  get experienceLevels() {
    return [
      { label: "All Experience Levels", value: "" },
      { label: "Fresher", value: "Fresher" },
      { label: "1-3 Years", value: "1-3 Years" },
      { label: "3-5 Years", value: "3-5 Years" },
      { label: "5+ Years", value: "5+ Years" }
    ];
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

  // ── Dashboard Metrics ─────────────────────────────────────
  get activityMetrics() {
    if (!this.jobs || !Array.isArray(this.jobs)) return [];
    const totalJobs = this.jobs.length;
    const newPostings = this.jobs.filter((job) => job.isNew).length;
    const companies = new Set(
      this.jobs.map((job) => job.Company__c).filter(Boolean)
    ).size;
    const remoteRoles = this.jobs.filter((job) =>
      (job.Location__c || "").toLowerCase().includes("remote")
    ).length;
    const maxJobs = totalJobs || 1;

    return [
      {
        label: "Active Jobs",
        value: totalJobs,
        extra: "Total live openings",
        icon: "standard:record",
        percentage: 100
      },
      {
        label: "Remote Jobs",
        value: remoteRoles,
        extra: "Work from anywhere",
        icon: "standard:home",
        percentage: Math.round((remoteRoles / maxJobs) * 100)
      },
      {
        label: "New This Week",
        value: newPostings,
        extra: "Fresh roles added",
        icon: "standard:reward",
        percentage: Math.round((newPostings / Math.max(maxJobs, 5)) * 100)
      },
      {
        label: "Active Companies",
        value: companies,
        extra: "Top hiring brands",
        icon: "standard:account",
        percentage: Math.round((companies / Math.max(maxJobs, 5)) * 100)
      }
    ];
  }

  // ── Pagination ────────────────────────────────────────────
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

  // ── Tabs ──────────────────────────────────────────────────
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

  // ── Metrics animation ─────────────────────────────────────
  animateMetrics() {
    const metrics = this.activityMetrics;
    this.displayMetrics = metrics.map((metric) => ({
      ...metric,
      displayValue: metric.value,
      progressStyle: `width: ${Math.min(metric.percentage, 100)}%`
    }));
    this.animationComplete = true;
  }

  // ── Salary parser ─────────────────────────────────────────
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

  // ── Filters & Sort (client-side for experience/sort) ─────
  applyFiltersAndSort() {
    let filtered = [...this.jobs];

    if (this.selectedExperience) {
      filtered = filtered.filter(
        (job) => job.Experience_Level__c === this.selectedExperience
      );
    }

    const [sortField, sortDirection] = this.sortValue.split("_");
    filtered.sort((a, b) => {
      let aValue;
      let bValue;

      switch (sortField) {
        case "createdDate":
          aValue = new Date(a.Posted_Date__c || "").getTime() || 0;
          bValue = new Date(b.Posted_Date__c || "").getTime() || 0;
          break;
        case "salary":
          aValue = this.parseSalary(a.Salary_Range__c);
          bValue = this.parseSalary(b.Salary_Range__c);
          break;
        default:
          aValue = 0;
          bValue = 0;
      }

      if (aValue < bValue) return sortDirection === "desc" ? 1 : -1;
      if (aValue > bValue) return sortDirection === "desc" ? -1 : 1;
      return 0;
    });

    this.filteredJobs = filtered;
    this.totalPages = Math.max(
      1,
      Math.ceil(this.filteredJobs.length / this.pageSize)
    );
    this.currentPage = Math.min(this.currentPage, this.totalPages);
  }

  // ── Event Handlers ────────────────────────────────────────
  handleSearchChange(event) {
    this.searchTerm = event.target.value;
    this.currentPage = 1;
    clearTimeout(this.searchTimeout);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.searchTimeout = setTimeout(() => {
      this.loadJobs();
    }, 500);
  }

  handleJobTypeChange(event) {
    this.selectedJobType = event.target.value;
    this.currentPage = 1;
    this.loadJobs();
  }

  handleLocationChange(event) {
    this.selectedLocation = event.target.value;
    this.currentPage = 1;
    this.loadJobs();
  }

  handleExperienceChange(event) {
    this.selectedExperience = event.target.value;
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

  handleTabChange(event) {
    event.preventDefault();
    this.activeTab = event.target.dataset.tab;
    if (this.activeTab === "applications") {
      this.fetchApplications();
    }
  }

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

    if (!resumeInput || !coverInput) return false;

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

    if (diff === 0) return "Today";
    if (diff === 1) return "Yesterday";
    if (diff < 7) return `${diff} days ago`;
    if (diff < 30) {
      const weeks = Math.floor(diff / 7);
      return `${weeks} week${weeks > 1 ? "s" : ""} ago`;
    }
    const months = Math.floor(diff / 30);
    return `${months} month${months > 1 ? "s" : ""} ago`;
  }

  // ── Submit Application ────────────────────────────────────
  async submitApplication() {
    if (!this.validateForm()) return;

    this.isLoading = true;

    try {
      const job = this.selectedJob;
      if (!job) {
        throw new Error("Selected job not found.");
      }

      const jobJson = JSON.stringify({
        id: job.Id,
        jobTitle: job.Job_Title__c,
        companyName: job.Company__c,
        location: job.Location__c,
        jobType: job.Job_Type__c,
        salary: job.Salary_Range__c,
        description: job.Description__c,
        applyLink: job.Apply_URL__c
      });

      await createApplication({
        jobJson,
        resumeUrl: this.resumeUrl.trim(),
        coverLetter: this.coverLetter.trim()
      });

      this.showForm = false;
      this.resumeUrl = "";
      this.coverLetter = "";
      await this.fetchApplications();

      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Application submitted successfully!",
          variant: "success"
        })
      );
    } catch (error) {
      const message =
        error?.body?.message ||
        error?.message ||
        "Failed to submit application. Please try again.";
      this.dispatchEvent(
        new ShowToastEvent({ title: "Error", message, variant: "error" })
      );
    } finally {
      this.isLoading = false;
    }
  }

  // ── Sync / Refresh ────────────────────────────────────────
  handleSyncJobs() {
    this.loadJobs();
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Refreshing",
        message: "Fetching latest real-time job listings...",
        variant: "info"
      })
    );
  }

  handleJobClick(event) {
    event.preventDefault();
    const jobId = event.target.dataset.id;
    console.log("Job clicked:", jobId);
  }
}
