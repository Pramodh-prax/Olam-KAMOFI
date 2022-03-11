public class TeamsTriggerHandler extends TriggerHandlerBase {
    
    public override void handleBeforeInsert() { 
        
        TeamsTriggerHelper.checkForValidations((List<Teams__c>)Trigger.new,new Map<Id,Teams__c>(), true);
        
        TeamsTriggerHelper.updateTeamMemberAccessDetails((List<Teams__c>)Trigger.new,NULL);
        
        TeamsTriggerHelper.currentMemberAdditionValidationOFI(Trigger.new);
     
    }
    public override void handleBeforeUpdate() { 
        
        TeamsTriggerHelper.checkForValidations((List<Teams__c>)Trigger.new,(Map<Id,Teams__c>)Trigger.oldMap, false);
       
        TeamsTriggerHelper.updateTeamMemberAccessDetails((List<Teams__c>)Trigger.new,(Map<Id,Teams__c>)Trigger.oldMap);
        
        TeamsTriggerHelper.currentMemberAdditionValidationOFI(Trigger.new);
    }
    
}