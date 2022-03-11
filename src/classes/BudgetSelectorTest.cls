@isTest
public class BudgetSelectorTest {
    @testSetup
    public static void createData()
    {
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
        
        Budget_vs_Actuals__c budget=new Budget_vs_Actuals__c();
        budget.Account__c=acc.Id;
        budget.Business_Unit__c='Dairy';
        budget.Start_date__c=system.today();
        budget.End_Date__c=system.today().addDays(365);
        budget.Is_Budget_Locked__c=false;
        //ba.Approval_Status__c='open';
        insert budget;
        
        Budget_vs_Actual_Line__c budgetLine=new Budget_vs_Actual_Line__c();
        budgetLine.Budget_vs_Actuals__c=budget.id;
        budgetLine.Business_Unit__c='Dairy';
        budgetLine.Category__c='BLEND';
        budgetLine.Volume__c=10;
        insert budgetLine;
        
       
        
    }
    
    public static testmethod void getBudgetByAccountIdTest()
    {
       
        Account acc=[select Id from Account where Name = 'DemoAccount'];
        System.assert(acc!=null, 'No Account Found');
        String buIdentifier='Dairy';
        Date startDate=system.today();
        Date endDate=system.today().addDays(365);
        
      list<Budget_vs_Actuals__c> budget_test= [SELECT Id, Account__c, End_Date__c, Start_date__c, Is_Budget_Locked__c,
                    Approval_Status__c,
                    (SELECT Id, Budget_vs_Actuals__c, Category__c, Sub_Category__c, Sub_Category_2__c, 
                    Volume__c, Actuals__c, Total_Consumption__c FROM Budget_vs_Actual_Lines__r)
                FROM Budget_vs_Actuals__c 
                WHERE Account__c =: acc.id
                AND Business_Unit__c =: buIdentifier
                AND Start_date__c =: startDate AND End_Date__c =:endDate
                LIMIT 1];
        List<Budget_vs_Actuals__c> res=BudgetSelector.getBudgetByAccountId(acc.Id, buIdentifier, startDate, endDate);
        System.assert(res!=null, 'No active mapping for given type / occured an internal error');
        System.assertEquals(res,budget_test,'Not equal' );
     }
     public static testmethod void getBudgetsTest()
     {
         set<integer> years=new set<integer>();
         years.add(2019);
         years.add(2020);
         years.add(2021);
         
         Account acc=[select Id from Account where Name = 'DemoAccount'];
        String buIdentifier='Cocoa';
        List<Budget_vs_Actuals__c> res=BudgetSelector.getBudgets(acc.Id, buIdentifier, years);
        System.assert(res!=null, 'No active mapping for given type / occured an internal error');
         
     }
    
    public static testmethod void getBudgetbyOpportunityDetailsTest(){
                 Account acc=[select Id from Account where Name = 'DemoAccount'];
            System.assert(acc!=null, 'No Account Found');
        Opportunity opp = new Opportunity(AccountId = acc.Id, 
                                              Name = 'unittest - opp1',
                                              StageName = 'Briefing',
                                              CloseDate = system.today().addDays(16),
                                              Business_Unit__c = 'Dairy',
                                              Project_Type__c = 'Sample');
            insert opp;
            List<Budget_vs_Actuals__c> res=BudgetSelector.getBudgetbyOpportunityDetails(opp);
            System.assert(res!=null, 'No active mapping for given type / occured an internal error');
    }
    public static testmethod void getBudgetByIdTest(){
        Budget_vs_Actuals__c budget=[select Id from Budget_vs_Actuals__c limit 1];
        System.assert(budget!=null, 'No budget Found');
        List<Budget_vs_Actuals__c> res=BudgetSelector.getBudgetById(budget.Id);
        System.assert(res!=null, 'No active mapping for given type / occured an internal error');

        
        
    }

         
}