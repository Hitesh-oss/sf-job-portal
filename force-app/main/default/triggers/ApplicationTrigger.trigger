trigger ApplicationTrigger on Application__c(before insert, before update) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      ApplicationTriggerHandler.handleBeforeInsert(Trigger.new);
    } else if (Trigger.isUpdate) {
      ApplicationTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
  }
}
