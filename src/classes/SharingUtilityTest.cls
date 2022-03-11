@isTest
public class SharingUtilityTest {
 @testSetup
    public static void createData()
    {
        Id currentUserId = UserInfo.getUserId();
        User user = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Dairy Sales'].Id, LastName = 'UnitTestUser1', Email = 'unittestuser000@unittestuser.com',
                             Username = 'unittestuser000@unittestuser.com' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title',
                             Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'//, Access_Set_Role__c = 'Sales'
                            );    
        insert user;
        Account acc1 = OFI_TestDataFactory.createAccount(true);
        Account acc2 = new Account(Name='Test02', BillingCountry = 'China', BillingStreet ='Test',//Segment__c = 'Agent/ Distributor',
                                   Regions__c ='APAC',Customer_Group__c = 'Cadboury');
        insert acc2;
        Teams__c team = OFI_TestDataFactory.createAccountTeam(acc1.Id, user.Id, 'All', 'Edit Access',//'Sales',
                                                              true, true);
        Teams__c team2 = OFI_TestDataFactory.createAccountTeam(acc2.Id, currentUserId, 'Cocoa', 'Read Access',//'PDI',
                                                               false, true);
        
    }
    public static testmethod void data()
    {
        List<Account> account = [Select Id, Name, BillingCountryCode, Regions__c, Customer_Group__c, Channel__c From Account];
        Set<Id> setOfNewAccountIds = new Set<Id>();
        if(!account.isEmpty()){
        for(Account acc : account)
        {
            setOfNewAccountIds.add(acc.Id);
        }
            System.debug('acc====>'+account);
            System.debug('setofAccIds====>'+setOfNewAccountIds);
        SharingUtility.getAccountTeamsUserBUs(setOfNewAccountIds);
        }
    }
}