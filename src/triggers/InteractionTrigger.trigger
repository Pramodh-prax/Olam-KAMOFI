trigger InteractionTrigger on Interactions__c (before insert, before Update, after insert, after update, after delete) {
    Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    
    if(vietnamUsers){
        
    }else{
        new InteractionTriggerHandler().Handle();
    }
}