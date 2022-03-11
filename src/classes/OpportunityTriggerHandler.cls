public class OpportunityTriggerHandler extends TriggerHandlerBase {
    Boolean hasCustomPermission = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    public override void handleAfterInsert() {
        //Commented by Bharatesh as part of OFI
        //new OlamObjectSharing('Opportunity', Trigger.new).addSharing();
        //
        //Added by Deepankar as part of Vietnam Tendering
    	if(hasCustomPermission){
            OpportunityTriggerHelperVietnam.afterInsert(Trigger.new);
        }else{
            //Added by Bharatesh as part of OFI
        	SharingObjectRecordsHandler.shareOpportunitiesWithAccountTeams((Map<Id,Opportunity>)Trigger.newMap);
        	OpportunityVolumeRollUpService.getInstance().processClosedOpportunities((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.newMap, null);
        
        }
    }
    
    
    //Added by Deepankar
    public override void handleBeforeInsert()
    {
        if(hasCustomPermission){
        	OpportunityTriggerHelperVietnam.beforeInsert(Trigger.new);
        }
    }
    
    public override void handleAfterUpdate() {

        //Added by Deepankar as part of Vietnam Tendering
        if(hasCustomPermission){
            OpportunityTriggerHelperVietnam.afterUpdate((List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
        }else{
            OpportunityTriggerHelper.updateOpprtunityLineItem((List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
            OpportunityVolumeRollUpService.getInstance().processClosedOpportunities((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.newMap, (Map<Id, Opportunity>)Trigger.oldMap);
        }
    }
    
    
    public override void handleBeforeUpdate(){
        
        //Added by Deepankar as part of Vietnam Tendering
        if(hasCustomPermission){
            OpportunityTriggerHelperVietnam.beforeUpdate((List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
        }else{
            OpportunityTriggerHandler.updateCloseDate((List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
        	OpportunityTriggerHelper.checkOpportunityStatusWithLatestQuoteStatus((List<Opportunity>)trigger.new, (Map<Id, Opportunity>)trigger.oldMap);
        
        }
    }
    
    
    public static void updateCloseDate(List<Opportunity> oppList,Map<Id,Opportunity> oldMapOfOpp){        
        for(Opportunity oppObj : oppList){
            if(oldMapOfOpp.get(oppObj.Id).IsClosed != true && oppObj.IsClosed == true){
                oppObj.CloseDate = system.today();
            }
        }
    }
}