public class SampleRequestLineItemHandler 
{
    public static boolean isInitiatedFromSampleRequest = false;
    
    
    public static void afterInsert(List<Sample_Request_Line_Item__c> SampleRequestLineItemList){
        SampleRequestLineItemHelper.publishPlatformEvent(SampleRequestLineItemList);
    }
    
    
    public static void beforeUpdate(List<Sample_Request_Line_Item__c> SampleRequestList,Map<id,Sample_Request_Line_Item__c> oldSampleReqsMap){
        setIntegrationStatusOnStatusChange(SampleRequestList, oldSampleReqsMap);
        setIntegrationStatusQuantityChange(SampleRequestList, oldSampleReqsMap);
    }
    
	
	 public static void afterUpdate(List<Sample_Request_Line_Item__c> SampleRequestList,Map<id,Sample_Request_Line_Item__c> oldSampleReqsMap){
        if(OpportunityProductTriggerHelper.isIniatedFromOpportunityProduct == false){
            SampleRequestLineItemHandler.updateOppoLineOnOssmChanges(SampleRequestList,oldSampleReqsMap);
        }
         
        
        SampleRequestLineItemHelper.publishPlatformEventOnFeedback(SampleRequestList,oldSampleReqsMap);
        
        sendRequestOnAmmendment(SampleRequestList,oldSampleReqsMap);
        
    }

    
    public static void setIntegrationStatusOnStatusChange(List<Sample_Request_Line_Item__c> SampleRequestList,Map<id,Sample_Request_Line_Item__c> oldSampleReqsMap){
        Set<String> feedbackStatus = new Set<String>{'7', '8', '9', '10', '12', '13', '14', '16'};
        
        for(Sample_Request_Line_Item__c srLine :SampleRequestList){
            if(srLine.Sampling_Status__c != oldSampleReqsMap.get(srLine.Id).Sampling_Status__c && feedbackStatus.contains(srLine.Sampling_Status__c)){
                srLine.Integration_Status__c = 'feedback_update';
            }
        }
    }
    
    
    public static void setIntegrationStatusQuantityChange(List<Sample_Request_Line_Item__c> SampleRequestList,Map<id,Sample_Request_Line_Item__c> oldSampleReqsMap){
        for(Sample_Request_Line_Item__c srLine :SampleRequestList){
            if(srLine.SAP_Line_Item_Id__c != null && (srLine.Quantity__c != oldSampleReqsMap.get(srLine.Id).Quantity__c || srLine.Unit_of_measure__c != oldSampleReqsMap.get(srLine.Id).Unit_of_measure__c)){
                srLine.Integration_Status__c = 'amendment';
            }
        }
    }
  
     
   
    
    
    public static void sendRequestOnAmmendment(List<Sample_Request_Line_Item__c> SampleRequestList,Map<id,Sample_Request_Line_Item__c> oldSampleReqsMap){
        Set<String> sampleRequestIdSet = new Set<String>();
        
        for(Sample_Request_Line_Item__c srLine :SampleRequestList){
            if(srLine.Integration_Status__c != oldSampleReqsMap.get(srLine.Id).Integration_Status__c && srLine.Integration_Status__c == 'amendment'){
                sampleRequestIdSet.add(srLine.Sample_Request__c);
            }
        }
        
        List<SampleRequest__e> sreqEvtList = new List<SampleRequest__e>();
        for(id srid : sampleRequestIdSet){
            sreqEvtList.add(new SampleRequest__e(SampleRequestId__c=srid));     
        }
        
        SampleRequestLineItemHelper.publishPlatformEventsForSampleRequest(sreqEvtList);
    }
    
    //This method updates the sampling_status_c, Tracking_Number__c and Development_Code__c in OpportunityLineItem and Product__c respectively
    //based on the values updated in SampleRequestLineItem by Cloud Integration Tool
    //Joel Tom   
    public static void updateOppoLineOnOssmChanges(List<Sample_Request_Line_Item__c> SampleRequestList,Map<id,Sample_Request_Line_Item__c> oldSampleReqsMap){
        Map<Id,Sample_Request_Line_Item__c> SRLineMapToUpdateOppProdct = new Map<Id,Sample_Request_Line_Item__c>();
        Map<Id,Sample_Request_Line_Item__c> SRLineMapToUpdateProdct = new Map<Id,Sample_Request_Line_Item__c>();
        
        for(Sample_Request_Line_Item__c srlin:SampleRequestList)
        {
            if(srlin.Sampling_Status__c != oldSampleReqsMap.get(srlin.id).Sampling_Status__c 
               || srlin.Tracking_Number__c != oldSampleReqsMap.get(srlin.id).Tracking_Number__c
               || srlin.Integration_Status__c != oldSampleReqsMap.get(srlin.id).Integration_Status__c //newly added
               || srlin.Quantity_Dispatched__c != oldSampleReqsMap.get(srlin.id).Quantity_Dispatched__c //new added
            ){                   
                   SRLineMapToUpdateOppProdct.put(srlin.Opportunity_Product__c,srlin);               
            }
            if(srlin.Development_Code__c != oldSampleReqsMap.get(srlin.id).Development_Code__c ){
                SRLineMapToUpdateProdct.put(srlin.Product__c,srlin);
            }
            
        }      
        
        Map<Id,OpportunityLineItem> OppLineItemMap = new Map<Id,OpportunityLineItem> ([SELECT id,Quantity_Dispatched__c,Tracking_Number__c,Integration_Status__c,Sampling_Status__c  FROM OpportunityLineItem WHERE Id IN :SRLineMapToUpdateOppProdct.keySet()]); 
        Map<Id, Product2> Product2Map = new Map<Id,Product2> ([SELECT id,Development_Code__c FROM Product2 WHERE Id IN :SRLineMapToUpdateProdct.keyset()]); 
        List<OpportunityLineItem > OpportunityItemsToUpdate = new List<OpportunityLineItem >();
        List<Product2> Product2ToUpdate = new List<Product2>();
   
        for(Sample_Request_Line_Item__c srlin : SampleRequestList){
            if(srlin.Sampling_Status__c != oldSampleReqsMap.get(srlin.id).Sampling_Status__c 
               || srlin.Tracking_Number__c != oldSampleReqsMap.get(srlin.id).Tracking_Number__c
               || srlin.Integration_Status__c != oldSampleReqsMap.get(srlin.id).Integration_Status__c //newly added
               ||  srlin.Quantity_Dispatched__c != oldSampleReqsMap.get(srlin.id).Quantity_Dispatched__c //newly added
            ){
                if(OppLineItemMap.containsKey(srlin.Opportunity_Product__c)){
                    OpportunityItemsToUpdate.add(new OpportunityLineItem(id = srlin.Opportunity_Product__c,Quantity_Dispatched__c=srlin.Quantity_Dispatched__c,Integration_Status__c=srlin.Integration_Status__c,Sampling_Status__c = srlin.Sampling_Status__c, Tracking_Number__c = srlin.Tracking_Number__c));
                }
            }
            
            if(srlin.Development_Code__c != oldSampleReqsMap.get(srlin.id).Development_Code__c){
                if(Product2Map.containsKey(srlin.Product__c)){
                    Product2ToUpdate.add(new Product2(id = srlin.Product__c,Development_Code__c = srlin.Development_Code__c));
                }
            }    
        }
        
        isInitiatedFromSampleRequest = true;
        
        if(Product2ToUpdate != null && Product2ToUpdate.size() > 0)
        {
            update Product2ToUpdate;
        }
        if(OpportunityItemsToUpdate != null && OpportunityItemsToUpdate.size() > 0)
        {
            update OpportunityItemsToUpdate;
        }   
        
    }
    
}