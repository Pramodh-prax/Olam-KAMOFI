@isTest
public class QuoteLineItemsDisplayController_Test {
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
        QuoteLineItem qLI = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        
        System.debug('qLI: '+qLI);
    }
    @isTest
    public static void fetchQuoteLineItemsTest1()
    {
        Quote quote = [Select id from Quote limit 1];
        System.debug('quote: '+quote);
        Test.startTest();
        List<QuoteLineItem> QuoLIList = QuoteLineItemsDisplayController.fetchQuoteLineItems(quote.Id);
        System.debug('QuoLIList1: '+QuoLIList);
        Test.stopTest();
    }
    @isTest
    public static void deleteQuoteLineItemsTest1()
    {
        Quote quote = [Select id from Quote limit 1];
        
        Test.startTest();
        List<QuoteLineItem> QuoLIList = QuoteLineItemsDisplayController.fetchQuoteLineItems(quote.Id);
        System.debug('QuoLIList2: '+QuoLIList);
        
        List<QuoteLineItem> QuoLIList3 = [Select id from QuoteLineItem];
        System.debug('QuoLIList3: '+QuoLIList3);
        QuoteLineItemsDisplayController.deleteQuoteLineItems(QuoLIList3);
        Test.stopTest();
    }
    @isTest
    public static void fetchQuoteDetailsTest1()
    {
        Quote quote = [Select id from Quote limit 1];
        
        Test.startTest();
        Quote Quo = QuoteLineItemsDisplayController.fetchQuoteDetails(quote.Id);
        Test.stopTest();
    }
    @isTest
    public static void deleteQuoteLineItemsTest2()
    {
        List<QuoteLineItem> QuoLIList3 = new List<QuoteLineItem>();
        QuoteLineItem qli = new QuoteLineItem();
        QuoLIList3.add(qli);
        Test.startTest();
        QuoteLineItemsDisplayController.deleteQuoteLineItems(QuoLIList3);
        Test.stopTest();
    }
    @isTest
    public static void deleteFilesTest1()
    {
        ContentVersion cv = TestData_Factory.createContentVersion(true);
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<Id> listOfContentDocIds = new List<Id>();
        listOfContentDocIds.add(cdList[0].Id);
        Test.startTest();
        QuoteLineItemsDisplayController.deleteFiles(listOfContentDocIds);
        Test.stopTest();
       
    }
    @isTest
    public static void deleteFilesTest2()
    {
        ContentVersion cv = TestData_Factory.createContentVersion(true);
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        List<Id> listOfContentDocIds = new List<Id>();
        listOfContentDocIds.add(cvList[0].Id);
        Test.startTest();
        QuoteLineItemsDisplayController.deleteFiles(listOfContentDocIds);
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateQuoteStatusTest()
    {
        Quote quote = [Select id,name from Quote Limit 1];
        product2 prod = [select id from product2 limit 1];
        PricebookEntry PricebookEntry = [select id from PricebookEntry limit 1];
        /*QuoteLineItem qLI1 = new QuoteLineItem();
        qLI1.QuoteId = quote.Id;
        qLI1.Approval_Status__c = 'N/A';
        qLI1.PricebookEntryId = PricebookEntry.Id;
        qLI1.Quantity = 1;
        qLI1.UnitPrice = 100;
        qLI1.Product2Id = prod.Id;
        insert qLI1;
        QuoteLineItem qLI2 = new QuoteLineItem();
        qLI2.QuoteId = quote.Id;
        qLI2.Approval_Status__c = 'Not Started';
        qLI2.PricebookEntryId = PricebookEntry.Id;
        qLI2.Quantity = 1;
        qLI2.UnitPrice = 100;
        qLI2.Product2Id = prod.Id;
        insert qLI2;
        QuoteLineItem qLI3 = new QuoteLineItem();
        qLI3.QuoteId = quote.Id;
        qLI3.Approval_Status__c = 'In Progress';
        qLI3.PricebookEntryId = PricebookEntry.Id;
        qLI3.Quantity = 1;
        qLI3.UnitPrice = 100;
        qLI3.Product2Id = prod.Id;
        insert qLI3;
        
        QuoteLineItem qLI5 = new QuoteLineItem();
        qLI5.QuoteId = quote.Id;
        qLI5.Approval_Status__c = 'Rejected';
        qLI5.PricebookEntryId = PricebookEntry.Id;
        qLI5.Quantity = 1;
        qLI5.UnitPrice = 100;
        qLI5.Product2Id = prod.Id;
        insert qLI5;
        QuoteLineItem qLI6 = new QuoteLineItem();
        qLI6.QuoteId = quote.Id;
        qLI6.Approval_Status__c = 'Recalled';
        qLI6.PricebookEntryId = PricebookEntry.Id;
        qLI6.Quantity = 1;
        qLI6.UnitPrice = 100;
        qLI6.Product2Id = prod.Id;
        insert qLI6;*/
        QuoteLineItem qLI4 = new QuoteLineItem();
        qLI4.QuoteId = quote.Id;
        qLI4.Approval_Status__c = 'Accepted';
        qLI4.PricebookEntryId = PricebookEntry.Id;
        qLI4.Quantity = 1;
        qLI4.UnitPrice = 100;
        qLI4.Product2Id = prod.Id;
        insert qLI4;
    }
}