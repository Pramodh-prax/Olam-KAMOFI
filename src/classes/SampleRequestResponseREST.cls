@RestResource(urlMapping='/SampleRequestResponse/*')
global with sharing class SampleRequestResponseREST{
    @HttpPost
    global static Boolean updateSampleRequest(SampleRequest record) {
        Boolean success = false;
        
        System.debug('OSSM RESPONSE --' + JSON.serialize(record));
        
        Sample_Request__c sampleRequest = new Sample_Request__c(
            Id = record.sf_sample_request_id,
            Sample_Request_SAP_Id__c = record.sap_sample_request_id,
            Integration_Status__c = record.flag == 'S' ? 'registered_in_ossm' : 'failed',
            Integration_Message__c = record.status
        );
        
        
        List<Sample_Request_Line_Item__c> lineItemsToUpdate = new List<Sample_Request_Line_Item__c>();
        
        for(SampleRequestLine item :record.items){
            lineItemsToUpdate.add(
                new Sample_Request_Line_Item__c(
                    Id = item.sf_lineitem_id, 
                    SAP_Line_Item_Id__c = record.flag == 'S' ? item.sap_lineitem_id : '',
                    Integration_Status__c = record.flag == 'S' ? 'registered_in_ossm' : 'failed'
                )    
            );
        }
        
        
        UPDATE sampleRequest;
        UPDATE lineItemsToUpdate;
        return true;
    }
    
    
    @testVisible
     global class SampleRequest{
        global String sf_sample_request_id;
        global String sap_sample_request_id;
        global String flag;
        global String status;
        global List<SampleRequestLine> items;
        
        global SampleRequest(){
            items = new List<SampleRequestLine>();
        }
    }  
    
    
    @testVisible
    global class SampleRequestLine{
        global String sf_lineitem_id;
        global String sap_lineitem_id;
    }
}