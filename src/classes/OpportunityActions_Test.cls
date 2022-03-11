@isTest
public class OpportunityActions_Test {
    
    public static void createTestUser(string lastName, Id profileId, Id roleId) {
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
        test.startTest();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            UserRole dairyRole = new UserRole(DeveloperName = 'Dairy_Something_Role', Name = 'Dairy Something');
            insert dairyRole;
            
            Id profileId = [SELECT Id FROM Profile WHERE Name = 'Dairy Sales'].Id;
            createTestUser('UnitTestDairyUser1', profileId, dairyRole.Id);
        }
        
        User user1 = [SELECT Id FROM User WHERE LastName = 'UnitTestDairyUser1'];
        Id userId1 = user1.Id;
        
       // System.runAs (user1) {
            // Create Account
            Account acc = new Account(Name = 'UNIT TEST account',   BillingStreet = 'Test 1 street', BillingCountry = 'Singapore');
            insert acc;
            
            Account acc2 = new Account(Name = 'UNIT TEST account2',  BillingStreet = 'Test 2 street', BillingCountry = 'Singapore');
            insert acc2;
            
            // Create new Products
            Product2 product1 = new Product2(Name = 'UNIT TEST Product 1');
            insert product1;
            
            Product2 product2 = new Product2(Name = 'UNIT TEST Product 2');
            insert product2;
            
            // Create asset and link to an account
            Asset asset = new Asset(Name = 'Approved SKU 1', 
                                    AccountId  = acc.Id, 
                                    Product2Id = product1.Id);
            insert asset;
            
            // Create Standard Pricebook
            //Instantiate the Pricebook2 record with StandardPricebookId
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            //Execute an update DML on the Pricebook2 record, to make IsStandard to true
            Update standardPricebook;
            
            // Create Pricebook Entry
            // SELECT Name, Id, Product2Id, IsActive, UnitPrice FROM PricebookEntry
            PricebookEntry pbEntry1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product1.Id, UnitPrice = 100, IsActive = true);
            insert pbEntry1;
            PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product2.Id, UnitPrice = 200, IsActive = true);
            insert pbEntry2;
             Id RecordTypeIdPresentOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
        	
            // Create Opportunity
          /*Opportunity opp = new Opportunity(AccountId = acc.Id, 
                                              OwnerId = userId1,
                                              Name = 'unittest - opp1',
                                              StageName = 'Briefing',
                                              CloseDate = date.newInstance(2050, 11, 21),
                                              Business_Unit__c = 'Dairy',
                                              RecordTypeId = RecordTypeIdPresentOpportunity,
                                              Pricebook2Id = standardPricebook.Id,
                                              Project_Type__c = 'Sample');
            insert opp;
            // Create new OpportunityLineItems
            OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id, 
                                                                       Product2Id = product1.Id, 
                                                                       PricebookEntryId = pbEntry1.Id,
                                                                       Sampling_Status__c = '5');
            insert oppLineItem1;
            
            OpportunityLineItem oppLineItem2 = new OpportunityLineItem(OpportunityId = opp.Id, 
                                                                       Product2Id = product2.Id, 
                                                                       PricebookEntryId = pbEntry2.Id,
                                                                       Sampling_Status__c = '5');
            insert oppLineItem2;
            
            Id RecordTypeIdDefendOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defend_Opportunity').getRecordTypeId();
            Opportunity opp2 = new Opportunity(AccountId = acc.Id, 
                                              OwnerId = userId1,
                                              Name = 'unittest - opp2',
                                              StageName = 'Briefing',
                                              CloseDate = date.newInstance(2050, 11, 21),
                                              Business_Unit__c = 'Dairy',
                                              RecordTypeId = RecordTypeIdDefendOpportunity,
                                              Pricebook2Id = standardPricebook.Id,
                                              Project_Type__c = 'Develop');
            insert opp2;
            OpportunityLineItem oppLineItem3 = new OpportunityLineItem(OpportunityId = opp2.Id, 
                                                                       Product2Id = product2.Id, 
                                                                       PricebookEntryId = pbEntry2.Id,
                                                                       Volume__c = 100,Sampling_Status__c = '5',UoM__c='KG');
            insert oppLineItem3;*/
            Id RecordTypeIdDefendOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defend_Opportunity').getRecordTypeId();

            Opportunity opp3 = new Opportunity(AccountId = acc2.Id, 
                                              OwnerId = userId1,
                                              Name = 'unittest - opp3',
                                              StageName = 'Briefing',
                                              CloseDate = date.newInstance(2050, 11, 21),
                                              Business_Unit__c = 'Dairy',
                                              RecordTypeId = RecordTypeIdDefendOpportunity,
                                              Pricebook2Id = standardPricebook.Id,
                                              Project_Type__c = 'Match');
            insert opp3;
            OpportunityLineItem oppLineItem4 = new OpportunityLineItem(OpportunityId = opp3.Id, 
                                                                       Product2Id = product2.Id, 
                                                                       PricebookEntryId = pbEntry2.Id,
                                                                       Quantity_of_Sample_Grams__c=1,Volume__c = 200,Sampling_Status__c = '5',UoM__c='KG');
            insert oppLineItem4;
          
            Opportunity opp4 = new Opportunity(AccountId = acc.Id, 
                                              OwnerId = userId1,
                                              Name = 'unittest - opp4',
                                              StageName = 'Briefing',
                                              CloseDate = date.newInstance(2050, 11, 21),
                                              Business_Unit__c = 'Dairy',
                                              RecordTypeId = RecordTypeIdDefendOpportunity,
                                              Pricebook2Id = standardPricebook.Id,
                                              Project_Type__c = 'Match');
            insert opp4;
           OpportunityLineItem oppLineItem6 = new OpportunityLineItem(OpportunityId = opp4.Id, 
                                                                       Product2Id = product1.Id, 
                                                                       PricebookEntryId = pbEntry2.Id,
                                                                        Quantity_of_Sample_Grams__c=1,Volume__c = 100,Sampling_Status__c = '5',UoM__c='KG');
            
            insert oppLineItem6;
            
            OpportunityLineItem oppLineItem5 = new OpportunityLineItem(OpportunityId = opp4.Id, 
                                                                       Product2Id = product1.Id, 
                                                                       PricebookEntryId = pbEntry1.Id,
                                                                        Quantity_of_Sample_Grams__c=1,Volume__c = 100,Sampling_Status__c = '8',UoM__c='KG');
            
            insert oppLineItem5;
            
 
           /* Opportunity opp5 = new Opportunity(AccountId = acc.Id, 
                                              OwnerId = userId1,
                                              Name = 'unittest - opp5',
                                              StageName = 'Briefing',
                                              CloseDate = date.newInstance(2050, 11, 21),
                                              Business_Unit__c = 'Dairy',
                                              RecordTypeId = RecordTypeIdDefendOpportunity,
                                              Pricebook2Id = standardPricebook.Id,
                                              Project_Type__c = 'Match');
            insert opp5;
            OpportunityLineItem oppLineItem7 = new OpportunityLineItem(OpportunityId = opp5.Id, 
                                                                       Product2Id = product2.Id, 
                                                                       PricebookEntryId = pbEntry2.Id,
                                                                      Sampling_Status__c = '5',UoM__c='KG');
            insert oppLineItem7;
            OpportunityLineItem oppLineItem8 = new OpportunityLineItem(OpportunityId = opp5.Id, 
                                                                       Product2Id = product2.Id, 
                                                                       PricebookEntryId = pbEntry2.Id,
                                                                       Sampling_Status__c = '5',UoM__c='KG');
            insert oppLineItem8;
            Opportunity opp6 = new Opportunity(AccountId = acc.Id, 
                                              OwnerId = userId1,
                                              Name = 'unittest - opp6',
                                              StageName = 'Briefing',
                                              CloseDate = date.newInstance(2050, 11, 21),
                                              Business_Unit__c = 'Dairy',
                                              RecordTypeId = RecordTypeIdDefendOpportunity,
                                              Pricebook2Id = standardPricebook.Id,
                                              Project_Type__c = 'Match');
            insert opp6;
            OpportunityLineItem oppLineItem9 = new OpportunityLineItem(OpportunityId = opp6.Id, 
                                                                       Product2Id = product2.Id, 
                                                                       PricebookEntryId = pbEntry2.Id,
                                                                       Volume__c = 100);
            insert oppLineItem9;
            OpportunityLineItem oppLineItem10 = new OpportunityLineItem(OpportunityId = opp6.Id, 
                                                                       Product2Id = product2.Id, 
                                                                       PricebookEntryId = pbEntry2.Id,
                                                                       Volume__c = 200);
            insert oppLineItem10;*/
            test.stopTest();
        //}
    }
    
    @isTest
    public static void testGetNewApprovedSKUList() {
      //  RunTest('UNIT TEST account', 'unittest - opp1');
    }
    
    @isTest
    public static void testGetNewApprovedSKUListOppHasDupProduct1() {
        Opportunity opp = [Select Id from Opportunity where Name = 'unittest - opp4'];
       // Id expectedOpportunityLineItemId = [Select Id from OpportunityLineItem where OpportunityId=:opp.Id and Volume__c = 100].Id;
        RunTest('UNIT TEST account', 'unittest - opp4');
    }
    
 /*   @isTest
    public static void testGetNewApprovedSKUListOppHasDupProduct2() {
      Opportunity opp = [Select Id from Opportunity where Name = 'unittest - opp5'];
      Id expectedOpportunityLineItemId = [Select Id from OpportunityLineItem where OpportunityId=:opp.Id Order by Id desc limit 1].Id;
      RunTest('UNIT TEST account', 'unittest - opp5', expectedOpportunityLineItemId);
    }
    
    @isTest
    public static void testGetNewApprovedSKUListOppHasDupProduct3() {
       Opportunity opp = [Select Id from Opportunity where Name = 'unittest - opp6'];
      Id expectedOpportunityLineItemId = [Select Id from OpportunityLineItem where OpportunityId=:opp.Id Order by Id desc limit 1].Id;
      RunTest('UNIT TEST account', 'unittest - opp6', expectedOpportunityLineItemId);
    }*/
    
    @isTest
    public static void testGetNewApprovedSKUListWithNoDup() {
      //  RunTest('UNIT TEST account', 'unittest - opp2');
    }
    
    @isTest
    public static void testGetNewApprovedSKUListWithAccountNoApprovedSKU() {
        RunTest('UNIT TEST account2', 'unittest - opp3');
    }
    
    private static void RunTest(String accountName, String opportunityName) {
        RunTest(accountName, opportunityName, NULL);
    }
    
    private static void RunTest(String accountName, String opportunityName, Id expectedOpportunityLineItemId) {
        Test.startTest();
        // Arrange
        Account acc = [Select Id from Account where Name = :accountName];
        Opportunity opp = [Select Id from Opportunity where Name = :opportunityName];
        
        OpportunityActions.ClosedWonNewApprovedSKURequest request = new OpportunityActions.ClosedWonNewApprovedSKURequest();
        request.oppId = opp.Id;
        request.accId = acc.Id;
        List<OpportunityActions.ClosedWonNewApprovedSKURequest> requests = new List<OpportunityActions.ClosedWonNewApprovedSKURequest>{request};
      
        // Action
        List<OpportunityActions.ClosedWonNewApprovedSKUResponse> result = OpportunityActions.GetNewApprovedSKUList(requests);

        Product2 expectedProduct = [Select Id from Product2 where Name = 'UNIT TEST Product 2'];
         
        
            
        Test.stopTest();
        // Assert
        
        System.assertEquals(1, result.size(), 'Got result more than 1 when input just 1');
        System.assertEquals(opp.Id, result[0].oppId, 'Result oppId not match with Input');
        System.assertEquals(1, result[0].newApprovedSKUList.size(), 'Incorrect size of returned newApprovedSKUList');
        System.assertEquals(opp.Id, result[0].newApprovedSKUList[0].OpportunityId, 'Result oppId in OpportunityLineItem does not match with Input');
        if(expectedOpportunityLineItemId == NULL)
            System.assertEquals(expectedProduct.Id, result[0].newApprovedSKUList[0].Product2Id, 'Incorrect Product2Id returned from function');
        else
            System.assertEquals(expectedOpportunityLineItemId, result[0].newApprovedSKUList[0].Id, 'Incorrect OpportunityLineItem Id returned from function');    
    }   
}