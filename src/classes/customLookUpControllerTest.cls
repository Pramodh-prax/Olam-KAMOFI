@isTest(SeeAllData=false)
public class customLookUpControllerTest {
	@testSetup static void setupData() {
        
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
    }
    
    @isTest static void testOne() {
        Test.startTest();
        List <sObject> returnList = customLookUpController.fetchLookUpValues('Cocoa', 'Product2', Test.getStandardPricebookId(), 'USD');
        Test.stopTest();
        System.assertEquals(returnList.size(), 2);
    }
}