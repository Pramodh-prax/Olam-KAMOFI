@isTest
public class KAM_AccountPlanSharePopupCntlTest {
    static testMethod void testMethod1() {
        String objname='Account_Plans__c';
        String apiName='Type__c';
        Boolean nullreq = true;
         Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Testcity';
        acc.BillingCountry = 'india';
        insert acc;
        Account_Plans__c app = new Account_Plans__c();
        app.Name = 'test';
        app.Account__c = acc.id;
        insert app;
        
        Profile p = [select id from profile where name='System Administrator'];

        User u = new User(alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='test123@noemail.com');
        insert u;
        String searchkeyword='test';
        List<Account_Plans__Share>listOfAccountPlanShare = new List<Account_Plans__Share>();
        Account_Plans__Share aps = new Account_Plans__Share();
        System.runAs(u){
        
        aps.AccessLevel = 'Read';
        aps.UserOrGroupId = u.Id;
        aps.ParentId = app.Id;
        aps.RowCause = Schema.Account_Plans__Share.RowCause.Manual;
        insert aps;
        listOfAccountPlanShare.add(aps);
        }
        KAM_AccountPlanSharePopupCntl.getAccountPlanShare(app.Id);
        KAM_AccountPlanSharePopupCntl.getPicklistvalues(objname,apiName,nullreq);
        KAM_AccountPlanSharePopupCntl.fetchUser(acc.Id, searchkeyword, listOfAccountPlanShare);
        KAM_AccountPlanSharePopupCntl.saveAccountPlanShare(app.Id, u.Id, u.Name, acc.Id);
        KAM_AccountPlanSharePopupCntl.removeAccessAccountPlanShare(aps.Id);
    }

}