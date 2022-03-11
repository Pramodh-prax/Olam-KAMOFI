trigger SalesAreaTrigger on Sales_Area__c (before insert, after insert) {
    new SalesAreaTriggerHandler().Handle();
}