@isTest
public class OlamTeamSharing_Test {
    
    //Commented as part of OFI as it is no more valid
    
    /*public static void createTestUser(string lastName, Id profileId, Id roleId) {
        User user = new User(
                 ProfileId = profileId,
                 LastName = lastName,
                 Email = lastName + '@unittestuser.com',
                 Username = lastName + '@unittestuser.com' + System.currentTimeMillis(),
                 CompanyName = 'TEST',
                 Title = 'title',
                 Alias = 'alias',
                 TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8',
                 LanguageLocaleKey = 'en_US',
                 LocaleSidKey = 'en_US',
                 UserRoleId = roleId
            );    
        insert user;
    }
    
	@testSetup
    public static void prepare() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            UserRole dairyRole = new UserRole(DeveloperName = 'Dairy_Something_Role', Name = 'Dairy Something');
            insert dairyRole;
            
            UserRole cocoaRole = new UserRole(DeveloperName = 'Cocoa_Something_Role', Name = 'Cocoa Something');
            insert cocoaRole;
            
            UserRole spiceRole = new UserRole(DeveloperName = 'Spice_Something_Role', Name = 'Spice Something');
            insert spiceRole;
            
            UserRole EdibleNutsRole = new UserRole(DeveloperName = 'Edible_Nuts_Something_Role', Name = 'Edible_Nuts Something');
            insert EdibleNutsRole;
            
            Id profileId = [SELECT Id FROM Profile WHERE Name = 'Dairy Sales'].Id;
            Id cocoaProfileId = [SELECT Id FROM Profile WHERE Name = 'Cocoa Sales'].Id;
            Id spiceProfileId = [SELECT Id FROM Profile WHERE Name = 'Spices Sales'].Id;
            Id EdibleNutsProfileId = [SELECT Id FROM Profile WHERE Name = 'Edible_Nuts Sales'].Id;
            
            createTestUser('UnitTestDairyUser1', profileId, dairyRole.Id);
            createTestUser('UnitTestDairyUser2', profileId, dairyRole.Id);
            createTestUser('UnitTestCocoaUser1', cocoaProfileId, cocoaRole.Id);
            createTestUser('UnitTestSpiceUser1', spiceProfileId, spiceRole.Id);
            createTestUser('UnitTestEdibleNutsUser1', EdibleNutsProfileId, EdibleNutsRole.Id);
        }
        
        User user1 = [SELECT Id FROM User WHERE LastName = 'UnitTestDairyUser1'];
        Id userId1 = user1.Id;
        
        System.runAs (user1) {
            // Create Account
            Account acc = new Account(Name = 'UNIT TEST account',
                                      OwnerId = userId1,
                                      BillingStreet = 'Test 1 street',
                                      BillingCountry = 'Singapore');
            insert acc;
            
    
            
            // Create Opportunity
            Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
            Opportunity opp = new Opportunity(AccountId = acc.Id, 
                                              OwnerId = userId1,
                                              Name = 'unittest - opp1',
                                              StageName = 'Briefing',
                                              CloseDate = date.newInstance(2050, 11, 21),
                                              Business_Unit__c = 'Dairy',
                                              RecordTypeId = RecordTypeIdOpportunity);
            insert opp;
            
            // Create Consumption
            Date d = date.newInstance(2050, 11, 21);
            Consumption__c consumption = new Consumption__c(Account__c = acc.id, 
                                                            OwnerId = userId1,
                                                               Business_Unit__c = 'Dairy', 
                                                               Coverage__c = d, 
                                                               Review_Date__c = d, 
                                                               Volume_MT__c = 1, 
                                                               Brands__c = 'Fonterra');
            insert consumption;
            
            // When new account is created, Process Builder - Account Automation will create a new Team and Interaction record 
            // with same BU as System.runAs user
            // So no need to manually create Interaction
            //**************************
            // Create Interaction
            // Interactions__c interaction = new Interactions__c(Account__c = acc.id, 
            //                                                   Business_Unit__c = 'Dairy');
            // insert interaction;
         
        }
   }
    
    @isTest
    public static void testAddingAndRemovingNewDairyTeamMember() {
        
        Test.startTest();
        // Arrange
        Account acc = [select Id from Account where Name = 'UNIT TEST account'];
        User dairyUser1 = [SELECT Id FROM User WHERE LastName = 'UnitTestDairyUser1'];
        User dairyUser2 = [SELECT Id FROM User WHERE LastName = 'UnitTestDairyUser2'];
        
        Teams__c team2;
        System.runAs (dairyUser1) {
            team2 = new Teams__c(Account__c = acc.Id,
                                         User__c = dairyUser2.Id,
                                         Is_Primary__c = false,
                                         Role_Name__c = 'Dairy Sales Manager');
            // Action : Adding new team member
            insert team2;
        }
        
        // Assert
        List<OpportunityShare> oppShareResult = [select Id, OpportunityId, UserOrGroupId, RowCause from OpportunityShare where UserOrGroupId = :dairyUser2.Id and RowCause = 'Manual'];
        List<Consumption__Share> conShareResult = [select Id, ParentId, UserOrGroupId, RowCause from Consumption__Share where UserOrGroupId = :dairyUser2.Id and RowCause = 'Manual'];
        List<Interactions__Share> intShareResult = [select Id, ParentId, UserOrGroupId, RowCause from Interactions__Share where UserOrGroupId = :dairyUser2.Id and RowCause = 'Manual'];
        
        Opportunity opp = [select Id from Opportunity where AccountId = :acc.Id];
        Consumption__c consumption = [select Id from Consumption__c where Account__c = :acc.Id];
        Interactions__c interaction = [select Id from Interactions__c where Account__c = :acc.Id];
        
        // Expected result: A Manual Sharing will be created for each Opportunity, Consumption and Interaction for this new teammember
        System.assertEquals(1, oppShareResult.size(), 'Adding new team member does not crate sharing for Opportunity correctly');
        System.assertEquals(1, conShareResult.size(), 'Adding new team member does not crate sharing for Consumption correctly');
        System.assertEquals(1, intShareResult.size(), 'Adding new team member does not crate sharing for Interactions correctly');
        System.assertEquals(opp.Id, oppShareResult[0].OpportunityId);
        System.assertEquals(consumption.Id, conShareResult[0].ParentId);
        System.assertEquals(interaction.Id, intShareResult[0].ParentId);
        
        // Action : Removing new team member
        delete team2;
        
        // Assert
        oppShareResult = [select Id, OpportunityId, UserOrGroupId, RowCause from OpportunityShare where UserOrGroupId = :dairyUser2.Id and RowCause = 'Manual'];
        conShareResult = [select Id, ParentId, UserOrGroupId, RowCause from Consumption__Share where UserOrGroupId = :dairyUser2.Id and RowCause = 'Manual'];
        intShareResult = [select Id, ParentId, UserOrGroupId, RowCause from Interactions__Share where UserOrGroupId = :dairyUser2.Id and RowCause = 'Manual'];

        Test.stopTest();
        
        // Expected result: NO Manual Sharing left for this user
        System.assertEquals(0, oppShareResult.size(), 'Removing new team member does not remove sharing for Opportunity');
        System.assertEquals(0, conShareResult.size(), 'Removing new team member does not remove sharing for Consumption');
        System.assertEquals(0, intShareResult.size(), 'Removing new team member does not remove sharing for Interactions');
    }

    @isTest
    public static void testClearDiaryOwnerOnAccount() {
        
        Test.startTest();
        
        Account acc = [select Id from Account where Name = 'UNIT TEST account'];
        Teams__c dairyPrimary = [SELECT Id, Account__c FROM Teams__c WHERE Account__c = :acc.id and Role_Name__c = 'Dairy Sales Manager' and Is_Primary__c = true];
        
        // Action
        delete dairyPrimary;
        
        // Assert
        acc = [select Id, Dairy_Owner_Id__c from Account where id = :acc.id];
        
        Test.stopTest();
        
        System.assertEquals(null, acc.Dairy_Owner_Id__c, 'Removing Dairy primary team member does not clear Dairy owner in Account');
    }
    
    @isTest
    public static void testClearCocoaOwnerOnAccount() {
        
        Test.startTest();
        User cocoaUser = [SELECT Id FROM User WHERE LastName = 'UnitTestCocoaUser1'];
        
        Account acc;
        System.runAs (cocoaUser) {
            acc = new Account(Name = 'COCOA Unit test Account2',
                                          OwnerId = cocoaUser.Id,
                                          BillingStreet = 'Test 1 street',
                                          BillingCountry = 'Singapore');
            insert acc;
        }
        
        acc = [select Id, Cocoa_Owner__c from Account where id = :acc.id];
        System.assertEquals(cocoaUser.Id, acc.Cocoa_Owner__c, 'Account Cocoa owner is not set when adding new Primary Cocoa team member');
        Teams__c cocoaPrimary = [SELECT Id, Account__c FROM Teams__c WHERE Account__c = :acc.id and Role_Name__c = 'Cocoa Sales Manager' and Is_Primary__c = true];
        
        // Action
        delete cocoaPrimary;
        
        // Assert
        acc = [select Id, Cocoa_Owner__c from Account where id = :acc.id];
        
        Test.stopTest();
        
        System.assertEquals(null, acc.Cocoa_Owner__c, 'Removing Dairy primary team member does not clear Dairy owner in Account');
    }
    
    @isTest
    public static void testClearSpiceOwnerOnAccount() {
        
        Test.startTest();
        User spiceUser = [SELECT Id FROM User WHERE LastName = 'UnitTestSpiceUser1'];
        Account acc;
        System.runAs (spiceUser) {
            acc = new Account(Name = 'Spice Unit test Account2',
                                          OwnerId = spiceUser.Id,
                                          BillingStreet = 'Test 1 street',
                                          BillingCountry = 'Singapore');
            insert acc;
        }
        
        acc = [select Id, Spice_Owner_Id__c from Account where id = :acc.id];
        System.assertEquals(spiceUser.Id, acc.Spice_Owner_Id__c, 'Account Spice owner is not set when adding new Primary Spice team member');
        Teams__c spicePrimary = [SELECT Id, Account__c FROM Teams__c WHERE Account__c = :acc.id and Role_Name__c = 'Spice Sales Manager' and Is_Primary__c = true];
        
        // Action
        delete spicePrimary;
        
        // Assert
        acc = [select Id, Spice_Owner_Id__c from Account where id = :acc.id];
        
        Test.stopTest();
        
        System.assertEquals(null, acc.Spice_Owner_Id__c, 'Removing Spice primary team member does not clear Spice owner in Account');
    }
    @isTest
     public static void testClearEdibleNutsOwnerOnAccount() {
        
        Test.startTest();
        User EdibleNutsUser = [SELECT Id FROM User WHERE LastName = 'UnitTestEdibleNutsUser1'];
        Account acc;
        System.runAs (EdibleNutsUser) {
            acc = new Account(Name = 'Edible Nuts Unit test Account2',
                                          OwnerId = EdibleNutsUser.Id,
                                          BillingStreet = 'Test 1 street',
                                          BillingCountry = 'Singapore');
            insert acc;
        }
        
        acc = [select Id, Edible_Nuts_Owner_Id__c from Account where id = :acc.id];
        System.assertEquals(EdibleNutsUser.Id, acc.Edible_Nuts_Owner_Id__c, 'Account Edible Nuts owner is not set when adding new Primary Edible Nuts team member');
        Teams__c EdibleNutsPrimary = [SELECT Id, Account__c FROM Teams__c WHERE Account__c = :acc.id and Role_Name__c = 'Edible_Nuts Sales Manager' and Is_Primary__c = true];
        
        // Action
        delete EdibleNutsPrimary;
        
        // Assert
        acc = [select Id, Edible_Nuts_Owner_Id__c from Account where id = :acc.id];
        
        Test.stopTest();
        
        System.assertEquals(null, acc.Edible_Nuts_Owner_Id__c, 'Removing Edible Nuts primary team member does not clear Edible Nuts owner in Account');
    }
*/
    
}