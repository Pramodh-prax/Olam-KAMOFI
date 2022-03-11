@isTest
public class CreateAccountTeamsPEventTrigger_Test {
    @testSetup
    public static void createData()
    {
        User user = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Dairy Sales'].Id, LastName = 'UnitTestUser1', Email = 'unittestuser000@unittestuser.com',
                             Username = 'unittestuser000@unittestuser.com' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title',
                             Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'
                             //,Access_Set_Role__c = 'Sales'
                             );    
        insert user;
        User user2 = new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Cocoa Sales'].Id, LastName = 'UnitTestUser2', Email = 'unittestuser000@unittestuser.com2',
                             Username = 'unittestuser000@unittestuser.com2' + System.currentTimeMillis(), CompanyName = 'TEST', Title = 'title',
                             Alias = 'alias', TimeZoneSidKey = 'America/Los_Angeles', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'
                             //,Access_Set_Role__c = 'Sales'
                             );    
        insert user2;
        
        Account acc = OFI_TestDataFactory.createAccount(true);
        Id pricebookId = Test.getStandardPricebookId();
        Access_Set__c access = OFI_TestDataFactory.createAccessSet('Country', null, 'IN', 'Cocoa', null, 'Nestle', null, true);
        Access_Set_Assignment__c assign = OFI_TestDataFactory.createAccessSetAssignment(access.Id, user.Id, //'Sales',
          																				true);
        /*Account acc2 = OFI_TestDataFactory.createMultipleAccount('demo acc', 'Singapore', 'SG', 'APAC', null, null, true);                                                                                
                     Access_Set__c    access2 = OFI_TestDataFactory.createAccessSet('Region', 'APAC', null, 'All', null, null, null, true);                                                               
        Access_Set_Assignment__c assign2 = OFI_TestDataFactory.createAccessSetAssignment(access2.Id, user2.Id, //'Sales',
                                                                                         true);*/
      Teams__c team = new Teams__c(Account__c = acc.Id, User__c = user2.Id, Is_Primary__c = false, Business_Unit__c = 'All', 
                                     Access_Level__c = 'Read Access', //Access_Set_Role__c = 'Sales', 
                                     Access_Set_Ids__c = access.Id);
        insert team;
    }
    
    public static testMethod void testschedule() {
        Test.StartTest();
        CreateAccountTeamsPEventScheduler testsche = new CreateAccountTeamsPEventScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
    public static testMethod void testschedule2() {
        List <Access_Set_Assignment__c> assignList = [Select Id,Account_Teams_Creation_Status__c from Access_Set_Assignment__c limit 1];
        Create_Account_Team__e createAccountTeamsPEvent = new Create_Account_Team__e ();
        Test.StartTest();
        if(!assignList.isEmpty()){
            assignList[0].Account_Teams_Creation_Status__c = SharingUtility.ACCOUNT_TEAM_CREATION_STATUS_PROCESSED;
            update assignList[0];
        }
        
        Database.SaveResult result = Eventbus.publish(createAccountTeamsPEvent);
        Test.stopTest();
    }
    //method to cover if retry log count less than 3
     @isTest
    static void testValidScenario3() {
        List<Access_Set_Assignment__c> assign = [Select Id, user__c, Access_set__c, Account_Teams_Creation_Status__c From Access_Set_Assignment__c];
        Create_Account_Team__e createAccountTeamsPEvent = new Create_Account_Team__e ();
        Test.startTest();
        if(!assign.isEmpty())
        {
        Retry_Log__c retry1 = new Retry_Log__c(Type__c = SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_CREATION, Access_Set_Assignment__c = assign[0].Id, Error_Message__c = 'Error Message1');
        insert retry1;
        }
        Database.SaveResult result = Eventbus.publish(createAccountTeamsPEvent);
        Test.stopTest();
    }
    //method to cover if retry log count more than 3
     @isTest
    static void testValidScenario4() {
        List<Access_Set_Assignment__c> assign = [Select Id, user__c, Access_set__c, Account_Teams_Creation_Status__c From Access_Set_Assignment__c];
        Create_Account_Team__e createAccountTeamsPEvent = new Create_Account_Team__e ();
        Test.startTest();
        if(!assign.isEmpty())
        {
        Retry_Log__c retry1 = new Retry_Log__c(Retry_Count__c = 3, Type__c = SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_CREATION, Access_Set_Assignment__c = assign[0].Id, Error_Message__c = 'Error Message1');
        insert retry1;
        }
        Database.SaveResult result = Eventbus.publish(createAccountTeamsPEvent);
        Test.stopTest();
    }
	 public static testMethod void testscheduleCatch() {
        Test.StartTest();
         //User user = [Select Id, Name From User where Email =: ]
        // Access_Set__c access = OFI_TestDataFactory.createAccessSet('Country', null, 'IN', 'Cocoa', null, 'Nestle', null, true);
        //Access_Set_Assignment__c assign = OFI_TestDataFactory.createAccessSetAssignment(access.Id, user.Id, //'Sales',
         // 																				true);
         
        /*List<Access_Set_Assignment__c> assign = [Select Id,Name,Account_Teams_Creation_Status__c From Access_Set_Assignment__c];
        assign[0].Account_Teams_Creation_Status__c = SharingUtility.ACCOUNT_TEAM_CREATION_STATUS_FAILED ;
         update assign;*/
         Test.stopTest();
    }
    
}