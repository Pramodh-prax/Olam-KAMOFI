@isTest
public class PLBSComponentController_Test {

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
    	TCB__c tcb = new TCB__c();
    	tcb.Opportunity__c = opp.Id;
    insert tcb;
}
     @isTest
    public static void testScenario()
    {
        Opportunity opp = [Select Id, Name From Opportunity];
        PLBSComponentController.getTCBId(opp.Id);
    }
}