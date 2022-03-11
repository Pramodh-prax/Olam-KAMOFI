@isTest
public class EditQuoteLineItemsController_Test {
	@testSetup
    public static void setupData()
    {
        //Create an Account
        //Account acc = TestData_Factory.createAccount(true);
        Account acc = new Account();
        acc.name='TestForOpportunity';
        acc.BillingCountry = 'USA';
        acc.Regions__c='USA';
        acc.BillingStreet ='Test';
        insert acc;
        //Get the pricebookId
        //Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 pricebook = TestData_Factory.createPriceBook(true);
        Id pricebookId = pricebook.Id;
        
        //Create an Opportunity
        Opportunity opp = TestData_Factory.createOpportunity(acc, pricebookId, true);
        
        //Create a Quote
        //Quote quote = TestData_Factory.createQuote(acc, opp, true);
        Quote quote=new Quote();
        quote.OpportunityId=opp.Id;
        quote.Name='quote testing1';
        quote.Bussiness_Unit__c=opp.Business_Unit__c;
        quote.ExpirationDate=opp.CloseDate;
        quote.Status='Draft';
        insert quote;
        //Create a Product
        Product2 prod = TestData_Factory.createProduct('12-Spices', 'Tropical', 'Pepper', 'Black Pepper', true);
        
        //Create a PricebookEntry
        PricebookEntry pbe = TestData_Factory.createPricebookEntry(pricebookId, prod, true);
        
        //PricebookEntry pbe = [Select Id from PricebookEntry where Product2Id =: prod.Id and CurrencyIsoCode =: opp.CurrencyIsoCode limit 1];
            
        //Create a QuoteLineItem
        QuoteLineItem qLI = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        
    }
    
    @isTest
    public static void testEditQuoteLineItem()
    {
         Test.startTest();
        List<QuoteLineItem> quoteLineItems = [Select id,QuoteId,unitPrice,Volume__c,Unit_Of_Measure__c,Approval_Required__c,Is_File_Uploaded__c,Customer_Material_Code__c from QuoteLineItem];
        List<EditQuoteLineItemsController.LineItemWrapper> listItem=new List<EditQuoteLineItemsController.LineItemWrapper>();
        listItem=EditQuoteLineItemsController.fetchLineItemWrapper(quoteLineItems,quoteLineItems[0].QuoteId);
        EditQuoteLineItemsController.getIsApprovalRequiredValues(quoteLineItems[0].QuoteId);
        EditQuoteLineItemsController.updateQuoteLineItem(quoteLineItems[0].QuoteId, listItem);
        List<Opportunity> opp=[select id,Business_Unit__c,CloseDate from Opportunity];
        Quote quote=new Quote();
        quote.OpportunityId=opp[0].Id;
        quote.Name='quote testing1';
        quote.Bussiness_Unit__c=opp[0].Business_Unit__c;
        quote.ExpirationDate=opp[0].CloseDate;
        quote.Status='Draft';
        insert quote; 
        EditQuoteLineItemsController.getselectOptions(Quote, 'Bussiness_Unit__c');
        Test.stopTest();
    }
}