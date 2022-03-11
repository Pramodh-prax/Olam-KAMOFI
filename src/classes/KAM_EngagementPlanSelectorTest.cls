@isTest
public class KAM_EngagementPlanSelectorTest {
    
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
        
        Engagement_Plan_Line__c engPlanLine= new Engagement_Plan_Line__c();
        engPlanLine.Engagement_Plan__c=engPlan.Id;
        engPlanLine.Actuals__c=10;
            engPlanLine.Attendee__c='Test';
            engPlanLine.Description__c='its test data'; 
            engPlanLine.Frequency__c='Monthly';
            engPlanLine.Last_Engagement_Date__c=system.today();
            engPlanLine.Planned__c=20; 
            engPlanLine.Type_of_Engagement__c='C Level Engagement'; 
        	insert engPlanLine;
        
        Interactions__c inter=new Interactions__c();
        inter.Account__c=acc.Id;
        inter.Business_Unit__c='Cocoa';
        inter.Name='Test Interaction';
        insert inter;
        
    }
    
    public static testmethod void getEngangementPlansByAccountIdTest(){
      list<Account> acc=[select Id from Account where Name = 'DemoAccount'];
       String accId= acc[0].Id;
       String buIdentifier='Cocoa';
       Date startDate=system.Today();
        Date endDate=system.today().addDays (365);
       List<Engagement_Plan__c> EngPlan=EngagementPlanSelector.getEngangementPlansByAccountId(accId,buIdentifier,startDate,endDate);
        
       system.assert(EngPlan!=null, 'No active mapping for given type / occured an internal error');
       System.assert(!EngPlan.isEmpty (), 'Values not found for the given EngPlan'); 
        
       system.assertEquals(engPlan[0].Account__c, acc[0].id, 'Not matches Actual value and Expected Value');
    }
    public static testmethod void getEngagementPlanByInteractionDetailTest(){
        
        Interactions__c inter=[select Id,Account__c,Business_Unit__c,Name from Interactions__c where Name = 'Test Interaction'];
        Set<String> interType=new set<string>{'C Level Engagement','Commercial (Sales & Pricing)','Finance (Structures & Payments)','Innovation','Risk (Solutions)','S&D (Market View Exchange)'};
        List<Engagement_Plan__c> EngPlan= EngagementPlanSelector.getEngagementPlanByInteractionDetail(inter, interType);
        
        system.assert(EngPlan!=null, 'No active mapping for given type / occured an internal error');
        System.assert(!EngPlan.isEmpty (), 'Values not found for the given EngPlan');
        
       List<Engagement_Plan__c> engplanTest=[SELECT Id, Account__c, Business_Unit__c, End_Date__c, Start_date__c from Engagement_Plan__c where Business_Unit__c =: inter.Business_Unit__c ];
         system.assertEquals(engPlan[0].Start_date__c, engplanTest[0].Start_date__c, 'Not matches Actual value and Expected Value');
       }
    
    public static testmethod void getEngangementPlansByIdTest()
    {
          List<Engagement_Plan__c> engPlan =[SELECT Id, Account__c, Business_Unit__c, End_Date__c, Start_date__c from Engagement_Plan__c where Business_Unit__c = 'Cocoa' limit 1];
        String EngagementPlanId=engPlan[0].Id;
        List<Engagement_Plan__c> EngPlanTest= EngagementPlanSelector.getEngangementPlansBytId(EngagementPlanId);
        
        system.assert(EngPlanTest!=null, 'No active mapping for given type / occured an internal error');
        System.assert(!EngPlanTest.isEmpty (), 'Values not found for the given EngPlan');
      
       system.assertEquals(engPlan[0].Id, EngPlanTest[0].Id, 'Not matches Actual value and Expected Value');


    }

}