trigger TeamsTrigger on Teams__c (before insert,after insert, after update,before update, after delete,before delete) {
    Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    
    if(!vietnamUsers && !CreateAccountTeamsEvtTriggerHandler.isSchedulerTeamInsert){
    	new TeamsTriggerHandler().Handle();
    }
    
}