@isTest
public class KAM_AccountPlanNewPopupCntlTest {
    @testSetup
    public static void createData() {
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        acc.Customer_Group__c='Demo';
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
        
        Account_Plans__c ap2=new Account_Plans__c();
        ap2.Account__c=acc.Id;
        ap2.Name='TestPlan';
        ap2.Description__c='This is test AccountPlan';
        ap2.StartDate__c=system.today();
        ap2.EndDate__c=system.today().addDays (365);
        ap2.Type__c='Individual';
        ap2.BU_Identifier__c='Cocoa';
        ap2.Year__c=String.valueOf(System.today().year ());
        insert ap2;
        
        Account_Plans__c ap1=new Account_Plans__c();
        ap1.Account__c=acc.Id;
        ap1.Name='TestPlan';
        ap1.Description__c='This is test AccountPlan';
        ap1.StartDate__c=system.today();
        ap1.EndDate__c=system.today().addDays (365);
        ap1.Type__c='Individual';
        ap1.BU_Identifier__c='Dairy';
        ap1.Year__c=String.valueOf(System.today().year ());
        insert ap1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Cocoa Sales'];
       User u = new User(Alias = 'standt', Email='standardtestuser@force.com', 
      EmailEncodingKey='UTF-8', LastName='TestUser', LanguageLocaleKey='en_US',ProfileId = p.Id, 
      LocaleSidKey='en_US',  
      TimeZoneSidKey='America/Los_Angeles', UserName='standardtestuser@force.com');
      System.runAs(u) {
         Date startdate = System.today();
         Date enddate = System.today();
          //added by sameer
         try{
         Account_Plans__c app= KAM_AccountPlanNewPopupCntl.saveAccountPlan(startdate, enddate, JSON.serialize(ap2));
          System.debug('Account Plan--->>'+ap2);
          }
          catch(Exception e)
          {
              e.getMessage();
          }
      }
        
    }
    static testMethod void testMethod1() {
        List<Account> accList = [SELECT Id FROM Account WHERE Name = 'DemoAccount' LIMIT 1];
        System.assert(accList.size() > 0, 'Unable to find the account');
        Date startdate = System.today();
        Date enddate = System.today(); 
        //List<Account_Plans__c> ap1=[select name,Year__c,Account__c,Type__c,BU_Identifier__c from Account_Plans__c where BU_Identifier__c=:'Individual' ];
        //String data5=JSON.serialize(ap1);
        String data ='{"name":"TEST","year":" ' + System.today().year () + '","AccountId":"'+ accList[0].Id + '","PlanType":"Individual","BusinessUnit":"Cocoa"}';
       Account_Plans__c app= KAM_AccountPlanNewPopupCntl.saveAccountPlan(startdate, enddate, data);
         system.debug('Account Plan test '+app);
       
        String data1 ='{"name":"TEST","year":" ' + System.today().year () + '","AccountId":"'+ accList[0].Id + '","PlanType":"Group","BusinessUnit":"Cocoa"}';
        KAM_AccountPlanNewPopupCntl.saveAccountPlan(startdate, enddate, data1);
        String data2 ='{"name":"TEST","year":" ' + System.today().year () + '","AccountId":"'+ accList[0].Id + '","PlanType":"Group","BusinessUnit":"Cocoa"}';
        KAM_AccountPlanNewPopupCntl.saveAccountPlan(startdate, enddate, data2);
        try{
        String data3 ='{"name":"TEST","year":" ' + System.today().year () + '","AccountId":"'+ accList[0].Id + '","PlanType":"Grou","BusinessUnit":"Cocoa"}';
        KAM_AccountPlanNewPopupCntl.saveAccountPlan(startdate, enddate, data3);
        }
        catch(exception e)
        {
            system.debug(e);
        }
        
        
        
    }
    static testMethod void testMethod2() {
        String obj='Account_Plans__c';
        String field='Type__c';
        Boolean emp=true;
        KAM_AccountPlanNewPopupCntl.getPicklistvalues(obj, field, emp);
    }
     //Added by Sameer to cover getcurrentUserAccountTeam method
    static testMethod void testMethod3() {
        Account acc = [Select Id, Name From Account];
        System.assert(acc != null, 'Null Value found');
        KAM_AccountPlanNewPopupCntl.getcurrentUserAccountTeam(acc.Id);
        
    }
    
}