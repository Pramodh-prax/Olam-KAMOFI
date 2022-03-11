trigger OFI_QuoteLineItemTrigger on QuoteLineItem (before insert,before update) {
    if(trigger.isbefore && trigger.isinsert){
        Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
        if(!vietnamUsers && userInfo.getName() != System.Label.Automated_Process){
            OFI_QuoteLinteItemHandler.checkUserAccessForInsert((List<QuoteLineItem>)trigger.new);
        }
        
    }
    if(trigger.isbefore && trigger.isupdate){
        Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
        if(!vietnamUsers && userInfo.getName() != System.Label.Automated_Process){
            OFI_QuoteLinteItemHandler.checkUserAccessForUpdate((List<QuoteLineItem>)trigger.new,(Map<Id, QuoteLineItem>)Trigger.newMap,(Map<Id, QuoteLineItem>)Trigger.oldMap);
        }
    }  
}