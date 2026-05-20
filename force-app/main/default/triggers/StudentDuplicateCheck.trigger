trigger StudentDuplicateCheck on Student__c(before insert) {
  // Step 1: Naye students ki emails collect karo
  Set<String> newEmails = new Set<String>();

  for (Student__c s : Trigger.new) {
    if (s.Email__c != null) {
      newEmails.add(s.Email__c.toLowerCase());
    }
  }

  // Step 2: Database mein check karo same email hai kya
  List<Student__c> existingStudents = [
    SELECT Id, Email__c
    FROM Student__c
    WHERE Email__c IN :newEmails
  ];

  // Step 3: Existing emails ka set banao
  Set<String> existingEmails = new Set<String>();
  for (Student__c es : existingStudents) {
    existingEmails.add(es.Email__c.toLowerCase());
  }

  // Step 4: Naye record pe check lagao
  for (Student__c s : Trigger.new) {
    if (
      s.Email__c != null && existingEmails.contains(s.Email__c.toLowerCase())
    ) {
      s.Email__c.addError(
        'Yeh email already register hai! Ek email se ek hi student ho sakta hai.'
      );
    }
  }
}
