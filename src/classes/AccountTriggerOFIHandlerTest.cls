@isTest
public class AccountTriggerOFIHandlerTest {
    @testSetup
    public static void data()
    {
        Profile p = [Select Id , Name From Profile where Name = 'OFI'];
        
        User u1 = new User(alias = 'jack12', email='jack12@noemail.com',
                           emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='jack12@noemail.com');
        insert u1;
        User u2 = new User(alias = 'tim123', email='tim123@anemail.com',
                           emailencodingkey='UTF-8', lastname='trial', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='tim123@anemail.com');
        insert u2;
        User u3 = new User(alias = 'rey619', email='rey619@hiemail.com',
                           emailencodingkey='UTF-8', lastname='Myst', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='rey619@hiemail.com');
        insert u3;
        User u4 = new User(alias = 'sam09', email='sam09@newemail.com',
                           emailencodingkey='UTF-8', lastname='Curran', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='sam09@newemail.com');
        insert u4;
        User u5 = new User(alias = 'andre08', email='andre08@hiemail.com',
                           emailencodingkey='UTF-8', lastname='Russel', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='andre08@hiemail.com');
        insert u5;
        User u6 = new User(alias = 'kieron1', email='kieron1@noemail.com',
                           emailencodingkey='UTF-8', lastname='Myst', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='kieron1@noemail.com');
        insert u6;
        User u7 = new User(alias = 'moen786', email='moen786@newemail.com',
                           emailencodingkey='UTF-8', lastname='Myst', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='moen786@newemail.com');
        insert u7;
        User u8 = new User(alias = 'faf456', email='faf456@anemail.com',
                           emailencodingkey='UTF-8', lastname='Myst', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='faf456@anemail.com');
        insert u8;
        User u9 = new User(alias = 'abd789', email='abd789@hiemail.com',
                           emailencodingkey='UTF-8', lastname='Myst', languagelocalekey='en_US',
                           localesidkey='en_US',profileid = p.Id,
                           timezonesidkey='America/Los_Angeles', username='abd789@hiemail.com');
        insert u9;
        System.debug('All users added');
        Access_Set__c access1 = new Access_Set__c(Grant_Access_By__c = 'Region',BU__c = 'Cocoa' , Regions__c = 'APAC' , Customer_Group__c = 'TH' , Channel__c = 'Trade House');
        insert access1;
        Access_Set__c access2 = new Access_Set__c(Grant_Access_By__c = 'Country',BU__c = 'Dairy' , Country__c = 'IN', Customer_Group__c = 'TH', Channel__c = 'Trade House');
        insert access2;
        Access_Set__c access3 = new Access_Set__c(Grant_Access_By__c = 'Region',BU__c = 'Spice' , Regions__c = 'APAC', Customer_Group__c = 'TH');
        insert access3;
        Access_Set__c access4 = new Access_Set__c(Grant_Access_By__c = 'Region',BU__c = 'Dairy' , Regions__c = 'APAC', Channel__c = 'Trade House');
        insert access4;
        Access_Set__c access5 = new Access_Set__c(Grant_Access_By__c = 'Country',BU__c = 'Cocoa' , Country__c = 'IN', Customer_Group__c = 'TH');
        insert access5;
        Access_Set__c access6 = new Access_Set__c(Grant_Access_By__c = 'Country',BU__c = 'Dairy' , Country__c = 'IN', Channel__c = 'Trade House');
        insert access6;
        Access_Set__c access7 = new Access_Set__c(Grant_Access_By__c = 'Region',BU__c = 'Spice' , Regions__c = 'APAC');
        insert access7;
        Access_Set__c access8 = new Access_Set__c(Grant_Access_By__c = 'Country',BU__c = 'Dairy' , Country__c = 'IN');
        insert access8;
        
        Access_Set_Assignment__c accessAssign1 = new Access_Set_Assignment__c(Access_Set__c = access7.Id, user__c = UserInfo.getUserId());
        insert accessAssign1;
        Access_Set_Assignment__c accessAssign2 = new Access_Set_Assignment__c(Access_Set__c = access1.Id, user__c = UserInfo.getUserId());
        insert accessAssign2;
        Access_Set_Assignment__c accessAssign3 = new Access_Set_Assignment__c(Access_Set__c = access2.Id, user__c = UserInfo.getUserId());
        insert accessAssign3;
         Access_Set_Assignment__c accessAssign4 = new Access_Set_Assignment__c(Access_Set__c = access3.Id, user__c = UserInfo.getUserId());
        insert accessAssign4;
        Access_Set_Assignment__c accessAssign5 = new Access_Set_Assignment__c(Access_Set__c = access4.Id, user__c = UserInfo.getUserId());
        insert accessAssign5;
        Access_Set_Assignment__c accessAssign6 = new Access_Set_Assignment__c(Access_Set__c = access5.Id, user__c = u5.Id);
        insert accessAssign6;
        Access_Set_Assignment__c accessAssign7 = new Access_Set_Assignment__c(Access_Set__c = access6.Id, user__c = u6.Id);
        insert accessAssign7;
        Access_Set_Assignment__c accessAssign8 = new Access_Set_Assignment__c(Access_Set__c = access7.Id, user__c = u7.Id);
        insert accessAssign8;
        Access_Set_Assignment__c accessAssign9 = new Access_Set_Assignment__c(Access_Set__c = access8.Id, user__c = u8.Id);
        insert accessAssign9;
    }
    public static testmethod void accountCreationValidationOFI_Test()
    {
        Account acc1 = new Account(Name = 'TEST account1', BillingCity='India', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', Customer_Group__c = 'TH' , Channel__c = 'Trade House');       
        Account acc2 = new Account(Name = 'TEST account2', BillingCity='India', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', Regions__c = 'APAC' , Channel__c = 'Trade House');       
        Account acc3 = new Account(Name = 'TEST account3', BillingCity='India', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', Regions__c = 'APAC');       
        Account acc4 = new Account(Name = 'TEST account4', BillingCity='India', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', Regions__c = 'APAC', Channel__c = 'Trade House');       
        Account acc5 = new Account(Name = 'TEST account5', BillingCity='India', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', Customer_Group__c = 'TH' , Channel__c = 'Trade House');       

        List<Account> acc = new List<Account>();
        acc.add(acc1);
        acc.add(acc2);
        acc.add(acc3);
        acc.add(acc4);
        acc.add(acc5);
        
        AccountTriggerOFIHandler.accountCreationValidationOFI(acc);
    }
    
}