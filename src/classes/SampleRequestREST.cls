@RestResource(urlMapping='/SampleRequest/*')
global with sharing class SampleRequestREST{

    @HttpGet
    global static SampleRequestWrapper getSampleRequest() {
     
        RestRequest req = RestContext.request;
        String sampleRequestId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        SampleRequestWrapper result = new SampleRequestWrapper();
        
        Sample_Request__c sampleRequest = 
            [SELECT Id, Account__c, Opportunity__c, Opportunity__r.Name, Account_Name__c, Account_SAP_Id__c, Country__c, PD_I_User_Country__c, PD_I_User_Email__c, 
            Region__c, Sample_Due_Date__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountryCode, 
            Account__r.BillingPostalCode, Integration_Status__c, Sample_Requested_Date__c, Sample_Request_SAP_Id__c
            FROM Sample_Request__c
            WHERE Id = :sampleRequestId];
            
        result.sample_request = getSampleRequest(sampleRequest);
            
        List<Sample_Request_Line_Item__c> sampleRequestLineItems = new List<Sample_Request_Line_Item__c>();
        sampleRequestLineItems = [SELECT Id, Development_Code__c, Material_code_External_Product_Code__c, Opportunity_Product__c, Product__c,Product__r.Name,  
                Product_Family__c, Quantity__c, Sample_Request__c, Sampling_Status__c, Sample_with_Billing__c, Tracking_Number__c, 
                Unit_of_measure__c, Integration_Status__c, SAP_Line_Item_Id__c, Sample_Request__r.Opportunity__c
                 FROM Sample_Request_Line_Item__c 
                 WHERE Sample_Request__c = :sampleRequestId];
        
        for(Sample_Request_Line_Item__c sampleRequestLine : sampleRequestLineItems){
            result.sample_request_line_items.add(getSampleRequestLine(sampleRequestLine));
        }
        
        UPDATE new Sample_Request__c(Id = sampleRequestId, Integration_Status__c = 'sent_to_ossm');
        
        List<Sample_Request_Line_Item__c> sampleRequestLinesToUpdate = new List<Sample_Request_Line_Item__c>();
        for(Sample_Request_Line_Item__c sampleRequestLine : sampleRequestLineItems){
            sampleRequestLinesToUpdate.add(new Sample_Request_Line_Item__c(Id = sampleRequestLine.Id, Integration_Status__c = 'sent_to_ossm'));
        }
        
        UPDATE sampleRequestLinesToUpdate;
        
        System.debug('Sample Request Payload ' + JSON.serialize(result));
        
        return result;
    }
    
    
    @HttpPost
    global static Boolean updateSampleRequest() {
        return true;
    }
    
    
    public static SampleRequestLineItem getSampleRequestLine(Sample_Request_Line_Item__c sampleRequestLine){
        SampleRequestLineItem sample_request_line = new SampleRequestLineItem();
        
        sample_request_line.sample_request_line_item_id = sampleRequestLine.Id;
        sample_request_line.sample_request_id = sampleRequestLine.Sample_Request__c;
        sample_request_line.development_code = sampleRequestLine.Development_Code__c;
        sample_request_line.external_product_code = sampleRequestLine.Material_code_External_Product_Code__c;
        sample_request_line.product_name = sampleRequestLine.Product__r.name;
        sample_request_line.product_family = sampleRequestLine.Product_Family__c;
        sample_request_line.quantity = sampleRequestLine.Quantity__c;
        sample_request_line.sample_status = sampleRequestLine.Sampling_Status__c;
        sample_request_line.sample_with_billing = sampleRequestLine.Sample_with_Billing__c;
        sample_request_line.tracking_number = sampleRequestLine.Tracking_Number__c;
        sample_request_line.unit_of_measure = sampleRequestLine.Unit_of_measure__c;
        sample_request_line.sap_lineitem_id = sampleRequestLine.SAP_Line_Item_Id__c;
        sample_request_line.spec_doc_links = Label.OppDocumentRelatedListUrl.replace('<<OPPID>>',sampleRequestLine.Sample_Request__r.Opportunity__c);
        
        if(sampleRequestLine.SAP_Line_Item_Id__c == null){
            sample_request_line.flag = 'N';
        }
        else{
            if(sampleRequestLine.Integration_Status__c == 'amendment'){
                sample_request_line.flag = 'A';
            }
            else{
                sample_request_line.flag = 'O';
            }
        }
        
        return sample_request_line;
    }
        
    
    public static SampleRequest getSampleRequest(Sample_Request__c sampleRequest){
        SampleRequest sample_request = new SampleRequest();
        
        sample_request.sample_request_id = sampleRequest.Id;
        sample_request.sap_sample_request_id = sampleRequest.Sample_Request_SAP_Id__c;
        sample_request.opportunity_name = sampleRequest.Opportunity__r.Name;
        sample_request.account_id = sampleRequest.Account__c;
        sample_request.opportunity_id = sampleRequest.Opportunity__c;
        sample_request.account_name = sampleRequest.Account_Name__c;
        sample_request.account_sap_id = sampleRequest.Account_SAP_Id__c;
        sample_request.country= sampleRequest.Country__c;
        sample_request.pdni_user_country = sampleRequest.PD_I_User_Country__c;
        sample_request.pdni_user_email = sampleRequest.PD_I_User_Email__c;
        sample_request.region = sampleRequest.Region__c;
        sample_request.sample_due_date = sampleRequest.Sample_Due_Date__c;
        sample_request.sample_requested_date = sampleRequest.Sample_Requested_Date__c;
        sample_request.sap_sample_request_id = sampleRequest.Sample_Request_SAP_Id__c;
        
        AddressDetails address = new AddressDetails();
        address.street1 = sampleRequest.Account__r.BillingStreet;
        address.city = sampleRequest.Account__r.BillingCity;
        address.state = sampleRequest.Account__r.BillingState;
        address.country = sampleRequest.Account__r.BillingCountryCode;
        address.postal_code = sampleRequest.Account__r.BillingPostalCode;        
        sample_request.address = address;
        return sample_request;
    }
    
    
    global class SampleRequestWrapper{
        global SampleRequest sample_request;
        global List<SampleRequestLineItem> sample_request_line_items;
        
        global SampleRequestWrapper(){
            sample_request = new SampleRequest();
            sample_request_line_items = new List<SampleRequestLineItem>();
        }
    }
    
    
    global class SampleRequest{
        global String sample_request_id;
        global String sap_sample_request_id;
        global String opportunity_name;
        global String account_id;
        global String opportunity_id;
        global String account_name;
        global String account_sap_id;
        global String country;
        global String pdni_user_country;
        global String pdni_user_email;
        global String region;
        global Date sample_due_date;
        global Date sample_requested_date;
        global AddressDetails address;
    }
    
    
    global class SampleRequestLineItem{
        global String sample_request_line_item_id;
        global String sample_request_id;
        global String sap_lineitem_id;
        global String development_code;
        global String external_product_code;
        global String product_name;
        global String product_family;
        global Decimal quantity;
        global String sample_status;
        global Boolean sample_with_billing;
        global String tracking_number;
        global String unit_of_measure;
        global String spec_doc_links;
        global String flag;
    }
    
    
    global class AddressDetails{
        global String street1;
        global String street2;
        global String city;
        global String state;
        global String country;
        global String postal_code;
    }
}