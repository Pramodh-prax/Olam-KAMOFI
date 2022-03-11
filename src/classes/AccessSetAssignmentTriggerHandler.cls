public class AccessSetAssignmentTriggerHandler extends TriggerHandlerBase{
    public override void handleBeforeInsert() {
        AccessSetAssignmentTriggerHelper.populateUniqueId((List<Access_Set_Assignment__c>)trigger.new);
    }
}