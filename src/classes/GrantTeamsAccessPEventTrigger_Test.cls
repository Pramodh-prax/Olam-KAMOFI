@isTest
public class GrantTeamsAccessPEventTrigger_Test {
  @testSetup
    public static void createData()
    {
        User user = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Dairy Sales'].Id, LastName = 'UnitTestUser1', Email = 'unittestuser000@unittestuser.com',
                             Username = 'unittestuser000@unittestuser.com' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title',
                             Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'//, Access_Set_Role__c = 'Sales'
                            );    
        insert user;
        Account acc = OFI_TestDataFactory.createAccount(true);
        Id pricebookId = Test.getStandardPricebookId();
        Access_Set__c access = OFI_TestDataFactory.createAccessSet('Country', null, 'IN', 'All', null, 'Nestle', null, true);
        Access_Set_Assignment__c assign = OFI_TestDataFactory.createAccessSetAssignment(access.Id, user.Id,// 'Sales',
                                                                                        true);
        Teams__c team = new Teams__c(Account__c = acc.Id, User__c = user.Id, Is_Primary__c = true, //Revoke_Access_Status__c = SharingUtility.TEAMS_REVOKEACCESSSTATUS_INITIATED,
                                     Business_Unit__c = 'All', Access_Level__c = 'Edit Access', //Access_Set_Role__c = 'Sales', 
                                     Access_Set_Ids__c = access.Id);
        insert team;        
        Opportunity opp = OFI_TestDataFactory.createOpportunity(acc, pricebookId, true);
        Consumption__c consume = OFI_TestDataFactory.createConsumption(acc.Id, 'Cocoa', 12, true);
        Budget_vs_Actuals__c budget = OFI_TestDataFactory.createBudget(acc.Id, 'Cocoa', true);
        Engagement_Plan__c engPlan = OFI_TestDataFactory.createEngagementPlan(acc.Id, 'Cocoa', true);
        Account_Plans__c accPlan = OFI_TestDataFactory.createAccountPlan(acc.Id, 'Cocoa', true);

    }
    public static testMethod void testschedule() {
        Grant_Account_Teams_Access__e grantAccountTeamsAccessEvent = new Grant_Account_Teams_Access__e ();
        Test.StartTest();
        Database.SaveResult result = Eventbus.publish(grantAccountTeamsAccessEvent);
        GrantTeamsAccessPEventScheduler testsche = new GrantTeamsAccessPEventScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
    public static testmethod void teamNonPrimary()
    {
        List <Teams__c> teamList = [Select id,Grant_Access_Status__c from Teams__c limit 1];
        Grant_Account_Teams_Access__e grantAccountTeamsAccessEvent = new Grant_Account_Teams_Access__e ();
        if(!teamList.isEmpty()){
            teamList[0].Access_Level__c = 'Read Access';
            teamList[0].Is_Primary__c = false;
            teamList[0].Business_Unit__c = 'Cocoa';
            update teamList[0];
        }
        Test.StartTest();
        Database.SaveResult result = Eventbus.publish(grantAccountTeamsAccessEvent);
        Test.stopTest();
    }
    public static testMethod void testschedule2() {
        List <Teams__c> teamList = [Select id,Grant_Access_Status__c from Teams__c limit 1];
        Grant_Account_Teams_Access__e grantAccountTeamsAccessEvent = new Grant_Account_Teams_Access__e ();
        if(!teamList.isEmpty()){
            teamList[0].Grant_Access_Status__c = SharingUtility.TEAMS_GRANTACCESSSTATUS_PROCESSED;
            update teamList[0];
        }
        Test.StartTest();
        Database.SaveResult result = Eventbus.publish(grantAccountTeamsAccessEvent);
        Test.stopTest();
    }
    //method to cover if retry log count less than 3
    public static testmethod void testScenario3()
    {
        List<Teams__c> team = [Select Id, Name, Account__c, User__c, Grant_Access_Status__c From Teams__c];
        Test.startTest();
        if(!team.isEmpty()){
            Retry_Log__c retry1 = new Retry_Log__c(Type__c = SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_GRANT_ACCESS, Account_Team__c = team[0].Id, Error_Message__c = 'Error Message1');
            insert retry1;
        }
        Grant_Account_Teams_Access__e grantAccountTeamsAccessEvent = new Grant_Account_Teams_Access__e ();
        Database.SaveResult result = Eventbus.publish(grantAccountTeamsAccessEvent);
        Test.stopTest();
    }
    //method to cover if retry log count more than 3
    public static testmethod void testScenario4()
    {
        List<Teams__c> team = [Select Id, Name, Account__c, User__c, Grant_Access_Status__c From Teams__c];
        Test.startTest();
        if(!team.isEmpty()){
            Retry_Log__c retry1 = new Retry_Log__c(Retry_Count__c = 3, Type__c = SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_GRANT_ACCESS, Account_Team__c = team[0].Id, Error_Message__c = 'Error Message1');
            insert retry1;
        }
        Grant_Account_Teams_Access__e grantAccountTeamsAccessEvent = new Grant_Account_Teams_Access__e ();
        Database.SaveResult result = Eventbus.publish(grantAccountTeamsAccessEvent);
        Test.stopTest();
    }
}