@isTest(SeeAllData=false)
public class KMA_PDFViewCntlTest {
	@testSetup static void setupData() {
    	Account acc = new Account();
        acc.name='Test01';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        acc.Segment__c = 'Bakery';
        insert acc;
        
        ContentVersion contentVer = new ContentVersion(
        	Description = 'Test',
            Title = 'Test',
            ContentUrl = 'Test'
        );
        insert contentVer;
    }
    
    @isTest static void testOne() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
    	Test.startTest();
        KMA_PDFViewCntl.ContentWrapper conWrap = new KMA_PDFViewCntl.ContentWrapper();
        KMA_PDFViewCntl.createContentVersion('Test', 'Test file.pdf', acc.Id);
        Test.stopTest();
        
        System.assertEquals([SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id].size(), 1);
    }
}