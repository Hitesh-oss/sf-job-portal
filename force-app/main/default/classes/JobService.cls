public with sharing class JobService {
  public static List<JobWrapper> fetchJobs(
    String query,
    String location,
    String type
  ) {
    List<JobWrapper> normalizedJobs = new List<JobWrapper>();

    // 1. Try JSearch API (Primary)
    try {
      normalizedJobs = callJSearchAPI(query, location, type);
      if (normalizedJobs != null && !normalizedJobs.isEmpty()) {
        System.debug('Successfully fetched jobs from JSearch API.');
        return normalizedJobs;
      }
    } catch (Exception e) {
      System.debug(
        'JSearch API failed: ' + e.getMessage() + '\n' + e.getStackTraceString()
      );
    }

    // 2. Fallback to Adzuna API (Backup)
    try {
      System.debug('Attempting fallback to Adzuna API...');
      normalizedJobs = callAdzunaAPI(query, location, type);
      if (normalizedJobs != null && !normalizedJobs.isEmpty()) {
        System.debug('Successfully fetched jobs from Adzuna API.');
        return normalizedJobs;
      }
    } catch (Exception e) {
      System.debug(
        'Adzuna API failed: ' + e.getMessage() + '\n' + e.getStackTraceString()
      );
    }

    return normalizedJobs;
  }

  private static List<JobWrapper> callJSearchAPI(
    String query,
    String location,
    String type
  ) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();

    // Build search query
    String fullQuery = query;
    if (String.isNotBlank(location)) {
      fullQuery += ' in ' + location;
    }
    if (String.isNotBlank(type)) {
      fullQuery += ' ' + type;
    }

    String encodedQuery = EncodingUtil.urlEncode(fullQuery, 'UTF-8');
    request.setEndpoint(
      'callout:JSearch_API/search?query=' + encodedQuery + '&page=1&num_pages=1'
    );
    request.setMethod('GET');
    request.setHeader('x-rapidapi-key', '{!$Credential.Password}');
    request.setHeader('x-rapidapi-host', 'jsearch.p.rapidapi.com');
    request.setHeader('Accept', 'application/json');
    request.setTimeout(10000); // 10 seconds timeout

    HttpResponse response = http.send(request);

    if (response.getStatusCode() != 200) {
      throw new CalloutException(
        'JSearch API returned status code ' +
          response.getStatusCode() +
          ': ' +
          response.getStatus()
      );
    }

    String body = response.getBody();
    if (String.isBlank(body)) {
      return new List<JobWrapper>();
    }

    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    List<Object> dataList = (List<Object>) results.get('data');
    if (dataList == null) {
      return new List<JobWrapper>();
    }

    List<JobWrapper> jobs = new List<JobWrapper>();
    for (Object item : dataList) {
      Map<String, Object> jobMap = (Map<String, Object>) item;
      JobWrapper j = new JobWrapper();
      j.id = (String) jobMap.get('job_id');
      j.jobTitle = (String) jobMap.get('job_title');
      j.companyName = (String) jobMap.get('employer_name');

      // Normalize Location
      String city = (String) jobMap.get('job_city');
      String state = (String) jobMap.get('job_state');
      String country = (String) jobMap.get('job_country');
      List<String> locParts = new List<String>();
      if (String.isNotBlank(city))
        locParts.add(city);
      if (String.isNotBlank(state))
        locParts.add(state);
      if (String.isNotBlank(country))
        locParts.add(country);
      j.location = locParts.isEmpty() ? 'Remote' : String.join(locParts, ', ');

      // Normalize Salary
      Object minSal = jobMap.get('job_min_salary');
      Object maxSal = jobMap.get('job_max_salary');
      String currencyCode = (String) jobMap.get('job_salary_currency');
      if (minSal != null && maxSal != null) {
        j.salary = currencyCode + ' ' + minSal + ' - ' + maxSal;
      } else if (minSal != null) {
        j.salary = currencyCode + ' ' + minSal + '+';
      } else {
        j.salary = 'Not disclosed';
      }

      j.applyLink = (String) jobMap.get('job_apply_link');

      // Normalize Job Type
      String empType = (String) jobMap.get('job_employment_type');
      if (String.isNotBlank(empType)) {
        j.jobType = empType.capitalize();
      } else {
        j.jobType = 'Full-time';
      }

      j.description = (String) jobMap.get('job_description');
      if (String.isNotBlank(j.description) && j.description.length() > 300) {
        j.description = j.description.substring(0, 297) + '...';
      }

      j.postedDate = (String) jobMap.get('job_posted_at_datetime_utc');
      if (String.isNotBlank(j.postedDate)) {
        j.postedDate = j.postedDate.substring(0, 10);
      } else {
        j.postedDate = String.valueOf(System.today());
      }

      j.requiredSkills = 'N/A';
      j.isNew = true;

      jobs.add(j);
    }

    return jobs;
  }

  private static List<JobWrapper> callAdzunaAPI(
    String query,
    String location,
    String type
  ) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();

    // Build Adzuna URL
    // Adzuna API format: /v1/api/jobs/in/search/1?app_id={!$Credential.Username}&app_key={!$Credential.Password}&what=software+developer&where=India
    String countryCode = 'in'; // Default country
    String searchWhat = EncodingUtil.urlEncode(query, 'UTF-8');
    String searchWhere = String.isNotBlank(location)
      ? EncodingUtil.urlEncode(location, 'UTF-8')
      : '';

    String endpoint =
      'callout:Adzuna_API/v1/api/jobs/' +
      countryCode +
      '/search/1?content-type=application/json';
    endpoint += '&app_id={!$Credential.Username}&app_key={!$Credential.Password}';
    endpoint += '&what=' + searchWhat;
    if (String.isNotBlank(searchWhere)) {
      endpoint += '&where=' + searchWhere;
    }

    request.setEndpoint(endpoint);
    request.setMethod('GET');
    request.setHeader('Accept', 'application/json');
    request.setTimeout(10000); // 10 seconds timeout

    HttpResponse response = http.send(request);

    if (response.getStatusCode() != 200) {
      throw new CalloutException(
        'Adzuna API returned status code ' +
          response.getStatusCode() +
          ': ' +
          response.getStatus()
      );
    }

    String body = response.getBody();
    if (String.isBlank(body)) {
      return new List<JobWrapper>();
    }

    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
      body
    );
    List<Object> resultsList = (List<Object>) results.get('results');
    if (resultsList == null) {
      return new List<JobWrapper>();
    }

    List<JobWrapper> jobs = new List<JobWrapper>();
    for (Object item : resultsList) {
      Map<String, Object> jobMap = (Map<String, Object>) item;
      JobWrapper j = new JobWrapper();
      j.id = String.valueOf(jobMap.get('id'));
      j.jobTitle = (String) jobMap.get('title');

      // Strip HTML/strong tags from title if any
      if (String.isNotBlank(j.jobTitle)) {
        j.jobTitle = j.jobTitle.replaceAll('<[^>]*>', '');
      }

      // Company Name
      Map<String, Object> companyMap = (Map<String, Object>) jobMap.get(
        'company'
      );
      if (companyMap != null) {
        j.companyName = (String) companyMap.get('display_name');
      }

      // Location
      Map<String, Object> locationMap = (Map<String, Object>) jobMap.get(
        'location'
      );
      if (locationMap != null) {
        j.location = (String) locationMap.get('display_name');
      } else {
        j.location = 'India';
      }

      // Salary
      Object minSal = jobMap.get('salary_min');
      Object maxSal = jobMap.get('salary_max');
      if (minSal != null && maxSal != null) {
        j.salary = 'INR ' + minSal + ' - ' + maxSal;
      } else if (minSal != null) {
        j.salary = 'INR ' + minSal + '+';
      } else {
        j.salary = 'Not disclosed';
      }

      j.applyLink = (String) jobMap.get('redirect_url');

      // Job Type
      String contractTime = (String) jobMap.get('contract_time'); // full_time or part_time
      if (String.isNotBlank(contractTime)) {
        j.jobType = contractTime.replace('_', '-').capitalize();
      } else {
        j.jobType = 'Full-time';
      }

      j.description = (String) jobMap.get('description');
      if (String.isNotBlank(j.description)) {
        j.description = j.description.replaceAll('<[^>]*>', '');
        if (j.description.length() > 300) {
          j.description = j.description.substring(0, 297) + '...';
        }
      }

      j.postedDate = (String) jobMap.get('created');
      if (String.isNotBlank(j.postedDate)) {
        j.postedDate = j.postedDate.substring(0, 10);
      } else {
        j.postedDate = String.valueOf(System.today());
      }

      j.requiredSkills = 'N/A';
      j.isNew = true;

      jobs.add(j);
    }

    return jobs;
  }
}
