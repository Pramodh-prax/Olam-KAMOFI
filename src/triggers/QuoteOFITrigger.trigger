trigger QuoteOFITrigger on Quote (before insert,before update) {

    if(trigger.isbefore && trigger.isinsert){
        Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(!vietnamUsers && !hasCustomPermission && userInfo.getName() != System.Label.Automated_Process){
            QuoteOFITriggerHandler.checkUserAccess((List<Quote>)trigger.new);
        }
        
    }
    if(trigger.isbefore && trigger.isupdate){
        Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(!vietnamUsers && !hasCustomPermission && userInfo.getName() != System.Label.Automated_Process){
            QuoteOFITriggerHandler.checkUserAccessForUpdate((List<Quote>)trigger.new,  (Map<Id, Quote>)Trigger.oldMap);
        }
        
    }   
    
}