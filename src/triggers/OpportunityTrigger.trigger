trigger OpportunityTrigger on Opportunity (before insert,after insert, after update, after delete,before update) {
    new OpportunityTriggerHandler().Handle();
}