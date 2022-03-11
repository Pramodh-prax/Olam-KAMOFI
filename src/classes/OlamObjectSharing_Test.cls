@isTest
public class OlamObjectSharing_Test {
    //Commented as part of OFI as it is no more valid
    
    /*@testSetup
    public static void prepare() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'Dairy Something');
            insert r;
            
            Id profileId = [SELECT Id FROM Profile WHERE Name = 'Dairy Sales'].Id;
            User u1 = new User(
                 ProfileId = profileId,
                 LastName = 'UnitTestUser1',
                 Email = 'unittestuser000@unittestuser.com',
                 Username = 'unittestuser000@unittestuser.com' + System.currentTimeMillis(),
                 CompanyName = 'TEST',
                 Title = 'title',
                 Alias = 'alias',
                 TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8',
                 LanguageLocaleKey = 'en_US',
                 LocaleSidKey = 'en_US',
                 UserRoleId = r.Id
            );    
            insert u1;
            
            User u2 = new User(
                 ProfileId = profileId,
                 LastName = 'UnitTestUser2',
                 Email = 'unittestuser002@unittestuser.com',
                 Username = 'unittestuser002@unittestuser.com' + System.currentTimeMillis(),
                 CompanyName = 'TEST',
                 Title = 'title',
                 Alias = 'alias',
                 TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8',
                 LanguageLocaleKey = 'en_US',
                 LocaleSidKey = 'en_US',
                 UserRoleId = r.Id
            );    
            insert u2;
        }
        
        List<String> userListString = new List<String>{'UnitTestUser1', 'UnitTestUser2'};
        List<User> userList = [SELECT Id FROM User WHERE LastName in :userListString];
        Id userId1 = userList[0].Id;
        Id userId2 = userList[1].Id;
        
        Account acc;
        Opportunity opp1;
        System.runAs (userList[0]) {
            acc = new Account(Name = 'UNIT TEST account', 
                                      OwnerId = userId1,
                                      BillingStreet = 'Test 1 street', 
                                      BillingCountry = 'Singapore');
            insert acc;
       
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
        
        opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'unittest - opp1';
		opp1.StageName = 'Briefing';
		opp1.CloseDate = date.newInstance(2050, 11, 21);
        opp1.Business_Unit__c = 'Dairy';
        opp1.RecordTypeId = RecordTypeIdOpportunity;
        insert opp1;
        }
        Teams__c team1Check = [Select Account__c, User__c 
                                 from Teams__c 
                                 where Account__c=:acc.Id and 
                                     User__c=:userId1 and 
                                     Is_Primary__c=true and 
                                     Role_Name__c='Dairy Sales Manager'];
        
        //System.runAs (userList[0]) {
        //    Teams__c team1 = new Teams__c(Account__c = acc.Id, 
        //                                  User__c = userId1, 
        //                                  Is_Primary__c = true,
        //                                  Role_Name__c = 'Dairy Sales Manager');
        //    insert team1;
        //}
        
       System.runAs (userList[0]) {
            Teams__c team2 = new Teams__c(Account__c = acc.Id,
                                         User__c = userId2,
                                         Is_Primary__c = false,
                                         Role_Name__c = 'Dairy Sales Manager');
            insert team2;
       }
    }
    
	@isTest
    public static void testAddSharingOpportunity() {
        // Arrange
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
        
        Test.startTest();
        List<String> userListString = new List<String>{'UnitTestUser1', 'UnitTestUser2'};
		List<User> userList = [SELECT Id FROM User WHERE LastName in :userListString];
        Opportunity newOpp;
        Account acc = [select Id from Account where Name = 'UNIT TEST account'];
        
        System.runAs(userList[0]){
            
		newOpp = new Opportunity(AccountId = acc.Id, 
                                             Name = 'unittest - opp3', 
                                             StageName = 'Briefing', 
                                             CloseDate = date.newInstance(2050, 11, 21), 
                                             Business_Unit__c = 'Dairy', 
                                             RecordTypeId = RecordTypeIdOpportunity);
        // Action
        insert newOpp;
        }
        // Assert
        List<OpportunityShare> result = [select Id, OpportunityId, UserOrGroupId, RowCause from OpportunityShare where OpportunityId = :newOpp.Id and RowCause In('Manual','Owner') Order by RowCause];
        
        userList = [SELECT Id FROM User WHERE LastName in :userListString];
        
        System.debug('ttt '+result);
        
        Test.stopTest();
        System.assertEquals(2, result.size());
        System.assertEquals(newOpp.Id, result[0].OpportunityId);
        System.assertEquals(newOpp.Id, result[1].OpportunityId);
        System.assertEquals(userList[1].Id, result[0].UserOrGroupId);
        System.assertEquals(userList[0].Id, result[1].UserOrGroupId);
        System.assertEquals('Manual', result[0].RowCause);
        System.assertEquals('Owner', result[1].RowCause);
    }
    
    @isTest
    public static void testAddSharingConsumption() {
        // Arrange
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
        
        Test.startTest();
                
        Date d = date.newInstance(2050, 11, 21);
        Account acc = [select Id from Account where Name = 'UNIT TEST account'];
		Consumption__c newConsumption = new Consumption__c(Account__c = acc.id, 
                                                           Business_Unit__c = 'Dairy', 
                                                           Coverage__c = d, 
                                                           Review_Date__c = d, 
                                                           Volume_MT__c = 1, 
                                                           Brands__c = 'Fonterra');
        // Action
        insert newConsumption;

        // Assert
        List<Consumption__Share> result = [select Id, ParentId, UserOrGroupId, RowCause from Consumption__Share where ParentId = :newConsumption.Id and RowCause = 'Manual'];
        
        List<String> userListString = new List<String>{'UnitTestUser1', 'UnitTestUser2'};
        List<User> userList = [SELECT Id FROM User WHERE LastName in :userListString];
        
        Test.stopTest();
        
        System.assertEquals(2, result.size());
        System.assertEquals(newConsumption.Id, result[0].ParentId);
        System.assertEquals(newConsumption.Id, result[1].ParentId);
        System.assertEquals(userList[0].Id, result[0].UserOrGroupId);
        System.assertEquals(userList[1].Id, result[1].UserOrGroupId);
        System.assertEquals('Manual', result[0].RowCause);
        System.assertEquals('Manual', result[1].RowCause);
    }
    
    @isTest
    public static void testAddSharingInteraction() {
        // Arrange
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
        
        Test.startTest();
        
        Account acc = [select Id from Account where Name = 'UNIT TEST account'];
		Interactions__c newInteraction = new Interactions__c(Account__c = acc.id, 
                                                           Business_Unit__c = 'Dairy');
        // Action
        insert newInteraction;

        // Assert
        List<Interactions__Share> result = [select Id, ParentId, UserOrGroupId, RowCause from Interactions__Share where ParentId = :newInteraction.Id and RowCause = 'Manual'];

        List<String> userListString = new List<String>{'UnitTestUser1', 'UnitTestUser2'};
        List<User> userList = [SELECT Id FROM User WHERE LastName in :userListString];
        
        Test.stopTest();
        
        System.assertEquals(2, result.size());
        System.assertEquals(newInteraction.Id, result[0].ParentId);
        System.assertEquals(newInteraction.Id, result[1].ParentId);
        System.assertEquals(userList[0].Id, result[0].UserOrGroupId);
        System.assertEquals(userList[1].Id, result[1].UserOrGroupId);
        System.assertEquals('Manual', result[0].RowCause);
        System.assertEquals('Manual', result[1].RowCause);
    }*/
}