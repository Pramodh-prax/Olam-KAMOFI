@isTest(SeeAllData=false)
public class opportunityLineItemEditTest {
	@testSetup static void setupData() {
        Account acc = new Account();
        acc.name='Test01';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        acc.Segment__c = 'Bakery';
        insert acc;
        
        Product2 prod = new Product2(
            Name = 'Cocoa Beans',
            IsActive = true
        );
        insert prod;
        
        Product2 prod2 = new Product2(
            Name = 'Cocoa Butter',
            IsActive = true
        );
        insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('PBI '+pricebookId);
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod2.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe2;
        
        Opportunity opp = new Opportunity(
        	AccountId = acc.Id,
            Name = 'Test Opp',
            StageName = 'Briefing',
            RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId(),
            CloseDate = System.today(),
            Business_Unit__c = 'Cocoa',
            Application__c = 'Bakery',
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = 'USD'
        );
        insert opp;
        
        OpportunityLineItem oppli = new OpportunityLineItem(
        	OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            UnitPrice = 0
        );
        insert oppli;
    }
    
    
    @isTest static void testOne() {
    	Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        opportunityLineItemEdit.fetchOpportunityLineItem(opp.Id);
        Test.stopTest();
    }
    
    
    @isTest static void testTwo() {
    	Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> oppliList = [SELECT Id, Product2Id,UnitPrice,Customer_Bid__c,Unit_of_measure__c,Description,
                                                              Volume__c,Shipment_Month__c,Splits__c,Sampling_Status__c,Quantity_of_Sample_Grams__c,
                                                              Tracking_Number__c,Tracking_URL__c,Opportunity.PriceBook2Id from OpportunityLineItem];
        
        Test.startTest();
        opportunityLineItemEdit.saveOpportunityLineItem(opp.Id, oppliList);
        Test.stopTest();
    }
    
    
    @isTest static void testThree() {
        Test.startTest();
        opportunityLineItemEdit.getselectOptions(new OpportunityLineItem(), 'Sampling_Status__c');
        Test.stopTest();
    }
}