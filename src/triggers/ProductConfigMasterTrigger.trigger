trigger ProductConfigMasterTrigger on ProductConfigMaster__c (before insert, before update,after insert, after update,after Delete) {
    new ProductConfigMasterTriggerHandler().Handle();
}