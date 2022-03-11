@isTest
public class AccountPlansTrigger_Test {

    @testSetup
    public static void createData()
{
    UserRole r = [select id,name from UserRole where name LIKE '%Cocoa%' limit 1];
        Profile prof = [select id,name from profile where name LIKE '%Cocoa%' limit 1]; 
    User usr1 = new User(ProfileId = prof.Id, LastName = 'OLTest01', Email = 'olam.test@test.olam.com1',
                             Username = 'olam.test@test.olam.com1' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title',
                             Alias = 'OLTest02', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US');    
        insert usr1;
    Access_Set__c access1 = new Access_Set__c(Grant_Access_By__c = 'Country',BU__c = 'All' , Region__c = null , Country__c = 'IN');
        insert access1; 
    Access_Set_Assignment__c assign = OFI_TestDataFactory.createAccessSetAssignment(access1.Id, usr1.Id,//'Sales',
                                                                                    true);
    System.runAs(usr1){
    Account acc = new Account();
            acc.name='Test01';
            acc.BillingCountry = 'India';
            acc.BillingStreet ='Test';
            insert acc;
    Account_Plans__c ap = OFI_TestDataFactory.createAccountPlan(acc.Id, 'Dairy', true);
        
    }
}
    @isTest
    public static void testData()
{
    User u = [Select Id, Name From User where Email =: 'olam.test@test.olam.com1'];
    System.runAs(u){
   List<Account_Plans__c> ap = [Select Id,Name From Account_Plans__c];
    System.debug('app======>'+ap);
    ap[0].Name = 'Demo Plan 2';
    update ap;
    }
}
}