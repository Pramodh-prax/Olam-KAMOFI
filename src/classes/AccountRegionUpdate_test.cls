@isTest
public class AccountRegionUpdate_test {

    
    public static void createTestUser() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            UserRole cocoaRole = new UserRole(DeveloperName = 'Cocoa_Something_Role', Name = 'Cocoa Something');
            insert cocoaRole;
            
            Id cocoaProfileId = [SELECT Id FROM Profile WHERE Name = 'Cocoa Sales'].Id;
            User user = new User(
                ProfileId = cocoaProfileId,
                LastName = 'UnitTestCocoaUser1',
                Email = 'UnitTestCocoaUser1' + '@unittestuser.com',
                Username = 'UnitTestCocoaUser1' + '@unittestuser.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = cocoaRole.Id
            );    
            insert user;
        }
    }
    
    @isTest
    public static void testRegionUpdate() {
        Test.startTest();
        
        createTestUser();
        Account acc1, acc2, acc3;
        User user1 = [SELECT Id FROM User WHERE LastName = 'UnitTestCocoaUser1'];
        //System.runAs (user1) {
            acc1 = new Account(Name = 'UNIT TEST account1', BillingStreet = 'Test 1 street', BillingCountry = 'Australia',BillingCountryCode = 'AU');
            acc2 = new Account(Name = 'UNIT TEST account2', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore',BillingCountryCode = 'SG');
            acc3 = new Account(Name = 'UNIT TEST account5', BillingStreet = 'Test 1 street', BillingCountry = 'India',BillingCountryCode = 'IN');
            List<Account> accounts = new List<Account>{acc1, acc2, acc3};
            insert accounts;
        //}
        Map<id,account> actualResults= new map<id,account> ([select regions__c,ofi_sub_region__c,ofi_sub_region_2__c from account]);
        Test.stopTest();
        System.assertEquals('APAC', actualResults.get(acc1.Id).regions__c, 'Expecpted OFI Region');        
        System.assertEquals('Asia', actualResults.get(acc2.Id).ofi_sub_region__c, 'Expecpted OFI Sub Region');

    }
}