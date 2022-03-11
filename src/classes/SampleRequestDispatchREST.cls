@RestResource(urlMapping='/SampleRequestDispatch/*')
global with sharing class SampleRequestDispatchREST{
    public class CustomException extends Exception{}
    
    @HttpPost
    global static Boolean updateSampleRequest(List<SampleRequestLineItem> record) {
       
        System.debug('OSSM REQUEST -- '+JSON.serialize(record));
        try{
            Set<String> sapLineItemIdSet = new Set<String>();
            for(SampleRequestLineItem sampleLine :record){
                sapLineItemIdSet.add(sampleLine.sap_line_item_id);
            }
            
            Map<String, Sample_Request_Line_Item__c> sampleRequestLineMap = new Map<String, Sample_Request_Line_Item__c>();
            sampleRequestLineMap = getSampleRequestLineMap(record[0].sf_sample_request_id, sapLineItemIdSet);
            
            for(SampleRequestLineItem sampleLine :record){
                if(sampleRequestLineMap.containsKey(sampleLine.sap_line_item_id)){
                    Sample_Request_Line_Item__c srLine = sampleRequestLineMap.get(sampleLine.sap_line_item_id);
                    if(sampleLine.development_code != null) {srLine.Development_Code__c = sampleLine.development_code;}
                    if(sampleLine.quantity_of_sample != null) {srLine.Quantity_Dispatched__c = sampleLine.quantity_of_sample;}
                    if(sampleLine.sample_sent_status != null) {srLine.Sampling_Status__c = sampleLine.sample_sent_status;}
                    if(sampleLine.tracking_number != null) {srLine.Tracking_Number__c = sampleLine.tracking_number;}
                    if(sampleLine.modified_by != null) {srLine.Modified_By_Name__c = sampleLine.modified_by;}
                    if(sampleLine.created_by != null) {srLine.Created_By_Name__c = sampleLine.created_by;}
                    if(sampleLine.actual_hours != null) {srLine.Actual_Hours__c = srLine.Actual_Hours__c != null ? srLine.Actual_Hours__c + sampleLine.actual_hours : sampleLine.actual_hours;}
                    if(sampleLine.date_of_dispatch != null) {srLine.Date_of_Dispatch__c = sampleLine.date_of_dispatch;}
                }
                else{
                    throw new CustomException('Line item not found');
                }
            }
            
            update sampleRequestLineMap.values();
        }
        catch(Exception e){
            if(e.getMessage().contains('Development_Code__c duplicates')){
                throw new CustomException('Development code alreay exists.');
            }
            else{
                throw e;
            }
        }
        
        
        return true;
    }
    
    
    global static Map<String, Sample_Request_Line_Item__c> getSampleRequestLineMap(String sampleRequestId, Set<String> sapLineItemIdSet){
        Map<String, Sample_Request_Line_Item__c> sampleRequestLineMap = new Map<String, Sample_Request_Line_Item__c>();
        
        for(Sample_Request_Line_Item__c srLine :[SELECT Id, SAP_Line_Item_Id__c, Actual_Hours__c FROM Sample_Request_Line_Item__c WHERE Sample_Request__c =:sampleRequestId AND SAP_Line_Item_Id__c IN :sapLineItemIdSet]){
            sampleRequestLineMap.put(srLine.SAP_Line_Item_Id__c, srLine);
        }
        
        return sampleRequestLineMap;
    }
    
    
    global class SampleRequestLineItem{
        global String sf_sample_request_id;
        global String sap_line_item_id;
        global String development_code;
        global Decimal quantity_of_sample;
        global String sample_sent_status;
        global String tracking_number;
        global String created_by;
        global String modified_by;
        global Decimal actual_hours;
        global Date date_of_dispatch;
    }
}