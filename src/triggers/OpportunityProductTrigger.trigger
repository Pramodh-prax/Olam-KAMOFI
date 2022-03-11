trigger OpportunityProductTrigger on OpportunityLineItem (before insert, before update, after insert, after update) {
    Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    
     if(Trigger.isBefore){
        if(Trigger.isupdate){
            OpportunityProductTriggerHandler.beforeUpdate(trigger.oldmap,trigger.new);
        }
         
         if(Trigger.isInsert){
             //OpportunityProductTriggerHandler.beforeInsert(Trigger.new);
         }
    }
    
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OpportunityProductTriggerHandler.afterInsert(trigger.new);
        }
        if(Trigger.isUpdate){
           System.debug('Opp Product Trigger'); 
           OpportunityProductTriggerHandler.afterUpdate(trigger.oldmap,trigger.new,trigger.old);   
        }        
    }
    

    
}