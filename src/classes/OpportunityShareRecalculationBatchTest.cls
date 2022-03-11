@isTest(SeeAllData=false)
public class OpportunityShareRecalculationBatchTest {
    //Commented as part of OFI as it is no more valid
    
	/*
	  @testSetup static void setupData() {
		UserRole role = [select id,name from UserRole where name LIKE '%Cocoa%' limit 1];
        Profile prof = [select id,name from profile where name LIKE '%Cocoa%' limit 1];
        
        List<User> userList = new List<User>();
        userList.add(TestUtility.getUser(prof.Id, role.Id, 'test.olam@olamtest.com.test1', 'OLITest1', 'OLITest1', 'OLITest1'));
        userList.add(TestUtility.getUser(prof.Id, role.Id, 'test.olam@olamtest.com.test2', 'OLITest2', 'OLITest2', 'OLITest2'));
        insert userList;
        
        System.runAs(userList[0]){
            Account acc = new Account(
            	Name='TestOLI1',
            	BillingCountry = 'India',
            	BillingStreet ='Test'
            );
            insert acc;
            
            Opportunity opp = new Opportunity(
            	Name = 'TestOLI1',
                AccountId = acc.Id,
                Business_Unit__c = 'Cocoa',
                StageName = 'Briefing',
                CloseDate = System.Today(),
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId()
            );
            insert opp;
            
            Teams__c team = new Teams__c(
                Account__c = acc.Id,
                User__c = userList[1].Id,
                User_Role_Name__c = 'Cocoa Sales Manager',
                Role_Name__c = 'Cocoa Sales Manager',
                Is_Primary__c = false
            );
        	insert team;
        }
	}*/
    
    @isTest static void testOne() {
        //Commented as part of OFI as it is no more valid
        
        /*Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		DELETE [SELECT Id FROM OpportunityShare WHERE OpportunityId = :opp.Id AND RowCause = 'Manual' LIMIT 10];*/
        
        Test.startTest();
        Database.executeBatch(new OpportunityShareRecalculationBatch());
        Test.stopTest();
    }
}