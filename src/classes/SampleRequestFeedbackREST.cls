@RestResource(urlMapping='/SampleRequestFeedback/*')
global with sharing class SampleRequestFeedbackREST{
     
    @HttpGet
    global static SampleRequest getSampleRequestFeedback() {
        RestRequest req = RestContext.request;
        String sampleRequestId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        System.debug('REQUEST -- '+sampleRequestId);
        
        List<SampleRequestLineItem> sampleRequestLineToReturn = new List<SampleRequestLineItem>();
        List<Sample_Request_Line_Item__c> sampleRequestLineListToUpdate = new List<Sample_Request_Line_Item__c>();
        
        for(Sample_Request_Line_Item__c srLine :[SELECT Id, Sample_Feedback__c, Sample_Request__r.Sample_Request_SAP_Id__c, SAP_Line_Item_Id__c , Sampling_Status__c, Reason_for_Resampling__c, Bulk_Sample_Quantity__c, Quantity__c, Unit_of_measure__c, Resampling_Quantity__c  FROM Sample_Request_Line_Item__c WHERE Sample_Request__c = :sampleRequestId AND Integration_Status__c = 'feedback_update']){
            SampleRequestLineItem srLineItem = new SampleRequestLineItem();
            srLineItem.sf_sample_request_id = sampleRequestId;
            srLineItem.sap_sample_request_id = srLine.Sample_Request__r.Sample_Request_SAP_Id__c;
            srLineItem.sap_lineitem_id = srLine.SAP_Line_Item_Id__c;
            srLineItem.status = srLine.Sampling_Status__c;
            
            if(srLine.Sampling_Status__c == '9'){
                srLineItem.quantity = srLine.Bulk_Sample_Quantity__c;
                srLineItem.unit_of_measure = srLine.Unit_of_measure__c;
            }
                
            srLineItem.sample_feedback = srLine.Sample_Feedback__c;
            if(srLine.Sampling_Status__c == '10'){
                srLineItem.sample_feedback = srLine.Reason_for_Resampling__c + ': ' + srLine.Sample_Feedback__c;
            }
            
            if(srLine.Reason_for_Resampling__c == 'Change in Quantity' || srLine.Reason_for_Resampling__c == 'Change in Quantity & Sample Spec'){
                srLineItem.quantity = srLine.Resampling_Quantity__c;
                srLineItem.unit_of_measure = srLine.Unit_of_measure__c;
            }
            
            
            
            sampleRequestLineListToUpdate.add(new Sample_Request_Line_Item__c(Id = srLine.Id, Integration_Status__c = 'update_sent_to_ossm'));
            
            sampleRequestLineToReturn.add(srLineItem);
        }
        
        UPDATE sampleRequestLineListToUpdate;
        
        SampleRequest result = new SampleRequest();
        result.root = sampleRequestLineToReturn;
        
        System.debug('Feedback Response Payload '+ JSON.serialize(result));
        
        return result;
    }
    
    
    global class SampleRequest{
        global List<SampleRequestLineItem> root;
        
        global SampleRequest(){
            root = new List<SampleRequestLineItem>();
        }
    }
    
    
    global class SampleRequestLineItem{
        global String sf_sample_request_id;
        global String sap_sample_request_id;
        global String sap_lineitem_id;
        global String status;
        global String sample_feedback;
        global Decimal quantity;
        global String unit_of_measure;
    }
}