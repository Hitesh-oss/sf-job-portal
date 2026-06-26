public class JobWrapper {
  @AuraEnabled
  public String id { get; set; }
  @AuraEnabled
  public String jobTitle { get; set; }
  @AuraEnabled
  public String companyName { get; set; }
  @AuraEnabled
  public String location { get; set; }
  @AuraEnabled
  public String salary { get; set; }
  @AuraEnabled
  public String applyLink { get; set; }
  @AuraEnabled
  public String jobType { get; set; }
  @AuraEnabled
  public String description { get; set; }
  @AuraEnabled
  public String postedDate { get; set; }
  @AuraEnabled
  public String requiredSkills { get; set; }
  @AuraEnabled
  public Boolean isNew { get; set; }
}
