@isTest
public class KAM_AccountPlanListCntlTest {
    static testMethod void testMethod1() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Testcity';
        acc.BillingCountry = 'india';
        insert acc;
        
        Account_Plans__c ap=new Account_Plans__c();
        ap.Account__c=acc.Id;
        ap.Name='TestPlan';
        ap.Description__c='This is test AccountPlan';
        ap.StartDate__c=system.today();
        ap.EndDate__c=system.today().addDays (365);
        ap.Type__c='Group';
        ap.BU_Identifier__c='Cocoa';
        ap.Year__c=String.valueOf(System.today().year ());
        insert ap;
        
        KAM_AccountPlanListCntl.getAccountPlans(acc.Id);
        KAM_AccountPlanListCntl.getAccountTeams(acc.Id);
        KAM_AccountPlanListCntl.getUserBU();
        KAM_AccountPlanListCntl.getCustomPermission();
        KAM_AccountPlanListCntl.deleteAccountPlan(ap.Id);
        
    }
    
    static testMethod void KAM_AccountPlanPopupCntlTest() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Testcity';
        acc.BillingCountry = 'india';
        insert acc;
        Account_Plans__c app = new Account_Plans__c();
        app.Name = 'test';
        app.Account__c = acc.id;
        insert app;
        KAM_AccountPlanPopupCntl.getAccountPlan(app.Id);
    }

}