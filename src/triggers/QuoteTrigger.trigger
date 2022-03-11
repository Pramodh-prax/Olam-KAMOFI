trigger QuoteTrigger on Quote (before insert,after insert, before update, after update) {
    
    Boolean vietnamUser= FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    
    if(vietnamUser)
    {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            Vietnam_QuoteTriggerHelper.BeforeInsert(Trigger.new);
            
        }
    }
    
    if(!vietnamUser)
    {
        
        if(Trigger.isAfter && Trigger.isInsert)
        {
            QuoteTriggerHandler.AfterInsert(Trigger.new);
            
        }      
    }
}