public class AccountTriggerHandler extends TriggerHandlerBase {

    public override void handleBeforeInsert() {
       AccountRegionUpdate.RegionUpdate((List<account>)Trigger.new);
       //Added by Bharatesh - Replacing Ashwini's fnctionality in AccountTriggerHanlder.beforeInsert
       AccountRegionUpdate.setOwnerToIntegrationUser((List<account>)Trigger.new);
    }
    
    
    public override void handleBeforeUpdate(){
        AccountRegionUpdate.RegionUpdate((List<account>)Trigger.new);
    }


}