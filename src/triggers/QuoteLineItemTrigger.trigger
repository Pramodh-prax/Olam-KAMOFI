trigger QuoteLineItemTrigger on QuoteLineItem (after insert,after update,before delete, after delete) {
	
    if(Trigger.isAfter) 
        {
            if(Trigger.isDelete)
            {
                QuoteLineItemTriggerHandler.afterDelete(Trigger.Old);
            }
        }
    new QuoteLineItemTriggerHandler().Handle();
}