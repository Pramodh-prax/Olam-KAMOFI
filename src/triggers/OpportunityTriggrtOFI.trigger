trigger OpportunityTriggrtOFI on Opportunity (before insert,before update,After insert,After Update) {
    
    Id profileId=userinfo.getProfileId();
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    system.debug('ProfileName'+profileName);
    Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    
    if(vietnamUsers){
        if(trigger.isAfter && trigger.isinsert){
            //     OpportunityTriggerHelperVietnam.afterInsert(Trigger.new);
        }
        
        if(trigger.isbefore && trigger.isupdate){
            //  OpportunityTriggerHelperVietnam.beforeUpdate((List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
        }
        
        if(trigger.isAfter && trigger.isupdate){
            //   OpportunityTriggerHelperVietnam.afterUpdate((List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
        }
    }else{
        
        if(trigger.isbefore && trigger.isinsert){
            if(!vietnamUsers && userInfo.getName() != System.Label.Automated_Process){
                opportunityTriggerOfiUser.checkUserAccess((List<Opportunity>)trigger.new);
            }
            
        }
        if(trigger.isbefore && trigger.isupdate){
            if(!vietnamUsers && userInfo.getName() != System.Label.Automated_Process){
                opportunityTriggerOfiUser.checkUserAccessForUpdateOpp((List<Opportunity>)trigger.new,  (Map<Id, Opportunity>)Trigger.oldMap);
            }
            
        }   
    }
    
    
}