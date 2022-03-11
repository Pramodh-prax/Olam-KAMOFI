@istest
public class SamplingRequestToOSSMControllerTest {
    @testSetup public static void setup() {
    	TestDataFactory.setup();
    }
    
    
    @isTest
    static void testValidScenario() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.PDI_Lead__c = UserInfo.getUserId();
        opp.PDI_Member__c = UserInfo.getUserId();
        opp.PLM_Approval_Status__c = 'Approved';
        opp.PDNI_Approval_Status__c = 'Approved';
        update opp;
        Test.startTest();
		SamplingRequestToOSSMController.createSampleRequest(opp.Id);        
        test.stopTest();
    }
    
    @isTest
    static void testPDIUserNotAdded() {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		SamplingRequestToOSSMController.createSampleRequest(opp.Id);        
        test.stopTest();
    }  
	
    
    @isTest
    static void testSampleRequestExistsScenario() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.PDI_Lead__c = UserInfo.getUserId();
        opp.PDI_Member__c = UserInfo.getUserId();
        opp.PLM_Approval_Status__c = 'Approved';
        opp.PDNI_Approval_Status__c = 'Approved';
        update opp;
        SamplingRequestToOSSMController.createSampleRequest(opp.Id); 
        Test.startTest();
		SamplingRequestToOSSMController.createSampleRequest(opp.Id);        
        test.stopTest();
    }
     
    
    @isTest
    static void testSampleRequestFailedScenario() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.PDI_Lead__c = UserInfo.getUserId();
        opp.PDI_Member__c = UserInfo.getUserId();
        opp.PLM_Approval_Status__c = 'Approved';
        opp.PDNI_Approval_Status__c = 'Approved';
        update opp;
        SamplingRequestToOSSMController.createSampleRequest(opp.Id); 
        
        Sample_Request__c sampleRequest = [SELECT Id FROM Sample_Request__c LIMIT 1];
        sampleRequest.Integration_Status__c = 'failed';
        update sampleRequest;
            
        Test.startTest();
		SamplingRequestToOSSMController.createSampleRequest(opp.Id);        
        test.stopTest();
    }   
    
}