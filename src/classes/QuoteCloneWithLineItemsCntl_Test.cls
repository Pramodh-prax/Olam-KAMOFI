@isTest
public class QuoteCloneWithLineItemsCntl_Test {

    @testSetup
    public static void setupData()
    {
        //Create an Account
        Account acc = TestData_Factory.createAccount(true);
        
        //Get the pricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create an Opportunity
        Opportunity opp = TestData_Factory.createOpportunity(acc, pricebookId, true);
        
        //Create a Quote
        Quote quote = TestData_Factory.createQuote(acc, opp, true);
        
        //Create a Product
        Product2 prod = TestData_Factory.createProduct('12-Spices', 'Tropical', 'Pepper', 'Black Pepper', true);
        
        //Create a PricebookEntry
        //PricebookEntry pbe = TestData_Factory.createPricebookEntry(pricebookId, prod, true);
        
        PricebookEntry pbe = [Select Id from PricebookEntry where Product2Id =: prod.Id and CurrencyIsoCode =: opp.CurrencyIsoCode limit 1];
            
        //Create a QuoteLineItem
        QuoteLineItem qLI1 = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        
    }
    
    @isTest
    public static void cloneQuoteTest()
    {
        Quote qout = [Select id from Quote limit 1];
        Test.startTest();
        QuoteCloneWithLineItemsCntl.cloneQuote(qout.Id);
        QuoteCloneWithLineItemsCntl.getMetadata();
        QuoteCloneWithLineItemsCntl.ResponseWrapper wrap = new QuoteCloneWithLineItemsCntl.ResponseWrapper();
        wrap.message ='';
        wrap.quoteId = '';
        Test.stopTest();
    }
	
}