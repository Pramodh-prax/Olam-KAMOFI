@isTest
public class KAM_BudgetActualsGrpCntlTest {
    @testSetup
    public static void createData()
    {
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
        ap.Year__c='2021';
        ap.Type__c='Individual';
        ap.BU_Identifier__c='Cocoa';
        insert ap;
    }
    
    public static testmethod void testGetDetails () {
        List<Account_Plans__c> accPlan = [SELECT Id,Name,StartDate__c,EndDate__c,BU_Identifier__c,Customer_Group__c FROM Account_Plans__c ];
        System.assert(accPlan != null && !accPlan.isEmpty (), 'Unable to find the accountPlan');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'Group_Budget_Actuals\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find BudgetActualsGrp component details ' );
        
        String res 
            = KAM_AccountPlanOverviewCntl.getDetails(
                JSON.serialize(accountPlanMetaData[0]),
                JSON.serialize(new Map<String, Object> {'accountPlan' => accPlan[0]})
            );
        List<Account> accounts = (List<Account>) JSON.deserialize(res, List<Account>.class);
        System.assert(!accounts.isEmpty (), 'no accounts found');
        
    }
    
    
    public static testmethod void test_getDetailsNull()
    {
        Account_Plans__c ap=new Account_Plans__c();
        KAM_BudgetActualsGrpCntl bagc=new KAM_BudgetActualsGrpCntl();
        bagc.getDetails(JSON.serialize(ap));
    }
    
    
    
    public static testmethod void test_getOverAllBudgets()
    {
        Account_Plans__c ap=[Select Id,StartDate__c,EndDate__c,Year__c from Account_Plans__c where CreatedDate=Today Limit 1];
        System.assert(ap!=null , 'Unable to find account Plan');
       try
       {
            List<Budget_vs_Actuals__c> ba=KAM_BudgetActualsGrpCntl.getOverAllBudgets(JSON.serialize(ap), ap.Year__c);
       }
        catch(Exception e)
        {
            e.getMessage();
        }
    }
    
    
}

/*
public static testmethod void test_getDetails()
{
Account_Plans__c ap=[Select Id,StartDate__c,EndDate__c,Year__c from Account_Plans__c where CreatedDate=Today Limit 1];
System.assert(ap!=null , 'Unable to find account Plan');
KAM_BudgetActualsGrpCntl bagc=new KAM_BudgetActualsGrpCntl();
String res=bagc.getDetails(JSON.serialize(new Map<String, Object> {'accountPlan' => ap}));
}
public static testmethod void test_getAccountsAndPlansByCustomerGroup()
    {
        Account_Plans__c ap=[Select Id,StartDate__c,EndDate__c,Year__c from Account_Plans__c where CreatedDate=Today Limit 1];
        System.assert(ap!=null , 'Unable to find account Plan');
        KAM_BudgetActualsGrpCntl bagc=new KAM_BudgetActualsGrpCntl();
        try
        {
            List<Account> acc=bagc.getAccountsAndPlansByCustomerGroup(ap);
        }
        catch(Exception e)
        {
            e.getMessage();
            
        }
        
    }

*/