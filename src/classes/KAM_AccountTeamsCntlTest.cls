@isTest
public class KAM_AccountTeamsCntlTest {
 @testSetUp
    static void createData () {
         Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Testcity';
        acc.BillingCountry = 'india';
        acc.Customer_Group__c='Test Group';
        insert acc;
        
         Account acc1 = new Account();
        acc1.Name = 'Test1';
        acc1.BillingCity = 'Testcity';
        acc1.BillingCountry = 'india';
        acc1.Customer_Group__c='Test Group';
        insert acc1;
         
         Account_Plans__c app = new Account_Plans__c();
        app.Name = 'test';
        app.Account__c = acc.id;
        insert app;
        
        Account_Plans__c app1 = new Account_Plans__c();
        app1.Name = 'test1';
        app1.Account__c = acc1.id;
         app1.Type__c='group';
        insert app1;
        
        Account_Plans__c app_group = new Account_Plans__c();
        app_group.Name = 'testGrp';
        app_group.Account__c = acc.id;
        app_group.Type__c='group';
        app_group.BU_Identifier__c='Cocoa';
        insert app_group; 
        
        Teams__c team=new Teams__c();
        team.Account__c= acc.id;
        team.Is_Primary__c=true;
        team.Business_Unit__c = 'All';
       insert team;
         
          }
    @isTest 
    static void testGetDetails () {
        Account acc=[select id from account where name='Test'];
        
         Account_Plans__c app=[select id,Account__c,name,BU_Identifier__c,Type__c,Customer_Group__c from Account_Plans__c where name='testGrp'];
        string result= KAM_AccountTeamsCntl.getDetails( JSON.serialize(new Map<String, Object> {'accountId' => acc.Id}));
         System.assert(result != null , 'Unable to get details');
         KAM_AccountTeamsCntl.getDetails( JSON.serialize(new Map<String, Object> {'accountId' => null}));
         string result1= KAM_AccountTeamsCntl.getDetails( JSON.serialize(app));
        
    }
     @isTest 
    static void TestgetGroupDetails () {
        Account acc=[select id from account where name='Test'];
         Account_Plans__c app1=[select id,Account__c,name,BU_Identifier__c,Type__c,Customer_Group__c from Account_Plans__c where name='test'];
        Account_Plans__c app=[select id,Account__c,name,BU_Identifier__c,Type__c,Customer_Group__c from Account_Plans__c where name='testGrp'];
        string result= KAM_AccountTeamsCntl.getGroupDetails( JSON.serialize(new Map<String, Object> {'accountPlan' =>app}));
         System.assert(result != null , 'Unable to get details');
         string result1= KAM_AccountTeamsCntl.getGroupDetails( JSON.serialize(acc));
        KAM_AccountTeamsCntl.getGroupDetails(  JSON.serialize(new Map<String, Object> {'accountPlan' =>app1}));
        
        
    }
    @isTest 
    static void TestgetAccountTeamsForGroup()
    {
      Account acc=[select id from account where name='Test'];
      List<object> result= KAM_AccountTeamsCntl.getAccountTeamsForGroup(acc.Id);
         System.assert(result != null && !result.isEmpty () , 'Unable to get details');
      KAM_AccountTeamsCntl.getAccountTeamsForGroup(null);  
    }
}