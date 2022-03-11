@istest(SeeAllData=false)
public class SampleRequestDispatchRESTTest {
    @testSetup public static void setup() {
    	TestDataFactory.setup();
    }
    
    static testMethod void testMethod1(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.PDI_Lead__c = UserInfo.getUserId();
        opp.PDI_Member__c = UserInfo.getUserId();
        opp.PLM_Approval_Status__c = 'Approved';
        opp.PDNI_Approval_Status__c = 'Approved';
        update opp;
		SamplingRequestToOSSMController.createSampleRequest(opp.Id); 
        
        Sample_Request__c sr = [SELECT Id FROM Sample_Request__c LIMIT 1];
        
        Sample_Request_Line_Item__c srli = [SELECT Id FROM Sample_Request_Line_Item__c LIMIT 1];
        srli.SAP_Line_Item_Id__c = 'qwerty';
        update srli;
        
        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://olam--olamcrmstg.my.salesforce.com/services/apexrest/SampleRequestDispatch/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        List<SampleRequestDispatchREST.SampleRequestLineItem> srlinList = new List<SampleRequestDispatchREST.SampleRequestLineItem>();
        SampleRequestDispatchREST.SampleRequestLineItem srlin = new SampleRequestDispatchREST.SampleRequestLineItem();
        srlin.sf_sample_request_id = sr.id;
        srlin.actual_hours = 12;
        srlin.created_by  = 'asdada';
        srlin.date_of_dispatch  = system.today();
        srlin.development_code  = 'asdada';
        srlin.modified_by  = 'asdada';
        srlin.quantity_of_sample  = 110;
        srlin.sample_sent_status  = '5';
        srlin.sap_line_item_id  = 'qwerty';
        srlin.tracking_number  = 'asdada';
        srlinList.add(srlin);    
        
        Map<String, Sample_Request_Line_Item__c> sampleRequestLineMap = new Map<String, Sample_Request_Line_Item__c>();
        
       for(Sample_Request_Line_Item__c srLine :[SELECT Id, SAP_Line_Item_Id__c, Actual_Hours__c FROM Sample_Request_Line_Item__c WHERE Sample_Request__c= :sr.id AND SAP_Line_Item_Id__c = :srlinList[0].sap_line_item_id ]){
            sampleRequestLineMap.put(srLine.SAP_Line_Item_Id__c, srLine);
        }
        
        
        
        boolean b = SampleRequestDispatchREST.updateSampleRequest(srlinList);
        test.stopTest();        
    }
}