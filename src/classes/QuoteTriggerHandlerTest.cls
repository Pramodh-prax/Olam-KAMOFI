@isTest
public class QuoteTriggerHandlerTest {
    @testSetup
    public static void data()
    {
        Account acc=new Account();
        acc.Name='Spices';
        acc.BillingCountry='India';
        acc.BillingStreet='xyz area';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='Gain';
        opp.StageName='Offering';
        opp.CloseDate=System.today()+1;
        opp.Type='New Business';
        opp.Business_Unit__c='Spice';
        //opp.CurrencyIsoCode='USD - U.S. Dollar';
        insert opp;
        
        Quote q=new Quote();
        q.OpportunityId=opp.Id;
        //q.AccountId=acc.Id;
        q.Name=opp.Name;
        q.Bussiness_Unit__c=opp.Business_Unit__c;
        q.ExpirationDate=opp.CloseDate;
        //q.Ship_To_Party__c=acc.Id;
        q.Status='Draft';
        insert q;
        
        //testdatafactory class 
    }
    public static testmethod void afterInsert()
    {
        
        List<Quote> quoList=[Select Id,IsSyncing,Name,Bussiness_Unit__c,Status,ExpirationDate,OpportunityId,Version__c from Quote];
        //Quote q=quoList[0];
        System.assert(quoList!=null,'Null values');
        //QuoteTriggerHandler.afterInsert(quoList);
        System.assertEquals(1,quoList[0].Version__c);
        //System.debug('sync=========>'+quoList[0].IsSyncing);
        
    }
}