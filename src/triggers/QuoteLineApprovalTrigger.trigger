trigger QuoteLineApprovalTrigger on Quote_Line_Approval__c (after insert,after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        QuoteLineApprovalTriggerHandler.onAfterInsert(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        QuoteLineApprovalTriggerHandler.onAfterUpdate(Trigger.new,Trigger.oldMap);
    }
}