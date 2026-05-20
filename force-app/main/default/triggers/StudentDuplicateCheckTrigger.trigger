trigger StudentDuplicateCheckTrigger on student2004__c(
  before insert,
  before update
) {
  Set<String> studentNames = new Set<String>();

  for (student2004__c s : Trigger.new) {
    if (s.Name != null) {
      studentNames.add(s.Name);
    }
  }

  Map<String, student2004__c> existingStudents = new Map<String, student2004__c>();

  for (student2004__c s : [
    SELECT Id, Name
    FROM student2004__c
    WHERE Name IN :studentNames
  ]) {
    existingStudents.put(s.Name, s);
  }

  for (student2004__c s : Trigger.new) {
    if (
      existingStudents.containsKey(s.Name) &&
      existingStudents.get(s.Name).Id != s.Id
    ) {
      s.addError('Duplicate student name not allowed!');
    }
  }
}
