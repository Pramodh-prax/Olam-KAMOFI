trigger AccessSetTrigger on Access_Set__c (before insert) {
    new AccessSetTriggerHandler().Handle();
}