@isTest
public class QuoteLineItemTriggerTest {

    @testSetup
    public static void setupData()
    {
        //Create an Account
        //Account acc = TestData_Factory.createAccount(true);
        Account acc = new Account();
        acc.name='TestForQuote1';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        //acc.Segment__c = 'Agent/ Distributor';
        insert acc;
         Contact con =new Contact();
        con.AccountId=acc.Id;
        con.LastName='Ben';
        con.Email='abc@gmail.com';
        insert con;
        
        
        //Get the pricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
      /*  //Create an Opportunity
       // Opportunity opp = TestData_Factory.createOpportunity(acc, pricebookId, true);
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp for QuoteLine';
        opp.StageName = 'Briefing';
        opp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        opp.CloseDate = System.today();
       
        opp.Application__c = 'Agent/ Distributor';
        opp.Pricebook2Id = pricebookId;
        opp.CurrencyIsoCode = 'USD';
        insert opp;
        //Create a Quote
       // Quote quote = TestData_Factory.createQuote(acc, opp, true);
         Quote quote=new  Quote(OpportunityId=opp.id,Bussiness_Unit__c=opp.Business_Unit__c,name='Testing QuoteLine',Status='Draft');
         insert quote;
        //Create a Product
        Product2 prod = TestData_Factory.createProduct('12-Spices', 'Tropical', 'Pepper', 'Black Pepper', true);
        
        //Create a PricebookEntry
        //PricebookEntry pbe = TestData_Factory.createPricebookEntry(pricebookId, prod, true);
        
        PricebookEntry pbe = [Select Id from PricebookEntry where Product2Id =: prod.Id and CurrencyIsoCode =: opp.CurrencyIsoCode limit 1];
            */
        Product2 prod = new Product2(
            Name = 'Beans Cocoa',
            IsActive = true
        );
        insert prod;
        // Id pricebookId = Test.getStandardPricebookId();
        System.debug('PBI '+pricebookId);
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe;
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='Gain Test Opportunity For QuoteLine';
        //opp.ContactId=con.Id;
        opp.StageName='Offering';
        opp.CloseDate=System.today()+1;
        opp.Type='New Business';
        opp.Business_Unit__c='Spice';
        opp.Pricebook2Id=pricebookId;
        //opp.CurrencyIsoCode='USD - U.S. Dollar';
        insert opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.UnitPrice=44;
        oli.PricebookEntryId=pbe.Id;
        insert oli;
        Quote quote=new Quote();
        quote.OpportunityId=opp.Id;
        quote.Name=opp.Name;
        quote.Bussiness_Unit__c=opp.Business_Unit__c;
        quote.ExpirationDate=opp.CloseDate;
        quote.Status='Draft';
        insert quote;
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
        
        //Create a QuoteLineItem
        
        QuoteLineItem qLI1 = TestData_Factory.createQuoteLineItemNew(pbe, prod, quote,'N/A', true);
        QuoteLineItem qLI2 = TestData_Factory.createQuoteLineItemNew(pbe, prod, quote,'Not Started', true);
       
        QuoteLineItem qLI3 = TestData_Factory.createQuoteLineItemNew(pbe, prod, quote, 'In Progress', true);
        qLI3.Approval_Status__c = 'In Progress';
        QuoteLineItem qLI4 = TestData_Factory.createQuoteLineItemNew(pbe, prod, quote,'Accepted', true);
        qLI4.Approval_Status__c = 'Accepted';
        QuoteLineItem qLI5 = TestData_Factory.createQuoteLineItemNew(pbe, prod, quote,'Rejected', true);
        qLI5.Approval_Status__c = 'Rejected';
        QuoteLineItem qLI6 = TestData_Factory.createQuoteLineItemNew(pbe, prod, quote,'Recalled', true);
        qLI6.Approval_Status__c = 'Recalled';
        
    }
    
    @isTest
    public static void checkValidation()
    {
        Test.startTest();
        List<QuoteLineItem> QuoLIList = [Select id,Product2.Name,quoteid,Approval_Status__c,Product_Configuration__c from QuoteLineItem];
         
        QuoLIList[0].Product_Configuration__c='[{"olam_material_code":"100000039072","customer_sap_id":"1234","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 500,00"}]}]';
        update QuoLIList[0];
        delete QuoLIList[1];
        
        Test.stopTest();
    }
    @isTest	
    public static void UpdateQuoteStatusTest()	
    {	
        Quote q = [Select id,name from Quote Limit 1];	
        /*QuoteLineItem qLI1 = new QuoteLineItem();	
qLI1.QuoteId = q.Id;	
qLI1.Approval_Status__c = 'N/A';	
insert qLI1;	
QuoteLineItem qLI2 = new QuoteLineItem();	
qLI2.QuoteId = q.Id;	
qLI2.Approval_Status__c = 'NotStarted';	
insert qLI2;	
QuoteLineItem qLI3 = new QuoteLineItem();	
qLI3.QuoteId = q.Id;	
qLI3.Approval_Status__c = 'InProgress';	
insert qLI3;	
QuoteLineItem qLI4 = new QuoteLineItem();	
qLI4.QuoteId = q.Id;	
qLI4.Approval_Status__c = 'Accepted';	
insert qLI4;	
QuoteLineItem qLI5 = new QuoteLineItem();	
qLI5.QuoteId = q.Id;	
qLI5.Approval_Status__c = 'Rejected';	
insert qLI5;	
QuoteLineItem qLI6 = new QuoteLineItem();	
qLI6.QuoteId = q.Id;	
qLI6.Approval_Status__c = 'Recalled';	
insert qLI6; */	
        QuoteLineItemTriggerHelper.updateQuoteStatus(q.Id);	
    }

}