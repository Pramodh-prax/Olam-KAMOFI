@isTest(SeeAllData=false)
public class OpportunityLineItemTriggerTest {
    @testSetup static void setupData() {
        Account acc = new Account();
        acc.name='Test01';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        insert acc;
        
        Consumption__c consump = new Consumption__c(
            Account__c = acc.Id,
            Business_Unit__c = 'Cocoa',
            Year__c = String.valueOf(System.today().year()),
            Volume_MT__c = 100 
        );
        insert consump;
        
        Brand_n_Comp__c compBrand = new Brand_n_Comp__c(
            Consumption__c = consump.Id,
            Brand__c = 'Huysman',
            Brand_type__c = 'Internal'
        );
        insert compBrand;
        
        Product2 prod = new Product2(
            Name = 'Cocoa Beans',
            IsActive = true
        );
        insert prod;
        
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
    }
    
    @isTest static void testOne() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Opportunity opp = new Opportunity(
            Name = 'Test1',
            AccountId = acc.Id,
            CloseDate = System.Today(),
            CurrencyIsoCode = 'USD',
            StageName = 'Briefing',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId(),
            Business_Unit__c = 'Cocoa',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;
        
        OpportunityLineItem oppli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = [SELECT Id FROM PricebookEntry].Id
        );
        insert oppli;
        Test.stopTest();
    }
}