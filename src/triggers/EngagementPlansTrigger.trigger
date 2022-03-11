trigger EngagementPlansTrigger on Engagement_Plan__c (before insert, before update, after insert) {
    Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    if(vietnamUsers){
        
    }else{
        new EngagementPlansTriggerHandler().Handle();
    }
}