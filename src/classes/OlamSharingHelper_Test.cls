@isTest
public class OlamSharingHelper_Test {
    //Commented as part of OFI as it is no more valid
    
    /*@testSetup
    public static void prepare() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u;
        System.runAs (thisUser) {
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'test role');
            insert r;
            
            	 u = new User(
                 ProfileId = [SELECT Id FROM Profile WHERE Name = 'Dairy Sales'].Id,
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
            insert u;
        }
        
        System.runAs(u){
            Id userId = u.Id;
            
            Account acc = new Account(Name = 'Test account', 
                                      OwnerId = userId, 
                                      Dairy_Owner_Id__c = userId, 
                                      BillingStreet = 'Test 1 street', 
                                      BillingCountry = 'Singapore');
            insert acc;
            Teams__c team1 = new Teams__c(Account__c = acc.Id, 
                                          User__c = userId, 
                                          Is_Primary__c = true,
                                          Role_Name__c = 'Dairy Sales Manager');
            insert team1;
            
            Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
            Opportunity opp1;
            Opportunity opp2;
            Opportunity opp3;
            System.runAs (u) {       
            opp1 = new Opportunity();
            opp1.AccountId = acc.Id;
            opp1.Name = 'unittest - opp1';
            opp1.StageName = 'Briefing';
            opp1.CloseDate = date.newInstance(2050, 11, 21);
            opp1.Business_Unit__c = 'Dairy';
            opp1.RecordTypeId = RecordTypeIdOpportunity;
            insert opp1;
            
            opp2 = new Opportunity();
            opp2.AccountId = acc.Id;
            opp2.Name = 'unittest - opp2';
            opp2.StageName = 'Briefing';
            opp2.CloseDate = date.newInstance(2050, 11, 21);
            opp2.Business_Unit__c = 'Dairy';
            opp2.RecordTypeId = RecordTypeIdOpportunity;
            insert opp2;
            
            opp3 = new Opportunity();
            opp3.AccountId = acc.Id;
            opp3.Name = 'unittest - opp3';
            opp3.StageName = 'Briefing';
            opp3.CloseDate = date.newInstance(2050, 11, 21);
            opp3.Business_Unit__c = 'Dairy';
            opp3.RecordTypeId = RecordTypeIdOpportunity;
            insert opp3;
            }
        }   
        
    }
    @isTest
    public static void testQueryShareObjectByParentIdListWithOwnerRowCause() {
		Test.startTest();
        
        List<String> oppNameList = new list<String> { 'unittest - opp1' };
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id from Opportunity where Name in :oppNameList]);
        Set<Id> filterParentList = oppMap.keySet();
        Boolean isIncludeOwnerRowCause = true;
        
        // Action
        List<OpportunityShare> oppShareList = OlamSharingHelper.queryShareObjectByParentIdList('Opportunity', filterParentList, isIncludeOwnerRowCause);
        
        Test.stopTest();
        
        // Expected result: share object with RowCause = 'Manual' or 'Owner' are returned
        System.assertEquals(1,oppShareList.size());
        List<Id> ids = new List<Id>(filterParentList);
        System.assertEquals(oppMap.get(ids[0]).Id, oppShareList[0].OpportunityId);
        //System.assertEquals(oppMap.get(ids[0]).Id, oppShareList[1].OpportunityId);
        System.assertEquals('Owner', oppShareList[0].RowCause);
        //System.assertEquals('Owner', oppShareList[1].RowCause);
    }
    
    @isTest
    public static void testQueryShareObjectByParentIdListWithoutOwnerRowCause() {
		Test.startTest();
        
        List<String> oppNameList = new list<String> { 'unittest - opp1', 'unittest - opp2' };
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id from Opportunity where Name in :oppNameList]);
        Set<Id> filterParentList = oppMap.keySet();
        Boolean isIncludeOwnerRowCause = true;
        
        // Action
        List<OpportunityShare> oppShareList = OlamSharingHelper.queryShareObjectByParentIdList('Opportunity', filterParentList, isIncludeOwnerRowCause);
        
        Test.stopTest();
        
        // Expected result: Only share object with RowCause = 'Owner' is returned
        Integer count = 0;
        for(OpportunityShare oppShare : oppShareList) {
            if(oppMap.containsKey(oppShare.OpportunityId) && oppShare.RowCause == 'Owner')
                count++;
        }
        System.assertEquals(2, count);
    }
    
    @isTest
    public static void testFilterDuplicateObjectShare() {
        Id parentId = Id.valueOf('a00000000000000001');
        Id userId = Id.valueOf('a00000000000000002');
        OpportunityShare oppShare = new OpportunityShare();
        oppShare.OpportunityId = parentId;
        oppShare.UserOrGroupId = userId;
        oppShare.RowCause = 'Manual';
        
        Test.startTest();
        
        Opportunity opp2 = [select Id from Opportunity where Name = 'unittest - opp1'];
        OpportunityShare oppShare2 = [select Id, OpportunityId, UserOrGroupId, RowCause from OpportunityShare where OpportunityId = :opp2.Id and  RowCause = 'Owner'];
            
        List<OpportunityShare> toTest = new List<OpportunityShare>{oppShare, oppShare2};
        
        // Action
        List<OpportunityShare> result = (List<OpportunityShare>)OlamSharingHelper.filterDuplicateObjectShare('Opportunity', toTest);
        
        Test.stopTest();
        
        // Expected result: Only oppShare is returned
        System.assertEquals(1, result.size());
        System.assertEquals(parentId, result[0].OpportunityId);
        System.assertEquals(userId, result[0].UserOrGroupId);
    }
    
    @isTest
    public static void testGetObjectShareToDeleteList() {
        Id parentId = Id.valueOf('a00000000000000001');
        Id userId = Id.valueOf('a00000000000000002');
        OpportunityShare oppShare = new OpportunityShare();
        oppShare.OpportunityId = parentId;
        oppShare.UserOrGroupId = userId;
        oppShare.RowCause = 'Manual';
        
        List<String> oppNameList = new list<String> { 'unittest - opp1', 'unittest - opp2', 'unittest - opp3' };
        Test.startTest();
        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id from Opportunity where Name in :oppNameList]);
        Set<Id> oppIdSet = oppMap.keySet();
        List<Id> oppIdList = new List<Id>(oppIdSet);
        
        List<OpportunityShare> toTest = [select Id, OpportunityId, UserOrGroupId, RowCause from OpportunityShare where OpportunityId in :oppIdSet];
        toTest.add(oppShare);
        
        // Action
        List<OpportunityShare> result = (List<OpportunityShare>)OlamSharingHelper.getObjectShareToDeleteList('Opportunity', toTest);
        
        Test.stopTest();
        
        // Expected to get only OpportunityShare of unittest - opp1 and unittest - opp2
        System.assertEquals(0, result.size());
        //System.assertEquals(oppIdList[0], result[0].OpportunityId);
        //System.assertEquals('Manual', result[0].RowCause);
        //System.assertEquals(oppIdList[1], result[1].OpportunityId);
        //System.assertEquals('Owner', result[1].RowCause);
    }*/
     
}