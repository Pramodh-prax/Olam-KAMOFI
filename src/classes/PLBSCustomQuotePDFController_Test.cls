@isTest
public class PLBSCustomQuotePDFController_Test {
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
        
        
        //  Access_Set__c accset= OFI_TestDataFactory.createAccessSet('country', null, 'In','Spice', null, null, null, true); 
        //  Access_Set_Assignment__c accsetass=OFI_TestDataFactory.createAccessSetAssignment(accset.Id, ofiuser.id,'PDI', true);
        
        //Access_Set__c accset1= OFI_TestDataFactory.createAccessSet('country', null, 'In','Cocoa', null, null, null, true); 
        //Access_Set_Assignment__c accsetass1=OFI_TestDataFactory.createAccessSetAssignment(accset1.Id, ofiuser.id,'PDI', true);
        
        
        //Access_Set__c accsetall= OFI_TestDataFactory.createAccessSet('country', null, 'In','All', null, null, null, true); 
        //Access_Set_Assignment__c accsetassall=OFI_TestDataFactory.createAccessSetAssignment(accsetall.Id, ofiuser1.id,'Sales', true);
        //Teams__C teamall=OFI_TestDataFactory.createAccountTeam(acc1.id,  ofiuser1.id, 'All', 'Edit Access','Sales', True, True);        
        //  Teams__C team1=OFI_TestDataFactory.createAccountTeam(acc.id,  ofiuser.id, 'Spice', 'Edit Access','PDI', false, True);
        //  Teams__C team=OFI_TestDataFactory.createAccountTeam(acc1.id,  ofiuser.id, 'Cocoa', 'Edit Access','PDI', false, True);
        
        
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
        Quote qu= new Quote(OpportunityId=opp.Id,Name='testqAdmin',pricebook2Id =pricebookId,ExpirationDate=system.today()+30,Inco_Terms__c='DAP',Ship_To_Party__c=acc.id);
        insert qu;
}
    @isTest
    public static void testScenario()
    {
        Quote q = [Select Id,Name from Quote];
        PLBSCustomQuotePDFController.createDoc(q.Id);
    }
    @isTest
    public static void testScenarioElse()
    {
        Quote q = new Quote();
        PLBSCustomQuotePDFController.createDoc(q.Id);
    }
     @isTest
    public static void testScenario2()
    {
        Quote q = [Select Id,Name from Quote];
        PLBSCustomQuotePDFController.isContactAvailable(q.Id);
    }
}