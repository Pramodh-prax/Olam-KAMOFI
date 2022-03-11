trigger AccountPlansTrigger on Account_Plans__c (before insert, before update, after insert) {
Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    if(vietnamUsers){
        
    }else{
        new AccountPlansTriggerHandler().Handle();
    }
}