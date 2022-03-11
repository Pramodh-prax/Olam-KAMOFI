trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert,before insert,after update, before delete){
    /*if(Trigger.isAfter && Trigger.isInsert){
        OpportunityLineItemTriggerHandler.handleAfterInsert(Trigger.new);
    }*/
    new OpportunityLineItemTriggerHandler().Handle();
}