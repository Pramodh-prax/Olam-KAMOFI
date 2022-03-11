public class OpportunityProductTriggerHandler {

    public static void beforeUpdate(Map<Id,OpportunityLineItem> oppLineItemOldMap,List<OpportunityLineItem> oppLineItemList){
        OpportunityProductTriggerHelper.throwErrorForFileUpload(oppLineItemOldMap,oppLineItemList);
    }
    
    
    public static void afterInsert(List<OpportunityLineItem> oppLineItemList){
        OpportunityProductTriggerHelper.updateProductNameOnOpportunity(oppLineItemList);
    }
       
    
    public static void afterUpdate(Map<Id,OpportunityLineItem> oppLineItemOldMap,List<OpportunityLineItem> oppLineItemList,List<OpportunityLineItem> oldList){
		
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
        System.debug('Checked In');
   		if(hasCustomPermission)
    	{
            System.debug('Checked In 1');
       		Vietnam_OpportunityProductTriggerHelper.OpportunityProductHistoryUpdate(oldList);
    	}
        else
        { 
            if(SampleRequestLineItemHandler.isInitiatedFromSampleRequest == false){
             OpportunityProductTriggerHelper.UpdateSampleRequestLineItem(oppLineItemOldMap,oppLineItemList); 
       	 	}
        
        	OpportunityProductTriggerHelper.captureFieldChangeHistory(oppLineItemOldMap,oppLineItemList);
        	OpportunityProductTriggerHelper.handleOpportunityLogUpdates(oppLineItemList, oppLineItemOldMap);
        }
    }
    
}