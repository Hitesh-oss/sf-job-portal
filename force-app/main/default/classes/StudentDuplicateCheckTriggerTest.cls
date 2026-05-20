@isTest
public class StudentDuplicateCheckTriggerTest {
  @isTest
  static void testDuplicateStudent() {
    // First record for Student__c
    Student__c s1 = new Student__c(
      Name = 'Test Student',
      Email__c = 'test@example.com'
    );
    insert s1;

    // Duplicate record for Student__c
    Student__c s2 = new Student__c(
      Name = 'Test Student 2',
      Email__c = 'test@example.com'
    );

    Test.startTest();
    try {
      insert s2;
      System.assert(false, 'Duplicate should not be allowed');
    } catch (DmlException e) {
      System.assert(
        e.getMessage()
          .contains(
            'Yeh email already register hai! Ek email se ek hi student ho sakta hai.'
          )
      );
    }

    // Record for student2004__c (includes Email__c to prevent flow error)
    student2004__c s3 = new student2004__c(
      Name = 'Test Student 2004',
      Email__c = 'test2004@example.com'
    );
    insert s3;

    // Duplicate record for student2004__c
    student2004__c s4 = new student2004__c(
      Name = 'Test Student 2004',
      Email__c = 'test2004_dup@example.com'
    );
    try {
      insert s4;
      System.assert(false, 'Duplicate should not be allowed');
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains('Duplicate student name not allowed!')
      );
    }
    Test.stopTest();
  }
}
