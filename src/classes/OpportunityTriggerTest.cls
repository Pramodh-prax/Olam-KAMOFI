@isTest
public class OpportunityTriggerTest {
    
    @testSetup
    public static void setupData()
    {
        //Create an Account
        //Account acc = TestData_Factory.createAccount(true);
        //Spices PDI
        /*Profile p = [select id from profile where name='Spices PDI'];
      
        User user1 = new User(alias = 'aksh', email='aksh@noemail.com',
                              emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = p.Id,UserRoleId ='00E2v000001LFNtEAO',
                              timezonesidkey='America/Los_Angeles', username='aksh@noemail.com');
        insert user1;*/
         Account acc = new Account();
        acc.name='TestForOpportunity';
        acc.BillingCountry = 'USA';
        acc.BillingStreet ='Test';
        //acc.Segment__c = 'Agent/ Distributor';
        insert acc;
       // Teams__C team=new Teams__c(Account__c=acc.id,User__c=user1.id,User_Role_Name__c='Spice Sales Manager');
        //insert team;
        //Get the pricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create an Opportunity
       // Opportunity opp = TestData_Factory.createOpportunity(acc, pricebookId, true);
       // System.runAs(user1){
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp for gain opp';
        opp.StageName = 'Briefing';
        opp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        opp.CloseDate = System.today();
        opp.Actual_Developing_Hours__c=2;
        opp.Business_Unit__c = 'Spice';
        
        //opp.Application__c = 'Agent/ Distributor';
        opp.Pricebook2Id = pricebookId;
        opp.CurrencyIsoCode = 'USD';
        insert opp;
        //Create a Quote
       // Quote quote = TestData_Factory.createQuote(acc, opp, true);
        Quote quote=new Quote();
        quote.OpportunityId=opp.Id;
        quote.Name='quote testing1';
        quote.Bussiness_Unit__c=opp.Business_Unit__c;
        quote.ExpirationDate=opp.CloseDate;
        quote.Status='Draft';
        insert quote;
         opp.SyncedQuoteId=quote.id;
         update opp;
        //Create a Product
        
        Product2 prod = TestData_Factory.createProduct('12-Spices', 'Tropical', 'Pepper', 'Black Pepper', true);
        
        //Create a PricebookEntry
        //PricebookEntry pbe = TestData_Factory.createPricebookEntry(pricebookId, prod, true);
        
        PricebookEntry pbe = [Select Id from PricebookEntry where Product2Id =: prod.Id and CurrencyIsoCode =: opp.CurrencyIsoCode limit 1];
       // }
        //Create a QuoteLineItem
        //QuoteLineItem qLI = TestData_Factory.createQuoteLineItemNew(pbe, prod, quote, 'Rejected',true);
        QuoteLineItem qli=new QuoteLineItem();
        qli.QuoteId=quote.Id;
        //qli.Product2Id=p.Id;
        qli.PricebookEntryId=pbe.Id;
        qli.UnitPrice = 0;
        qli.Volume__c=3;
        qli.Quantity=5;
        qli.Approver_Comment__c = 'Test';
        qli.Product_Configuration__c='[{"varient_character_mapping":"ZVAR_MULTI_THRU","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 50,000","mic":"-U100","description":"% THRU US #100","customer_range":"0,000 - 50,000"},{"varient_character_mapping":"ZVAR2_MULTI_THRU","uom":"%","quantitative":"No","qualitative":"","olam_range":"0,000 - 80,000","mic":"-U200","description":"% THRU UK #200","customer_range":"0,000 - 80,000"}]';
        insert qli;
        //System.debug('qLI: '+qLI);
    }
    
    @isTest
    public static void checkOpportunityStatusWithLatestQuoteStatusTest()
    {
         Test.startTest();
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>();
       
        Opportunity opp1 = [SELECT Id,stageName FROM Opportunity LIMIT 1];
        Opportunity opp2 = [SELECT Id,stageName FROM Opportunity LIMIT 1];
        Quote qu1 = [SELECT Id,Status,OpportunityId FROM Quote where OpportunityId= :opp1.Id LIMIT 1];
        qu1.Status='Customer Accepted';
        update qu1;
        opp1.stageName = 'Closing Won';
        update opp1;
        update opp2;
        mapOpp.put(opp2.id,opp2);
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp1);
       
		//OpportunityTriggerHelper.checkOpportunityStatusWithLatestQuoteStatus(oppList,mapOpp);        
        test.stopTest();
    }
      @isTest static void testOne() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Opportunity opp = new Opportunity(
            Name = 'Test1',
            AccountId = acc.Id,
            CloseDate = System.Today(),
            CurrencyIsoCode = 'USD',
            //Application__c = 'Agent/ Distributor',
            StageName = 'Briefing',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId(),
            Business_Unit__c = 'Cocoa',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;
        
        OpportunityLineItem oppli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = [SELECT Id FROM PricebookEntry][0].Id
        );
        insert oppli;
        Test.stopTest();
    }

}