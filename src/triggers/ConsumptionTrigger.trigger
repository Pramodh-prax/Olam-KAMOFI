trigger ConsumptionTrigger on Consumption__c (before insert, before update, after insert) {//, after insert, after update, after delete
   
   Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    if(vietnamUsers){
        
    }else{
        new ConsumptionTriggerHandler().Handle();
    }
}