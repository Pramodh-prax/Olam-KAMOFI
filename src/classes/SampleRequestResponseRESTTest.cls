@isTest(SeeAllData=false)
public class SampleRequestResponseRESTTest { 
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
        
        test.startTest();
        Sample_Request__c sr = [SELECT Id FROM Sample_Request__c LIMIT 1];
        List<Sample_Request_Line_Item__c> srlin = [SELECT Id FROM Sample_Request_Line_Item__c LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://olam--olamcrmstg.my.salesforce.com/services/apexrest/SampleRequestResponse/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        SampleRequestResponseREST.SampleRequest s = new  SampleRequestResponseREST.SampleRequest();
        s.flag = 'sdfs';
        list<SampleRequestResponseREST.SampleRequestLine> srlinlist = new list<SampleRequestResponseREST.SampleRequestLine>();
        SampleRequestResponseREST.SampleRequestLine srln = new SampleRequestResponseREST.SampleRequestLine();
        srln.sap_lineitem_id = 'vhjvjv';
        srln.sf_lineitem_id = srlin[0].id;
        srlinlist.add(srln);
        s.sap_sample_request_id = 'sdfs';
        s.sf_sample_request_id = sr.id;
        s.items = srlinlist;
        s.status = 'sdfs';
        boolean b = SampleRequestResponseREST.updateSampleRequest(s);   
        test.stopTest();        
    }
}