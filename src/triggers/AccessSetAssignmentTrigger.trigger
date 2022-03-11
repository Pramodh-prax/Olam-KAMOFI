trigger AccessSetAssignmentTrigger on Access_Set_Assignment__c (before insert) {
    new AccessSetAssignmentTriggerHandler().Handle();
}