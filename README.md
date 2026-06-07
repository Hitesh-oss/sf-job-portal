# 💼 SF Job Portal — Salesforce Full Stack Recruitment Application

## 📖 Project Overview

SF Job Portal is a Salesforce full stack recruitment application built using Lightning Web Components, Apex, Salesforce Flow, Salesforce DX, and REST API integration.

The project allows users to browse jobs, filter job listings, view job details, apply for jobs, and track application status. It also supports external job sync from the Remotive Jobs API using Salesforce Named Credentials.

## ✨ Key Features

- Responsive Lightning Web Component job portal UI
- Job search and filtering
- Job details and apply modal
- My Applications tracking section
- Duplicate application prevention using Apex and Trigger
- Record-triggered Flow for email acknowledgment
- External job sync using Remotive Jobs API
- Secure API access using Named Credentials
- Salesforce DX project structure

## 🛠️ Tech Stack

- Lightning Web Components
- Apex Classes and Triggers
- Salesforce Flow
- Salesforce DX
- Custom Objects and Fields
- Named Credentials
- REST API Integration
- Git and GitHub

## 🗄️ Salesforce Objects

- **Job\_\_c**: Stores job posting details like title, company, location, job type, salary, description, required skills, posted date, and external job ID.
- **Application\_\_c**: Stores candidate application details like applicant name, email, resume URL, cover letter, status, applied date, and related job.

## 🏗️ Architecture

- **LWC** handles the user interface.
- **Apex Controller** handles server-side logic.
- **Trigger Handler** prevents duplicate applications.
- **Salesforce Flow** sends application confirmation emails.
- **Named Credential** secures the external API endpoint.
- **JobApiService** syncs jobs from the Remotive Jobs API.

## 🚀 Deployment

Deploy the project to your Salesforce org:

```bash
sf project deploy start --source-dir force-app
```

## 🧪 Testing

Run tests and formatting checks:

```bash
sf apex run test --wait 2
npm run test
npm run prettier
npm run lint
```

## 🔄 GitHub Workflow

Commit and push updates to your repository:

```bash
git status
git add .
git commit -m "Update professional README for SF Job Portal"
git push origin main
```

## 🎤 Interview Explanation

**How to explain this project:**
I built this Salesforce Full Stack Job Portal to demonstrate my skills in Salesforce Administration, Apex Development, Lightning Web Components, Flow Automation, and REST API Integration.

The project allows candidates to view jobs, apply for positions, and track application status. It includes custom objects, Apex business logic, duplicate prevention, automated email notification, and external API job synchronization.

## 👨‍💻 Author

**Hitesh Kumar Garnayak**  
_Salesforce Administrator & Developer_

- **GitHub:** [Hitesh-oss](https://github.com/Hitesh-oss)
- **Email:** garnayakhitesh@gmail.com
- **LinkedIn:** [LinkedIn Profile](https://linkedin.com/in/YOUR_LINKEDIN_PROFILE_HERE) _(Replace this placeholder with your actual link)_
