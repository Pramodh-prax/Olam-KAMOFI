@isTest
public class PLBSQuotePDFCustomCntl_Test {
@testSetup
    public static void createData()
{
     Profile profOfi = [select id from profile where name='OFI'];
        
        
        User ofiuser = new User(alias = 'jack qu', email='jackqu@noemail.com',
                                emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = profOfi.Id,
                                timezonesidkey='America/Los_Angeles',  username='jackqu@noemail.com');
        insert ofiuser;  
        
        User ofiuser1 = new User(alias = 'jack8', email='jackqu@noemail.com',
                                 emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profOfi.Id,
                                 timezonesidkey='America/Los_Angeles',  username='jack8@noemail.com');
        insert ofiuser1;
        
        List<user> currentuser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Account acc= OFI_TestDataFactory.createMultipleAccount('Test for Quote', 'India','In', null, null, null, true);
        Account acc1= OFI_TestDataFactory.createMultipleAccount('TestQuote1', 'India','In', null, null, null, true);
        Account acc2= OFI_TestDataFactory.createMultipleAccount('TestQuoteFailure', 'India','In', null, null, null, true);
        
		Contact con = new Contact(AccountId = acc.Id, LastName = 'ABC');
    	insert con;
      Id priceBookID = Test.getStandardPricebookId();
        
        Product2 p_test = new Product2(IsActive=true,Name='test Product',Description='Description for test Product');
        insert p_test;
        
        PricebookEntry pbe = new PricebookEntry(IsActive=true,Pricebook2Id=priceBookID,Product2Id=p_test.Id,UnitPrice=10.00);  
        insert pbe;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId =acc1.id;
        opp.CloseDate =system.today()+30;
        opp.StageName= 'Offering';
        opp.Business_Unit__c='All';   
        opp.Pricebook2Id=pricebookId;
        opp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        insert opp; 
     OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id, 
                                                                   Product2Id = p_test.Id, 
                                                                   PricebookEntryId = pbe.Id,Ratio__c=100,
                                                                   Sampling_Status__c = '7');
        insert oppLineItem1;
        Quote qu= new Quote(OpportunityId=opp.Id,Name='testqAdmin',pricebook2Id =pricebookId,ExpirationDate=system.today()+30,Inco_Terms__c='DAP',Ship_To_Party__c=acc.id,Terms_Conditions__c='abc',PM_Type_1st__c = 'DOY',MOQ_Packaging_1st__c = 34);  
    insert qu;
    opp.SyncedQuoteId = qu.Id;
    update opp;
    QuoteLineItem qiItem = new  QuoteLineItem(QuoteId = qu.Id ,Product2Id=p_test.Id  ,PricebookEntryId=pbe.Id,Volume__c=1, Quantity =1 , UnitPrice=123,Unit_Of_Measure__c='KG' );
        insert  qiItem;
}
    @isTest
    public static void testQuotePDFCustomCntl()
    {
        Quote q = [SELECT Id, Name,Inco_Terms__c,ExpirationDate,Payment_Terms__c,Contract_Start_Date__c,Contract_End_Date__c,Olam_Quote_Number__c, Account.Name,Opportunity.RecordType.Name,(SELECT Id, Product2.Name,Approval_Status__c, UnitPrice, Volume__c FROM QuoteLineItems) FROM Quote ]; 
        system.assert(q!=null, 'Null values found');
        PageReference testPage = Page.PLBSQuotePDFCustom; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(q.Id));
        ApexPages.StandardController sc=new ApexPages.StandardController(q);
        PLBSQuotePDFCustomCntl qcc= new PLBSQuotePDFCustomCntl(sc);
    }
}