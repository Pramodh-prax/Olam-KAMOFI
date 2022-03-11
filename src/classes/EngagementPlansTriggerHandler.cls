public class EngagementPlansTriggerHandler extends TriggerHandlerBase{
    public override void handleAfterInsert() {
        
        //Added by Bharatesh as part of OFI
        SharingObjectRecordsHandler.shareEngPlansWithAccountTeams((Map<Id,Engagement_Plan__c>)Trigger.newMap);
    }
    //Pramodh Added for user Access check
    public override void handleBeforeInsert(){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if( hasCustomPermission){
            
        }else{
            EngagementPlansTriggerHandler.userPrivilageCheck((List<Engagement_Plan__c>)Trigger.New);
        }
    }
    public override void handleBeforeUpdate(){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if( hasCustomPermission){
            
        }else{
            EngagementPlansTriggerHandler.userPrivilageCheck((List<Engagement_Plan__c>)Trigger.New);
        }
    }
    public static void userPrivilageCheck(List<Engagement_Plan__c> listOfEngagementPlans ){
        set<Id> setOfAccountIds = new Set<Id>();
        Map<Id,Map<Id,String>> mapOfAccIdWithMapOfUserBus = new Map<Id,Map<Id,String>>();
        for(Engagement_Plan__c tempEngagementPlan : listOfEngagementPlans){
            setOfAccountIds.add(tempEngagementPlan.Account__c);
        }
        mapOfAccIdWithMapOfUserBus = SharingUtility.getAccountTeamsUserBUs(setOfAccountIds);
        for(Engagement_Plan__c tempEngagementPlan : listOfEngagementPlans){
            boolean error = false;
            If(mapOfAccIdWithMapOfUserBus.containsKey(tempEngagementPlan.Account__c)){
                If(mapOfAccIdWithMapOfUserBus.get(tempEngagementPlan.Account__c).ContainsKey(userInfo.getUserId()) ){
                    If(mapOfAccIdWithMapOfUserBus.get(tempEngagementPlan.Account__c).get(userInfo.getUserId()) == tempEngagementPlan.Business_Unit__c ||
                       mapOfAccIdWithMapOfUserBus.get(tempEngagementPlan.Account__c).get(userInfo.getUserId()) == 'All'){
                           
                       }else{
                           error = true;
                       }
                }else{
                    error = true;
                }
            }else{
                error = true;
            }
            if(error){
                tempEngagementPlan.addError('You do not have enough permission to create/update this record');
            }
        }
    }
}