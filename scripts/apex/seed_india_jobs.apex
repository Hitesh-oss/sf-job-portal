// Script to seed professional India-based jobs into the Salesforce Job Portal
// Does not scrape private data. Data is curated specifically for demonstration.

List<Job__c> sampleJobs = new List<Job__c>();

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-001',
    Name = 'Senior Salesforce Developer',
    Job_Title__c = 'Senior Salesforce Developer',
    Company__c = 'TechNova Solutions',
    Location__c = 'Bengaluru',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '18 - 25 LPA',
    Description__c = 'We are looking for an experienced Salesforce Developer to lead our CRM transformation. You will design, develop, and implement complex Apex, LWC, and integration solutions.',
    Required_Skills__c = 'Apex, LWC, Integration, SOQL',
    Posted_Date__c = System.today().addDays(-2),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-001',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-002',
    Name = 'Cloud Solution Architect',
    Job_Title__c = 'Cloud Solution Architect',
    Company__c = 'Global Systems India',
    Location__c = 'Hyderabad',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '30 - 45 LPA',
    Description__c = 'Architect robust cloud environments across AWS and Azure. Work with enterprise clients in India and APAC to design scalable distributed systems.',
    Required_Skills__c = 'AWS, Azure, Kubernetes, System Design',
    Posted_Date__c = System.today().addDays(-1),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-002',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-003',
    Name = 'Frontend Engineer (React)',
    Job_Title__c = 'Frontend Engineer (React)',
    Company__c = 'Creative UX Studio',
    Location__c = 'Pune',
    Job_Type__c = 'Contract,',
    Salary_Range__c = '12 - 18 LPA',
    Description__c = 'Join our creative team for a 6-month contract to build high-performance React applications with stunning UI/UX for fintech clients.',
    Required_Skills__c = 'React, JavaScript, CSS, Redux',
    Posted_Date__c = System.today().addDays(-5),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-003',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-004',
    Name = 'Data Scientist',
    Job_Title__c = 'Data Scientist',
    Company__c = 'AI Innovations Ltd',
    Location__c = 'Mumbai',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '20 - 30 LPA',
    Description__c = 'Build predictive models and machine learning pipelines. Leverage big data technologies to drive analytics and actionable insights.',
    Required_Skills__c = 'Python, Machine Learning, SQL, Pandas',
    Posted_Date__c = System.today(),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-004',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-005',
    Name = 'Product Manager',
    Job_Title__c = 'Product Manager',
    Company__c = 'FinServe India',
    Location__c = 'Gurgaon',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '25 - 35 LPA',
    Description__c = 'Lead the product lifecycle for our core lending platform. Work closely with engineering and business stakeholders to define roadmaps and features.',
    Required_Skills__c = 'Agile, Product Strategy, JIRA, FinTech',
    Posted_Date__c = System.today().addDays(-3),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-005',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-006',
    Name = 'DevOps Engineer',
    Job_Title__c = 'DevOps Engineer',
    Company__c = 'CloudScale Solutions',
    Location__c = 'Chennai',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '15 - 22 LPA',
    Description__c = 'Maintain and optimize CI/CD pipelines, automate infrastructure using Terraform, and ensure 99.9% uptime for core microservices.',
    Required_Skills__c = 'Jenkins, Docker, AWS, Terraform',
    Posted_Date__c = System.today(),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-006',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-007',
    Name = 'Business Analyst',
    Job_Title__c = 'Business Analyst',
    Company__c = 'RetailTech Corp',
    Location__c = 'Noida',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '10 - 15 LPA',
    Description__c = 'Gather requirements for e-commerce implementations. Act as a bridge between technical teams and retail stakeholders.',
    Required_Skills__c = 'Requirement Gathering, SQL, E-commerce',
    Posted_Date__c = System.today().addDays(-4),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-007',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-008',
    Name = 'Full Stack Developer',
    Job_Title__c = 'Full Stack Developer',
    Company__c = 'Startup Hub',
    Location__c = 'Remote',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '14 - 20 LPA',
    Description__c = 'Exciting remote role! Build end-to-end features using Node.js backend and Vue.js frontend in a fast-paced environment.',
    Required_Skills__c = 'Node.js, Vue.js, MongoDB, Express',
    Posted_Date__c = System.today().addDays(-1),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-008',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-009',
    Name = 'Marketing Specialist',
    Job_Title__c = 'Marketing Specialist',
    Company__c = 'Digital Wave',
    Location__c = 'Kolkata',
    Job_Type__c = 'Part-time',
    Salary_Range__c = '5 - 8 LPA',
    Description__c = 'Part-time opportunity. Drive digital marketing campaigns, SEO, and social media engagement for local brands.',
    Required_Skills__c = 'SEO, Social Media, Content Marketing',
    Posted_Date__c = System.today().addDays(-7),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-009',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-010',
    Name = 'Software Tester (QA)',
    Job_Title__c = 'Software Tester (QA)',
    Company__c = 'QualityWorks Ltd',
    Location__c = 'Bhubaneswar',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '6 - 10 LPA',
    Description__c = 'Ensure high-quality software releases. Write automated test scripts in Selenium and perform manual regression testing.',
    Required_Skills__c = 'Selenium, Manual Testing, Java',
    Posted_Date__c = System.today().addDays(-2),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-010',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

sampleJobs.add(new Job__c(
    External_Job_Id__c = 'IND-TECH-011',
    Name = 'HR Manager',
    Job_Title__c = 'HR Manager',
    Company__c = 'NextGen Solutions',
    Location__c = 'Delhi',
    Job_Type__c = 'Full-time',
    Salary_Range__c = '12 - 18 LPA',
    Description__c = 'Manage recruitment, employee engagement, and onboarding processes for our growing engineering hub.',
    Required_Skills__c = 'Recruitment, Employee Relations',
    Posted_Date__c = System.today().addDays(-6),
    Apply_URL__c = 'https://example.com/apply/IND-TECH-011',
    Source__c = 'Manual India Jobs',
    Status__c = 'Active,'
));

// Upsert to avoid duplicates if run multiple times
upsert sampleJobs External_Job_Id__c;

System.debug('Inserted/Updated ' + sampleJobs.size() + ' manual India jobs.');
