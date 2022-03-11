public class AccessSetTriggerHandler extends TriggerHandlerBase{
    public override void handleBeforeInsert() {
        AccessSetTriggerHelper.populateUniqueId((List<Access_Set__c>)trigger.new);
    }
}