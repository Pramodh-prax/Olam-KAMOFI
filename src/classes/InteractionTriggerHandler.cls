public class InteractionTriggerHandler extends TriggerHandlerBase {

    public override void handleAfterInsert() {
        //Commented by Bharatesh as part of OFI
        //new OlamObjectSharing('Interactions__c', Trigger.new).addSharing();
        
        //Added by Bharatesh as part of OFI
        SharingObjectRecordsHandler.shareInteractionsWithAccountTeams((Map<Id,Interactions__c>)Trigger.newMap);
	}
    public override void handleBeforeInsert(){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(hasCustomPermission){
        }
        else{
        	InteractionTriggerHandler.userPrivilageCheck((List<Interactions__c>)Trigger.New);
        }
    }
    public override void handleBeforeUpdate(){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(hasCustomPermission){
        }
        else{
        	InteractionTriggerHandler.userPrivilageCheck((List<Interactions__c>)Trigger.New);
        }
    }
    public static void userPrivilageCheck(List<Interactions__c> listOfNewInteractions ){
        set<Id> setOfAccountIds = new Set<Id>();
        Map<Id,Map<Id,String>> mapOfAccIdWithMapOfUserBus = new Map<Id,Map<Id,String>>();
        for(Interactions__c tempInteraction : listOfNewInteractions){
            setOfAccountIds.add(tempInteraction.Account__c);
        }
        mapOfAccIdWithMapOfUserBus = SharingUtility.getAccountTeamsUserBUs(setOfAccountIds);
        system.debug('mapOfAccIdWithMapOfUserBus '+mapOfAccIdWithMapOfUserBus);
        for(Interactions__c tempInteraction : listOfNewInteractions){
            boolean error = false;
            If(mapOfAccIdWithMapOfUserBus.containsKey(tempInteraction.Account__c)){
                If(mapOfAccIdWithMapOfUserBus.get(tempInteraction.Account__c).ContainsKey(userInfo.getUserId()) ){
                    If(mapOfAccIdWithMapOfUserBus.get(tempInteraction.Account__c).get(userInfo.getUserId()) == tempInteraction.Business_Unit__c ||
                       mapOfAccIdWithMapOfUserBus.get(tempInteraction.Account__c).get(userInfo.getUserId()) == 'All'){
                        
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
                tempInteraction.addError('You do not have enough permission to create/update this record');
            }
        }
    }
}