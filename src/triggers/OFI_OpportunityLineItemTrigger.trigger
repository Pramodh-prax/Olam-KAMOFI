trigger OFI_OpportunityLineItemTrigger on OpportunityLineItem (before insert,before update,Before delete,after insert,after update) {

    Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
         
        if(trigger.isbefore && trigger.isinsert){
            if(!vietnamUsers && userInfo.getName() != System.Label.Automated_Process){
                OFI_OpportunityLineItemHandler.checkUserAccessForInsert((List<OpportunityLineItem>)trigger.new);}
            
        }
        if(trigger.isbefore && trigger.isupdate){
            if(!vietnamUsers && userInfo.getName() != System.Label.Automated_Process){
                OFI_OpportunityLineItemHandler.checkUserAccessForUpdate((List<OpportunityLineItem>)trigger.new,(Map<Id, OpportunityLineItem>)Trigger.newMap,(Map<Id, OpportunityLineItem>)Trigger.oldMap);
            }
        }   
    
    
}