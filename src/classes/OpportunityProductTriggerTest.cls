@isTest(SeeAllData=false)
public class OpportunityProductTriggerTest {

    @testSetup public static void setup() {
        TestDataFactory.setup();
    }
    
    
    @isTest
    static void createSampleRequestAndLineItemAndUpdate() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.PDI_Lead__c = UserInfo.getUserId();
        opp.PDI_Member__c = UserInfo.getUserId();
        opp.PLM_Approval_Status__c = 'Approved';
        opp.PDNI_Approval_Status__c = 'Approved';
        update opp;
        
        SamplingRequestToOSSMController.createSampleRequest(opp.Id);
        
        Test.startTest();
        OpportunityLineItem oplitmObj = [SELECT Id FROM OpportunityLineItem LIMIT 1];
        oplitmObj.Quantity_of_Sample_Grams__c = 33.00;
        oplitmObj.Sampling_Status__c = '1';
        oplitmObj.Sample_with_Billing__c = true;
        oplitmObj.Sample_Feedback__c = 'sdajggggdasd';
        oplitmObj.UoM__c = 'G';
        oplitmObj.Resampling_Quantity__c = 10;
        oplitmObj.Bulk_Sample_Quantity__c = 100;
        update oplitmObj;
        Test.stopTest();
    }
    
    
    static testMethod void createOpp() {
        test.startTest();
        Id oppRecordTNMId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        
        Account acc = new Account();
        acc.name='Test';
        acc.BillingCountry = 'India';
        //acc.Operating_Geographics__c ='Test';
        acc.BillingStreet ='Test';
        insert acc;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 prod = new Product2(
            Family = '03-Cocoa and Speciality',
            Name ='Testing',
            QuantityUnitOfMeasure ='KG',
            Development_Code__c = 'Test1234123'
        );
        insert prod;   
        
        PricebookEntry pbEntry = [Select id from PricebookEntry where Pricebook2Id =: pricebookId and
            Product2Id =: prod.Id and isActive = true AND CurrencyISOCode = 'USD'];
            
           
       
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId =acc.id;
        opp.CloseDate =system.today()+30;
        opp.StageName= 'Offering';
        opp.Pricebook2Id = pricebookId;
        opp.RecordTypeId = oppRecordTNMId;
        
        insert opp;
        
        
        OpportunityLineItem opl=new OpportunityLineItem();
        opl.OpportunityId = opp.Id;
        opl.Product2Id = prod.Id;
        opl.Quantity = 12.00;
        opl.PricebookEntryId=pbEntry.Id;
        insert opl;
        test.stopTest();
    } 
   
}