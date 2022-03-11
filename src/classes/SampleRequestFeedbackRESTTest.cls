@isTest(SeeAllData=false)
public class SampleRequestFeedbackRESTTest {   
    @testSetup public static void setup() {
    	TestDataFactory.setup();
    }
    
    @istest
    static void testmethod1(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.PDI_Lead__c = UserInfo.getUserId();
        opp.PDI_Member__c = UserInfo.getUserId();
        opp.PLM_Approval_Status__c = 'Approved';
        opp.PDNI_Approval_Status__c = 'Approved';
        update opp;
		SamplingRequestToOSSMController.createSampleRequest(opp.Id); 
        
        test.startTest();
        Sample_Request_Line_Item__c sampleRequestLine = [SELECT Id FROM Sample_Request_Line_Item__c LIMIT 1];
        sampleRequestLine.Integration_Status__c = 'feedback_update';
        update sampleRequestLine;
        
        RestRequest request = new RestRequest();
        request.requestUri = 'https://olam--olamcrmstg.my.salesforce.com/services/apexrest/SampleRequestFeedbackREST/'+[SELECT Id FROM Sample_Request__c LIMIT 1].Id;
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        SampleRequestFeedbackREST.SampleRequest s = SampleRequestFeedbackREST.getSampleRequestFeedback();
        test.stopTest(); 
    }
}