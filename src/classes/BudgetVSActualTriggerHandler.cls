public class BudgetVSActualTriggerHandler extends TriggerHandlerBase{
    public override void handleAfterInsert() {
        
        //Added by Bharatesh as part of OFI
        SharingObjectRecordsHandler.shareBudgetsWithAccountTeams((Map<Id,Budget_vs_Actuals__c>)Trigger.newMap);
    }
    //Pramodh Added for user Access check
    public override void handleBeforeInsert(){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if( hasCustomPermission){
            
        }else{
            BudgetVSActualTriggerHandler.userPrivilageCheck((List<Budget_vs_Actuals__c>)Trigger.New);
        }
    }
    public override void handleBeforeUpdate(){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if( hasCustomPermission){
            
        }else{
            BudgetVSActualTriggerHandler.userPrivilageCheck((List<Budget_vs_Actuals__c>)Trigger.New);
        }
    }
    public static void userPrivilageCheck(List<Budget_vs_Actuals__c> listOfNewBudgetActuals ){
        set<Id> setOfAccountIds = new Set<Id>();
        Map<Id,Map<Id,String>> mapOfAccIdWithMapOfUserBus = new Map<Id,Map<Id,String>>();
        for(Budget_vs_Actuals__c tempBudgetActual : listOfNewBudgetActuals){
            setOfAccountIds.add(tempBudgetActual.Account__c);
        }
        mapOfAccIdWithMapOfUserBus = SharingUtility.getAccountTeamsUserBUs(setOfAccountIds);
        for(Budget_vs_Actuals__c tempBudgetActual : listOfNewBudgetActuals){
            boolean error = false;
            system.debug('tempBudgetActual.Business_Unit__c '+tempBudgetActual.Business_Unit__c);
            If(mapOfAccIdWithMapOfUserBus.containsKey(tempBudgetActual.Account__c)){
                If(mapOfAccIdWithMapOfUserBus.get(tempBudgetActual.Account__c).ContainsKey(userInfo.getUserId()) ){
                    If(mapOfAccIdWithMapOfUserBus.get(tempBudgetActual.Account__c).get(userInfo.getUserId()) == tempBudgetActual.Business_Unit__c ||
                       mapOfAccIdWithMapOfUserBus.get(tempBudgetActual.Account__c).get(userInfo.getUserId()) == 'All'){
                           
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
                tempBudgetActual.addError('You do not have enough permission to create/update this record');
            }
        }
    }
}