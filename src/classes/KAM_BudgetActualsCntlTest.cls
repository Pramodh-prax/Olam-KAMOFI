@isTest
public class KAM_BudgetActualsCntlTest {

    @testSetup
    public static void createData()
    {
        Account acc=new Account();
        acc.Name='Test';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
        Account_Plans__c app = new Account_Plans__c();
        app.Name = 'accountPlan';
        app.Account__c = acc.id;
        app.BU_Identifier__c='Dairy';
        app.StartDate__c=system.today();
        app.EndDate__c=system.today().addDays(365);
        insert app;
        
       Budget_vs_Actuals__c budget=new Budget_vs_Actuals__c();
        budget.Account__c=acc.Id;
        budget.Business_Unit__c='Dairy';
        budget.Start_date__c=system.today();
        budget.End_Date__c=system.today().addDays(365);
        budget.Is_Budget_Locked__c=false;
        budget.Year__c='2021';
        budget.Approval_Status__c='';
        insert budget;
        
        Budget_vs_Actual_Line__c budgetLine=new Budget_vs_Actual_Line__c();
        budgetLine.Budget_vs_Actuals__c=budget.id;
        budgetLine.Business_Unit__c = 'Dairy';
        budgetLine.Category__c='BLEND';
        budgetLine.Volume__c=10;
        insert budgetLine;
        
         //Added by Sameer
        Access_Set__c access = OFI_TestDataFactory.createAccessSet('Country', null, 'IN', 'All', null, null, null, true);
        Access_Set_Assignment__c assign = OFI_TestDataFactory.createAccessSetAssignment(access.ID, userinfo.getUserId(), //'Sales', 
                                                                                        true);
		Teams__c team = OFI_TestDataFactory.createAccountTeam(acc.Id, UserInfo.getUserId(), 'All', 'Edit Access', //'Sales',
                                                              true, true);
    }
    
    public static testmethod void getDetailsTest()
    {
        Account acc=[select id from account];
       Account_Plans__c app=[select Name,Account__c,BU_Identifier__c,StartDate__c,EndDate__c from Account_Plans__c limit 1 ];
      //  String data='{"accountPlan":[{"Name":"Test","Account__c":"a0e1s000001pogbAAA","BU_Identifier__c":"Cocoa","StartDate__c":"2021-08-12","EndDate__c":"2021-08-31"}]}';
        KAM_BudgetActualsCntl BudgetCntl=new KAM_BudgetActualsCntl();
       String res= BudgetCntl.getDetails(JSON.serialize(new Map<String, Object> {'accountPlan' => app}));
         String res1= BudgetCntl.getDetails(JSON.serialize(app));
        system.assert(res!=null, 'Account Plans Details not found');
              
    }
    public static testmethod void refreshBudgetPlanTest(){
               Account_Plans__c app=[select Name,Account__c,BU_Identifier__c,StartDate__c,EndDate__c from Account_Plans__c limit 1 ];
                 system.assert(app!=null, 'Account Plans Details not found');
                 String res= KAM_BudgetActualsCntl.refreshBudgetPlan(JSON.serialize(app));
        try{
                String res1= KAM_BudgetActualsCntl.refreshBudgetPlan(JSON.serialize(null));
        }catch(exception e)
        {
            system.debug(e);
        }
            system.assert(res!=null, 'Budget Plan not Refresh');

        
    }
    public static testmethod void refreshOverAllBudget(){
        
             Account_Plans__c app=[select Name,Account__c,BU_Identifier__c,StartDate__c,EndDate__c from Account_Plans__c limit 1 ];
             system.assert(app!=null, 'Account Plans Details not found');
             list<integer> years=new list<integer>();
            years.add(2020);
            years.add(2021);
            years.add(2019);
            years.add(2018);
            List<Budget_vs_Actuals__c> res=KAM_BudgetActualsCntl.refreshOverAllBudget(JSON.serialize(app),JSON.serialize(years));
        try{
            List<Budget_vs_Actuals__c> res1=KAM_BudgetActualsCntl.refreshOverAllBudget(JSON.serialize(app),JSON.serialize(app));
        }catch(exception e)
        {
            system.debug(e);
        }
            system.assert(res!=null, 'not refresh budget');
        
    }
   public static testmethod void getOverAllBudgetsTest(){
            
   
             Account_Plans__c app=[select Name,Account__c,BU_Identifier__c,StartDate__c,EndDate__c from Account_Plans__c limit 1 ];
             system.assert(app!=null, 'Account Plans Details not found');  
            Account acc=[select id from account];
             list<integer> years=new list<integer>();
            years.add(2020);
            years.add(2021);
            years.add(2019);
            years.add(2018);
            List<Budget_vs_Actuals__c> res=KAM_BudgetActualsCntl.getOverAllBudgets(JSON.serialize(app),JSON.serialize(years));    
            system.assert(res!=null, 'Not Found Overall Budget'); 
       try{ 
       
          List<Budget_vs_Actuals__c> res1=KAM_BudgetActualsCntl.getOverAllBudgets(JSON.serialize(acc),JSON.serialize(acc));
       }catch(exception e)
       {
           system.debug(e);
       }
   }
       
       
      public static testmethod void riseRequestForBudgetEditTest(){
       Account acc=[select id from account];
       Budget_vs_Actuals__c budget1=new Budget_vs_Actuals__c();
        budget1.Account__c=acc.Id;
        budget1.Business_Unit__c='Cocoa';
        budget1.Start_date__c=system.today();
        budget1.End_Date__c=system.today().addDays(365);
        budget1.Is_Budget_Locked__c=true;
        budget1.Year__c='2022';
        budget1.Approval_Status__c='pending';
          insert budget1;
        Budget_vs_Actuals__c budget=[select Id,Account__c,Business_Unit__c,Start_date__c,End_Date__c,Is_Budget_Locked__c from Budget_vs_Actuals__c where Year__c='2022'];
        String res=KAM_BudgetActualsCntl.riseRequestForBudgetEdit(JSON.serialize(budget));
        
         Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        //System.assert((Boolean)resultMap.get ('success'), 'Exception thrown while processing record');
        String res1=KAM_BudgetActualsCntl.riseRequestForBudgetEdit(JSON.serialize(acc));
          
      } 
    public static testmethod void createBudgetTest(){
         Account acc=[select id from account];
       Budget_vs_Actuals__c budget1=new Budget_vs_Actuals__c();
        budget1.Account__c=acc.Id;
        budget1.Business_Unit__c='Cocoa';
        budget1.Start_date__c=system.today();
        budget1.End_Date__c=system.today().addDays(365);
        budget1.Is_Budget_Locked__c=true;
        budget1.Year__c='2022';
        budget1.Approval_Status__c='pending';
        
      Budget_vs_Actuals__c budget=[select Id,Account__c,Business_Unit__c,Start_date__c,End_Date__c,Is_Budget_Locked__c from Budget_vs_Actuals__c limit 1];
      list<Budget_vs_Actual_Line__c> budget_Line =[select Id,Budget_vs_Actuals__c,Category__c from Budget_vs_Actual_Line__c ];
      String res=KAM_BudgetActualsCntl.createBudget(JSON.serialize(budget),JSON.serialize(budget_Line)); 
      String res1=KAM_BudgetActualsCntl.createBudget(JSON.serialize(budget1),JSON.serialize(null));
      system.assert(res!=null, ' Budget Not create'); 
        
    }
    public static testmethod void getBudgetvsActualsTest(){
        
        Account acc=[select id from account];
         List<Budget_vs_Actuals__c> res=KAM_BudgetActualsCntl.getBudgetvsActuals(acc.Id);
        //commented by sameer
        //system.assert(res!=null, 'not found budgetvsActuals');
        
        //System.assertEquals(acc.id, res[0].Account__c , ' not matches actual and expected value');
        
    }
    
   public static testmethod void getBudgetActualsByIdTest()
   {
       Budget_vs_Actuals__c budget=[select Id from Budget_vs_Actuals__c limit 1];
       system.assert(budget!=null, 'not found budgetvsActuals');
       String res=KAM_BudgetActualsCntl.getBudgetActualsById(budget.Id);
       system.assert(res!=null, 'not found budgetvsActuals');

       
   }
    public static testmethod void getBudgetPickListValuesByFieldTest()
    {
      List<KAM_Util.PicklistEntry> result=KAM_BudgetActualsCntl.getBudgetPickListValuesByField('Budget_vs_Actuals__c','Year__c',false,false); 
       system.assert(result!=null,'No year');
        try{
            List<KAM_Util.PicklistEntry> result1=KAM_BudgetActualsCntl.getBudgetPickListValuesByField('Account','Start_date__c',false,false);
        }
        catch(exception e)
        {
            system.debug(e);
        }    
        
    }
    public static testmethod void createBudgetvsActualsTest(){
         Account acc=[select id from account];
        //Added by sameer
        Id currentUserId = UserInfo.getUserId();
        List<Teams__c> team = [Select Id,Name,Business_Unit__c From Teams__c where User__c =:currentUserId  and Account__c =: acc.Id];
       System.debug('Error acc======>'+acc);
        System.debug('Error team======>'+team);
        //added bu by sameer
       Budget_vs_Actuals__c budget = KAM_BudgetActualsCntl.createBudgetvsActuals('2020',acc.Id,team[0].Business_Unit__c);
         System.debug('budet=======sam>'+budget);
        system.assert(budget!=null,'No year');
         system.assertEquals(budget.Year__c, '2020');
        
    }
     //added by sameer
    @isTest
    public static void test_getUserBU(){
        User u = KAM_BudgetActualsCntl.getUserBU();
        System.assert(u!=null, 'No user found');
    }
    //added by sameer
    @isTest
    public static void test_getAccountTeams(){
        Account acc = [Select Id, Name From Account];
        List<Teams__c> team = KAM_BudgetActualsCntl.getAccountTeams(acc.Id);
        System.debug('teamlist======>'+team);
        System.assert(!team.isEmpty(), 'No team member found');
    }
    //added by sameer
    @isTest
    public static void test_getcurrentUserAccountTeam(){
	Account acc = [Select Id, Name From Account];
        Teams__c team = KAM_BudgetActualsCntl.getcurrentUserAccountTeam(acc.Id);
        System.assert(team!=null, 'No team member found');        
    }
}