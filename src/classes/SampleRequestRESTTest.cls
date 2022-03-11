@isTest(SeeAllData=false)
private class SampleRequestRESTTest{
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
        
        Test.startTest();
        
        Id recordId = [SELECT Id FROM Sample_Request__c LIMIT 1].Id;
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://olam--olamcrmstg.my.salesforce.com/services/apexrest/SampleRequest/'
            + recordId ;
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        SampleRequestREST.SampleRequestWrapper sreq = SampleRequestREST.getSampleRequest(); 
        
        test.stopTest();     
    }
}