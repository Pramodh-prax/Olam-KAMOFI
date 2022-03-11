trigger SampleRequestLineItemTrigger on Sample_Request_Line_Item__c (after insert,after update, before update) 
{
    
    if(Trigger.isAfter)
    {      
        if(Trigger.isInsert)
        {
             SampleRequestLineItemHandler.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate)
        {
             SampleRequestLineItemHandler.afterUpdate(Trigger.new,trigger.oldmap);
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        SampleRequestLineItemHandler.beforeUpdate(Trigger.new,trigger.oldmap);
    }
    
}