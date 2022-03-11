@isTest
public class LookupSearchResultTest extends LookupSearchResult {
    
    @testSetUp
    static void createData (){
        
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
        Engagement_Plan__c engPlan=new Engagement_Plan__c();
        engPlan.Account__c=acc.Id;
        engPlan.Is_Engagement_Plan_Locked__c=true;
        engPlan.End_Date__c=system.today().addDays (365);
        engPlan.Start_date__c=system.today();
        engPlan.Approval_Status__c='Pending';
        engPlan.Business_Unit__c='Cocoa';
        insert engPlan;
        
    }
    
    @isTest
    static void testCompareToMethod () {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult(null);
        Integer compareResult = r1.compareTo(r2);
        System.assertEquals(0, compareResult);
        
        r1 = getSearchResult(null);
        r2 = getSearchResult('a');
        compareResult = r1.compareTo(r2);
        System.assertEquals(1, compareResult);
        
        r1 = getSearchResult('a');
        r2 = getSearchResult(null);
        compareResult = r1.compareTo(r2);
        System.assertEquals(-1, compareResult);

        r1 = getSearchResult('a');
        r2 = getSearchResult('b');
        compareResult = r1.compareTo(r2);
        System.assertEquals(-1, compareResult); 
    }
    private static LookupSearchResult getSearchResult(String title) {
        return new LookupSearchResult(null, null, null, title, null);
    }
    
    @isTest
    static void lookupSearchResultTest()
    {
        Account acc=[select Id, Name, BillingCountry  from Account where Name = 'DemoAccount' LIMIT 1];
        System.assert(acc != null, 'Unable to find the account');
        Id acc_id=acc.Id;
        String sobjectType='Account';
        String icon='standard:account';
        String title=acc.Name;
        String subTitle=acc.BillingCountry;
        
        LookupSearchResult lookResult=new LookupSearchResult(acc_id,sobjectType,icon,title,subTitle);
        
        System.assertEquals(acc.Id, lookResult.getId());
        System.assertEquals(sobjectType, lookResult.getSObjectType());
        System.assertEquals(icon, lookResult.getIcon());
        System.assertEquals(acc.Name, lookResult.getTitle());
        System.assertEquals(acc.BillingCountry, lookResult.getSubtitle());
        
        lookResult = new LookupSearchResult (); 
        
    }
    
}