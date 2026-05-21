// =============================================================================
// SF Job Portal - Sample Job Data Script
// Run via: sf apex run --file scripts/apex/InsertSampleJobs.apex
// Inserts 20 sample Job__c records across India locations.
// =============================================================================

List<Job__c> jobs = new List<Job__c>{
    new Job__c(
        Name = 'Salesforce Developer',
        Job_Title__c = 'Salesforce Developer',
        Company__c = 'Infosys',
        Location__c = 'Bengaluru',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '8 LPA - 14 LPA',
        Required_Skills__c = 'Apex, LWC, SOQL, Flows, Admin',
        Description__c = 'Develop and maintain Salesforce applications using Apex, LWC, and Flows. Work with business teams to deliver CRM solutions.',
        Posted_Date__c = Date.today().addDays(-2),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Admin',
        Job_Title__c = 'Salesforce Admin',
        Company__c = 'TCS',
        Location__c = 'Hyderabad',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '5 LPA - 9 LPA',
        Required_Skills__c = 'Salesforce Admin, Flows, Reports, Dashboards',
        Description__c = 'Manage Salesforce org, user access, data quality, and automation flows. Support business stakeholders with reports and dashboards.',
        Posted_Date__c = Date.today().addDays(-5),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'LWC Frontend Developer',
        Job_Title__c = 'LWC Frontend Developer',
        Company__c = 'Wipro',
        Location__c = 'Pune',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '10 LPA - 18 LPA',
        Required_Skills__c = 'LWC, JavaScript, CSS, HTML, SLDS, Apex',
        Description__c = 'Build modern, responsive Salesforce Lightning Web Components for enterprise clients. Collaborate with UX and backend teams.',
        Posted_Date__c = Date.today().addDays(-1),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Integration Consultant',
        Job_Title__c = 'Salesforce Integration Consultant',
        Company__c = 'Accenture',
        Location__c = 'Mumbai',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '15 LPA - 25 LPA',
        Required_Skills__c = 'REST API, Named Credentials, Mulesoft, Apex, Integration',
        Description__c = 'Design and implement Salesforce integrations using REST/SOAP APIs, Named Credentials, and middleware platforms like Mulesoft.',
        Posted_Date__c = Date.today().addDays(-3),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Intern',
        Job_Title__c = 'Salesforce Intern',
        Company__c = 'Capgemini',
        Location__c = 'Bhubaneswar',
        Job_Type__c = 'Internship',
        Salary_Range__c = '15000 - 25000 per month',
        Required_Skills__c = 'Salesforce Admin, Apex Basics, Trailhead',
        Description__c = 'Join our Salesforce team as an intern. Learn hands-on with real projects, Apex, LWC, and Salesforce administration.',
        Posted_Date__c = Date.today().addDays(-7),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Senior Salesforce Architect',
        Job_Title__c = 'Senior Salesforce Architect',
        Company__c = 'Deloitte',
        Location__c = 'Gurgaon',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '30 LPA - 50 LPA',
        Required_Skills__c = 'Salesforce Architecture, Apex, LWC, Integration, Security, Data Modelling',
        Description__c = 'Lead Salesforce solution design for large enterprise clients. Define best practices, review code, and mentor junior developers.',
        Posted_Date__c = Date.today().addDays(-4),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce QA Engineer',
        Job_Title__c = 'Salesforce QA Engineer',
        Company__c = 'HCL Technologies',
        Location__c = 'Chennai',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '6 LPA - 11 LPA',
        Required_Skills__c = 'Selenium, Apex Tests, Jest, Test Automation, SOQL',
        Description__c = 'Write automated tests for Salesforce implementations using Jest, Apex Unit Tests, and Selenium. Ensure quality across LWC and Apex layers.',
        Posted_Date__c = Date.today().addDays(-6),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce CPQ Specialist',
        Job_Title__c = 'Salesforce CPQ Specialist',
        Company__c = 'IBM India',
        Location__c = 'Noida',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '12 LPA - 20 LPA',
        Required_Skills__c = 'Salesforce CPQ, Quote-to-Cash, Apex, Price Rules, Admin',
        Description__c = 'Implement and support Salesforce CPQ (Configure Price Quote) solutions. Work with sales teams on pricing configuration and product catalog.',
        Posted_Date__c = Date.today().addDays(-8),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Marketing Cloud Developer',
        Job_Title__c = 'Salesforce Marketing Cloud Developer',
        Company__c = 'Cognizant',
        Location__c = 'Delhi',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '10 LPA - 17 LPA',
        Required_Skills__c = 'Marketing Cloud, AMPscript, SQL, Journey Builder, Email Studio',
        Description__c = 'Develop and maintain Salesforce Marketing Cloud journeys, email templates, and automation workflows for marketing campaigns.',
        Posted_Date__c = Date.today().addDays(-10),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Remote Salesforce Developer',
        Job_Title__c = 'Remote Salesforce Developer',
        Company__c = 'Persistent Systems',
        Location__c = 'Remote',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '9 LPA - 16 LPA',
        Required_Skills__c = 'Apex, LWC, Triggers, SOQL, Git, Agile',
        Description__c = 'Work fully remote as a Salesforce Developer. Build and maintain CRM features using Apex, LWC, and Salesforce best practices.',
        Posted_Date__c = Date.today().addDays(-1),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Data Analyst',
        Job_Title__c = 'Salesforce Data Analyst',
        Company__c = 'Mphasis',
        Location__c = 'Kolkata',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '6 LPA - 10 LPA',
        Required_Skills__c = 'SOQL, Reports, Dashboards, Data Loader, Excel, Analytics',
        Description__c = 'Analyze CRM data using Salesforce Reports, SOQL queries, and Tableau CRM. Support sales teams with actionable insights.',
        Posted_Date__c = Date.today().addDays(-9),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Service Cloud Consultant',
        Job_Title__c = 'Salesforce Service Cloud Consultant',
        Company__c = 'Tech Mahindra',
        Location__c = 'Bengaluru',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '11 LPA - 19 LPA',
        Required_Skills__c = 'Service Cloud, Case Management, Omni-Channel, Knowledge Base',
        Description__c = 'Design and implement Salesforce Service Cloud features including case management, Omni-Channel routing, and knowledge base articles.',
        Posted_Date__c = Date.today().addDays(-5),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce DevOps Engineer',
        Job_Title__c = 'Salesforce DevOps Engineer',
        Company__c = 'Zensar Technologies',
        Location__c = 'Pune',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '13 LPA - 22 LPA',
        Required_Skills__c = 'SFDX, Git, CI/CD, Copado, Jenkins, DevOps, Apex',
        Description__c = 'Build and maintain Salesforce DevOps pipelines using SFDX, Git, and Copado. Automate deployments and ensure code quality standards.',
        Posted_Date__c = Date.today().addDays(-3),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Freelance Consultant',
        Job_Title__c = 'Salesforce Freelance Consultant',
        Company__c = 'IndependentConsulting.in',
        Location__c = 'Remote',
        Job_Type__c = 'Contract,',
        Salary_Range__c = '2000 - 4000 per day',
        Required_Skills__c = 'Salesforce Consulting, Requirements, Apex, Admin, Flows',
        Description__c = 'Engage as a Salesforce freelance consultant for short-term project engagements. Flexible work hours and fully remote delivery.',
        Posted_Date__c = Date.today().addDays(-2),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Business Analyst',
        Job_Title__c = 'Salesforce Business Analyst',
        Company__c = 'Hexaware Technologies',
        Location__c = 'Hyderabad',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '8 LPA - 14 LPA',
        Required_Skills__c = 'Requirements Gathering, User Stories, JIRA, Salesforce Admin, Flows',
        Description__c = 'Bridge business requirements and Salesforce technical implementation. Write user stories, manage sprints, and validate deliverables.',
        Posted_Date__c = Date.today().addDays(-11),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Part-time Salesforce Trainer',
        Job_Title__c = 'Part-time Salesforce Trainer',
        Company__c = 'CloudBlue Academy',
        Location__c = 'Delhi',
        Job_Type__c = 'Part-time',
        Salary_Range__c = '30000 - 50000 per month',
        Required_Skills__c = 'Salesforce Teaching, Apex, Admin, Trailhead, Communication',
        Description__c = 'Conduct Salesforce training sessions for aspiring developers and admins. Create course content and guide learners on their Trailhead journey.',
        Posted_Date__c = Date.today().addDays(-13),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Vlocity Developer',
        Job_Title__c = 'Salesforce Vlocity Developer',
        Company__c = 'Birlasoft',
        Location__c = 'Noida',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '14 LPA - 24 LPA',
        Required_Skills__c = 'Vlocity, Omnistudio, DataRaptor, FlexCards, Apex, SOQL',
        Description__c = 'Build Salesforce Industry Cloud solutions using Vlocity (OmniStudio), DataRaptors, and FlexCards for telecom and insurance domains.',
        Posted_Date__c = Date.today().addDays(-6),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Experience Cloud Developer',
        Job_Title__c = 'Salesforce Experience Cloud Developer',
        Company__c = 'Larsen & Toubro Infotech',
        Location__c = 'Mumbai',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '10 LPA - 16 LPA',
        Required_Skills__c = 'Experience Cloud, Communities, LWC, Apex, Digital Experiences',
        Description__c = 'Design and develop Salesforce Experience Cloud portals for partners and customers. Customize community templates and build LWC components.',
        Posted_Date__c = Date.today().addDays(-4),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Apex Developer Intern',
        Job_Title__c = 'Salesforce Apex Developer Intern',
        Company__c = 'NeoSoft Technologies',
        Location__c = 'Bhubaneswar',
        Job_Type__c = 'Internship',
        Salary_Range__c = '10000 - 20000 per month',
        Required_Skills__c = 'Apex Basics, SOQL, Trailhead, Java, OOP Concepts',
        Description__c = 'Learn Salesforce development in a structured internship program. Gain hands-on experience with Apex classes, triggers, and SOQL queries.',
        Posted_Date__c = Date.today().addDays(-15),
        Status__c = 'Active,'
    ),
    new Job__c(
        Name = 'Salesforce Analytics Developer',
        Job_Title__c = 'Salesforce Analytics Developer',
        Company__c = 'Mindtree',
        Location__c = 'Chennai',
        Job_Type__c = 'Full-time',
        Salary_Range__c = '12 LPA - 20 LPA',
        Required_Skills__c = 'Tableau CRM, SAQL, Einstein Analytics, Dataflows, Dashboards',
        Description__c = 'Build advanced Salesforce Tableau CRM (Einstein Analytics) dashboards and dataflows. Enable self-service analytics for sales and operations teams.',
        Posted_Date__c = Date.today().addDays(-8),
        Status__c = 'Active,'
    )
};

insert jobs;
System.debug('SUCCESS: ' + jobs.size() + ' sample jobs inserted successfully!');
