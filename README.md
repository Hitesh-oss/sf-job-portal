# 💼 SF Job Portal — Salesforce Full Stack Project

A complete, enterprise-grade, portfolio-ready **Salesforce Full Stack Job Portal** application. This project integrates standard Lightning Web Components (LWC), secure server-side Apex Controllers, automated database triggers, Salesforce flows, and secure external REST integrations (via Named Credentials) to offer a complete end-to-end recruitment experience.

---

## 🌟 Executive Project Features

### 1. Modern & Responsive LWC Frontend

- **Visual Excellence**: Clean glassmorphism headers, gradient metric dashboard counters, and card grids styled using the **Salesforce Lightning Design System (SLDS)**.
- **Reactive Sidebar Filters**: Search and filter by job title, company name, location, or job type, combined with instant client-side sorting.
- **View Details Modal**: Overlay cards presenting full descriptions, required skills as badges, and an integrated apply action.
- **Apply Modal**: Slide-out form capturing resume URLs, cover letters, and applying real-time client validation checks.
- **My Applications Tab**: A personal job application tracking panel detailing job names, companies, applied dates, and dynamic, color-coded status badges.
- **API Sync Action**: An interactive white/indigo button inside the header triggers a background fetch to download remote postings on demand.

### 2. Secure Apex & Trigger Backend

- **Secure Apex Logic**: All classes enforce sharing regulations (`with sharing`) and utilize `WITH USER_MODE` queries to protect data security at both FLS and CRUD levels.
- **Double-Layer Duplicate Check**: Application validations check for redundant submissions at both the application controller level and database trigger level using composite custom keys.
- **Bulk Trigger Architecture**: Standardized trigger handler loops prevent Governor Limit overflows by mapping collections efficiently.

### 3. Salesforce DX Metadata Database

- **Job\_\_c Object**: Handles details like salary ranges, company names, posted dates, and API source markers.
- **Application\_\_c Object**: Formulates junction connections linking job openings, resumes, and contact profiles securely.

### 4. Codeless Flow Automation

- **Application Notification Flow**: A record-triggered Salesforce flow that runs immediately after an application is created to send customized email acknowledgments to the candidate.

### 5. Secure REST Integration

- **Virtual Named Credentials**: Encapsulates external API endpoints (`https://remotive.com/api`) declaratively, abstracting keys and credentials.
- **JobApiService Engine**: Fetches data from the Remotive Jobs API, strips HTML tags dynamically using Regex matching, parses ISO timestamps into Dates, normalizes job-type values to restricted picklists, and bulk upserts records using the unique `External_Job_Id__c` field to prevent duplicate postings.

---

## 🛠️ Complete Tech Stack

- **Frontend**: Lightning Web Components (LWC), JavaScript (ES6+), Vanilla CSS variables, and SLDS design tokens.
- **Backend**: Apex Controllers, Apex Triggers, Apex Trigger Handlers, and HTTP Mocking frameworks.
- **Database**: Custom Objects, Master-Detail relationships, and Custom Fields (Salesforce DX XML).
- **Automation**: Record-Triggered Flows, Formula fields, and Validation Rules.
- **Integrations**: REST API, Named Credentials, and JSON Deserialization engines.
- **Unit Testing**: Apex Unit Tests (100% code coverage) and LWC Jest Test suite.
- **Linter & Formatter**: Prettier (Apex & LWC plugins) and ESLint.

---

## 📁 Salesforce DX Folder Structure

```text
sf-job-portal/
├── force-app/main/default/
│   ├── applications/              # Custom app tabs & navigation configurations
│   ├── classes/                   # Apex Controller, Service classes, and Unit Tests
│   │   ├── JobPortalController.cls
│   │   ├── JobApiService.cls
│   │   ├── ApplicationTriggerHandler.cls
│   │   └── JobApiServiceTest.cls
│   ├── flows/                     # Record-triggered email notification flow
│   │   └── Application_Notification_Flow.flow-meta.xml
│   ├── lwc/                       # LWC Job Portal UI bundle
│   │   └── jobList/
│   │       ├── jobList.html
│   │       ├── jobList.js
│   │       ├── jobList.css
│   │       └── __tests__/         # Jest unit tests
│   ├── namedCredentials/          # Declarative endpoint configuration
│   │   └── Remotive_Jobs_API.namedCredential-meta.xml
│   ├── objects/                   # Job__c and Application__c schema
│   └── triggers/                  # ApplicationTrigger database event hooks
├── package.json                   # Linter, formatter, and jest scripts
└── sfdx-project.json              # Salesforce Project properties (API 66.0)
```

---

## 🚀 One-Command Deployment

To deploy all LWC files, custom objects, Named Credentials, Flows, Apex classes, and database triggers to your active Salesforce developer environment, simply execute:

```bash
sf project deploy start --source-dir force-app
```

---

## 🧪 Running Quality Assurance Checks

### 1. Apex Tests & Code Coverage

To verify the robust API callouts, JSON mappings, and duplicate prevention checks:

```bash
sf apex run test --wait 2
```

### 2. Client-Side Jest Tests

To run LWC frontend tests:

```npm
npm run test
```

### 3. JavaScript Linter & Prettier Formatter

```npm
# Format your XML, CSS, JS, and APEX code
npm run prettier

# Verify JS styling guidelines
npm run lint
```

---

## 🔄 GitHub Portfolio Workflow

To commit your modifications and synchronize them with your remote repository:

```bash
# Check status of modified files
git status

# Stage clean source directories
git add .

# Commit using professional git messages
git commit -m "Improved Salesforce Job Portal full stack project"

# Push to your main repository branch
git push origin main
```

---

## 📈 90-Day Challenge Progress

- **Current Status**: Day 2/90 — API Sync Integration, LWC Portal UI, Email Notification Flows, and Clean Repository configurations completed!
- **Daily Goal**: Consistently push clean, enterprise-grade Salesforce DX codebases to GitHub.

---

## 📸 Portal Interface Showcases

_(Embed screenshots of your gorgeous portal's Dashboard metrics, Filters, SLDS Form Modals, and Application Tracking panels here inside your portfolio!)_

---

## 👤 Author

**Hitesh Kumar Garnaik**  
_Salesforce Developer & Portfolio Builder_  
[GitHub Profile](https://github.com/Hitesh-oss) | [LinkedIn](https://linkedin.com)
