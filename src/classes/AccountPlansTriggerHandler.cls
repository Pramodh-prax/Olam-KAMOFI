public class AccountPlansTriggerHandler extends TriggerHandlerBase{
    public override void handleAfterInsert() {
        
        //Added by Bharatesh as part of OFI
        SharingObjectRecordsHandler.shareAccountPlansWithAccountTeams((Map<Id,Account_Plans__c>)Trigger.newMap);
    }
    //Pramodh Added for user Access check
    public override void handleBeforeInsert(){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if( hasCustomPermission){
            
        }else{
            AccountPlansTriggerHandler.userPrivilageCheck((List<Account_Plans__c>)Trigger.New);
        }
    }
    public override void handleBeforeUpdate(){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if( hasCustomPermission){
            
        }else{
            AccountPlansTriggerHandler.userPrivilageCheck((List<Account_Plans__c>)Trigger.New);
        }
    }
    public static void userPrivilageCheck(List<Account_Plans__c> listOfAccountPlans ){
        set<Id> setOfAccountIds = new Set<Id>();
        Map<Id,Map<Id,String>> mapOfAccIdWithMapOfUserBus = new Map<Id,Map<Id,String>>();
        for(Account_Plans__c tempAccountPlan : listOfAccountPlans){
            setOfAccountIds.add(tempAccountPlan.Account__c);
        }
        mapOfAccIdWithMapOfUserBus = SharingUtility.getAccountTeamsUserBUs(setOfAccountIds);
        for(Account_Plans__c tempAccountPlan : listOfAccountPlans){
            boolean error = false;
            If(mapOfAccIdWithMapOfUserBus.containsKey(tempAccountPlan.Account__c)){
                If(mapOfAccIdWithMapOfUserBus.get(tempAccountPlan.Account__c).ContainsKey(userInfo.getUserId()) ){
                    If(mapOfAccIdWithMapOfUserBus.get(tempAccountPlan.Account__c).get(userInfo.getUserId()) == tempAccountPlan.BU_Identifier__c ||
                       mapOfAccIdWithMapOfUserBus.get(tempAccountPlan.Account__c).get(userInfo.getUserId()) == 'All'){
                           
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
                tempAccountPlan.addError('You do not have enough permission to create/update this record');
            }
        }
    }
}