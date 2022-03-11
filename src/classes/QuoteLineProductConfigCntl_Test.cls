@isTest
public class QuoteLineProductConfigCntl_Test {
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
        QuoteLineItem qLI2 = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        qLI2.Approval_Status__c = 'Not Started';
        QuoteLineItem qLI3 = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        qLI3.Approval_Status__c = 'In Progress';
        QuoteLineItem qLI4 = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        qLI4.Approval_Status__c = 'Accepted';
        QuoteLineItem qLI5 = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        qLI5.Approval_Status__c = 'Rejected';
        QuoteLineItem qLI6 = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        qLI6.Approval_Status__c = 'Recalled';
        //System.debug('qLI: '+qLI);
    }
	@isTest
    public static void forProductConfigController()
    {
        List<QuoteLineItem> QuoLIList = [Select id,Product2.Name,quoteid,Approval_Status__c from QuoteLineItem];
        System.debug('Test Qli'+QuoLIList);
        QuoLIList[0].Product_Configuration__c='[ {"customer_sap_id": "cust123","customer_material_code": "6642331","olam_material_code": "100000009688","configurations":[{"mic": "-U100","varient_character_mapping": "","description": "MOLD COUNT PER GRAM","uom": "%","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,000 - 500,000","customer_range": "0,000 - 500,000"}, { "mic": "","varient_character_mapping": "MOIST","description": "Moist 6","uom": "","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,00 - 500,00","customer_range": ""}]}]';
        Test.startTest();
        update QuoLIList[0];
        String secondParam= QuoteLineProductConfigCntl.getConfigurations(QuoLIList[0].Id);
        /*List<ProductConfigWrapper> secondParam = (List<ProductConfigWrapper>) JSON.deserialize(QuoLIList[0].Product_Configuration__c, List<ProductConfigWrapper>.class);
        string testVal;
        for(ProductConfigWrapper tempWrap : secondParam){
            system.debug(tempWrap.mic);
            testVal = tempWrap.mic;
            testVal = tempWrap.varient_character_mapping;
			testVal = tempWrap.description;
			testVal = tempWrap.uom;
			testVal = tempWrap.quantitative;
			testVal = tempWrap.qualitative;
			testVal = tempWrap.olam_range;
			testVal = tempWrap.customer_range;
			testVal = tempWrap.category;
        }*/
        QuoteLineProductConfigCntl.saveConfigurtions(QuoLIList[0].Id, secondParam);
        Test.stopTest();
    }
}