@isTest
public class AccountMappingTriggerHandler_Test {
    
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
    public static void testUpdatingSAPAccountId() {
        Test.startTest();
        
        createTestUser();
        Account acc1, acc2, acc3, acc4, acc5, acc5Dup, acc6;
        User user1 = [SELECT Id FROM User WHERE LastName = 'UnitTestCocoaUser1'];
        //System.runAs (user1) {
            acc1 = new Account(Name = 'UNIT TEST account1', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore');
            acc2 = new Account(Name = 'UNIT TEST account2', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore');
            acc3 = new Account(Name = 'UNIT TEST account3', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore');
            acc4 = new Account(Name = 'UNIT TEST account4', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore');
            acc5 = new Account(Name = 'UNIT TEST account5', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore');
            acc5Dup = new Account(Name = 'UNIT TEST account5', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore');
            acc6 = new Account(Name = 'UNIT TEST account6', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore', SAP_Account_ID__c = '666');
            List<Account> accounts = new List<Account>{acc1, acc2, acc3, acc4, acc5, acc5Dup, acc6};
            insert accounts;
        //}
        
        Account_Mapping__c accMap1 = new Account_Mapping__c(Account_Name__c = 'UNIT TEST account1', SAP_Account_ID__c  = '111');
        Account_Mapping__c accMap2 = new Account_Mapping__c(Account_Name__c = 'UNIT TEST account2', SAP_Account_ID__c  = '');
        Account_Mapping__c accMap3 = new Account_Mapping__c(Account_Name__c = '', SAP_Account_ID__c  = '333');
        Account_Mapping__c accMap4 = new Account_Mapping__c(Account_Name__c = 'UNIT TEST account4', SAP_Account_ID__c  = '444');
        Account_Mapping__c accMap4Dup = new Account_Mapping__c(Account_Name__c = 'UNIT TEST account4', SAP_Account_ID__c  = '4444');
        Account_Mapping__c accMap5 = new Account_Mapping__c(Account_Name__c = 'UNIT TEST account5', SAP_Account_ID__c  = '555');
        Account_Mapping__c accMap6 = new Account_Mapping__c(Account_Name__c = 'UNIT TEST account6', SAP_Account_ID__c  = '6666');
        Account_Mapping__c accMap7 = new Account_Mapping__c(Account_Name__c = 'UNIT TEST account7', SAP_Account_ID__c  = '777');
        List<Account_Mapping__c> accountMaps = new List<Account_Mapping__c>{accMap1, accMap2, accMap3, accMap4, accMap4Dup, accMap5, accMap6, accMap7};
        insert accountMaps;
        
        List<Id> accountMapIds = new List<Id> {accMap1.Id, accMap2.Id, accMap3.Id, accMap4.Id, accMap4Dup.Id, accMap5.Id, accMap6.Id, accMap7.Id};
        Map<Id, Account_Mapping__c> actualResults = new map<Id, Account_Mapping__c>([select Id, Status__c, Note__c from Account_Mapping__c where Id in :accountMapIds]);
        
        Test.stopTest();
        System.assertEquals('Applied', actualResults.get(accMap1.Id).Status__c, 'AccountMap1 is not applied');
        System.assertEquals('Id:'+ acc1.Id, actualResults.get(accMap1.Id).Note__c, 'AccountMap1 is applied to the wrong account');
        
        System.assertEquals('Skipped', actualResults.get(accMap2.Id).Status__c, 'AccountMap2 is not skipped');
        System.assertEquals('SAP Account ID is null or empty', actualResults.get(accMap2.Id).Note__c, 'AccountMap2 error');
        
        System.assertEquals('Skipped', actualResults.get(accMap3.Id).Status__c, 'AccountMap3 is not skipped');
        System.assertEquals('Account name is null or empty', actualResults.get(accMap3.Id).Note__c, 'AccountMap3 error');
        
        System.assertEquals('Skipped', actualResults.get(accMap4.Id).Status__c, 'AccountMap4 is not skipped');
        System.assertEquals('Duplicate account name in the same batch', actualResults.get(accMap4.Id).Note__c,'AccountMap4 error');
        
        System.assertEquals('Skipped', actualResults.get(accMap4Dup.Id).Status__c, 'AccountMap4Dup is not skipped');
        System.assertEquals('Duplicate account name in the same batch', actualResults.get(accMap4Dup.Id).Note__c, 'AccountMap4Dup error');
        
        System.assertEquals('Skipped', actualResults.get(accMap5.Id).Status__c, 'AccountMap5 is not Skipped');
        System.assertEquals('Duplicate account name found in SF(' + acc5.Id + ',' + acc5Dup.Id + ')', actualResults.get(accMap5.Id).Note__c, 'AccountMap5 error');
        
        System.assertEquals('Skipped', actualResults.get(accMap6.Id).Status__c, 'AccountMap6 is not skipped');
        System.assertEquals('Id:' + acc6.id + ', Already have SAP Account ID', actualResults.get(accMap6.Id).Note__c, 'AccountMap6 error');
        
        System.assertEquals('Skipped', actualResults.get(accMap7.Id).Status__c, 'AccountMap7 is not skipped');
        System.assertEquals('New account', actualResults.get(accMap7.Id).Note__c, 'AccountMap7 error');
    }
}