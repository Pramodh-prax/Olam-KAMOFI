@isTest
public class SubmitForApprovalControllerTest {
	
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
        qLI.Approval_Required__c = 'Yes';
        qLI.Approval_Status__c = 'Not Started;';
        QuoteLineItem qLI2 = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        qLI2.Approval_Required__c = 'Yes';
        qLI2.Approval_Status__c = 'Not Started';
        
        
        System.debug('qLI: '+qLI);
    }
    
    @isTest
    public static void getQuoteLineApprovalsTest()
    {
        Quote quo = [Select id,name from Quote Limit 1];
        Test.startTest();
        SubmitForApprovalController.getQuoteLineApprovals(quo.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void createQuoteLineApprovalTest()
    {
        Quote q = [Select Id, name from Quote Limit 1];
        QuoteLineItem qLI = [Select Id,Product2.Name from QuoteLineItem where QuoteId =: q.Id Limit 1];
        
        Quote_Line_Approval__c QLA = new Quote_Line_Approval__c();
       	QLA.Quote__c = q.Id;
        QLA.Quote_Line_Item__c = qLI.id;
        
        List<Quote_Line_Approval__c> QLAList = new List<Quote_Line_Approval__c>();
        QLAList.add(QLA);
        SubmitForApprovalController.createQuoteLineApprovals(QLAList);
	}
    
    @isTest
    public static void createQuoteLineApprovalTest_Catch()
    {
        Quote q = [Select Id, name from Quote Limit 1];
        QuoteLineItem qLI = [Select Id,Product2.Name from QuoteLineItem where QuoteId =: q.Id Limit 1];
        
        Quote_Line_Approval__c QLA = new Quote_Line_Approval__c();
       	QLA.Quote__c = q.Id;
        QLA.Quote_Line_Item__c = qLI.id;
        QLA.Product_Category__c = 'qwertyuiopokjhgfdsadfghjkljhgfdsdfghjklkjhythgrtyuiouytrtyuioiuytrtyuiopiuytrtyuiopiuytyui'
            +'sadfghfjggfjkjhdfghjkl;kjhgfdsdsfghjkl;kjhgfdfghjkl;lkjhgfdfghjkl;lkjhgfjkl;lkjhgfasdfghjkl;kjhgfdsafghjkl;kjhgfd'
            +'dsfghjkjhgfdsdfghjkl;sdfghjhgfdsdafsghjghgfvbnmnbvsadfghjhgfdcvfgbnhmnbvvdfbgnhmj,kbvccvdfbghnjmkjdcfvbghnjmkkmdcfvgbhnjm';
        
        List<Quote_Line_Approval__c> QLAList = new List<Quote_Line_Approval__c>();
        QLAList.add(QLA);
        SubmitForApprovalController.createQuoteLineApprovals(QLAList);
	}
}