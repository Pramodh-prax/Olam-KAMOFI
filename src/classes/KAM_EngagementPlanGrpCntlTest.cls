@isTest
public class KAM_EngagementPlanGrpCntlTest {
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
        ap.StartDate__c=system.today();
        ap.EndDate__c=system.today().addDays (365);
        ap.BU_Identifier__c='Cocoa';
        ap.Type__c='Individual';
        ap.Year__c='2023';
        ap.Description__c='This is a test class';
        ap.Name='TestDemo';
        insert ap;
        
        Engagement_Plan__c ep=new Engagement_Plan__c();
        ep.Account__c=ap.Account__c;
        ep.Approval_Status__c='Approved';
        ep.Start_date__c= ap.StartDate__c;
        ep.End_Date__c=ap.EndDate__c;
        ep.Business_Unit__c= ap.BU_Identifier__c;
        insert ep;
    }
    
    public static testmethod void testGetDetails () {
       List<Account_Plans__c> accPlan = [SELECT Id,Name,StartDate__c,EndDate__c,BU_Identifier__c,Customer_Group__c FROM Account_Plans__c ];
        System.assert(accPlan != null && !accPlan.isEmpty (), 'Unable to find the accountPlan');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'Group_Engagement_Plan\'');
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
        KAM_EngagementPlanGrpCntl epgc=new KAM_EngagementPlanGrpCntl();
        epgc.getDetails(JSON.serialize(new Map<String, Object> {''=> ap}));
    }
    
    public static testmethod void test_getGroupDetails()
    { List<Account_Plans__c> accPlan = [SELECT Id,Name,StartDate__c,EndDate__c,BU_Identifier__c,Customer_Group__c FROM Account_Plans__c ];
        System.assert(accPlan != null && !accPlan.isEmpty (), 'Unable to find the accountPlan');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'Group_Engagement_Plan\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find BudgetActualsGrp component details ' );
        
        String res 
            = KAM_AccountPlanOverviewCntl.getDetails(
                JSON.serialize(accountPlanMetaData[0]),
                JSON.serialize(new Map<String, Object> {'accountPlan' => accPlan[0]})
            );
        List<Account> ar = (List<Account>) JSON.deserialize(res, List<Account>.class);
        System.assert(!ar.isEmpty (), 'no results found');
        
    }
    
    public static testmethod void test_getGroupDetailsNull()
    {
        try{
            Account_Plans__c ap=new Account_Plans__c();
            KAM_EngagementPlanGrpCntl.getGroupDetails(JSON.serialize(new Map<String, Object> {''=> ap}));
            KAM_EngagementPlanGrpCntl.getGroupDetails(JSON.serialize(new Map<String, Object> {'accountPlan'=> ap}));
        }catch(Exception e){}    
    }
    
    public static testmethod void test_getEngagementPlans()
    {
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c from Account_Plans__c where createdDate=Today Limit 1];
        System.assert(ap!=null, 'Its having null values');
        KAM_EngagementPlanGrpCntl.getEngagementPlans(JSON.serialize(ap));
    }
    
}

/*
 public static testmethod void test_getDetails()
    {
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c from Account_Plans__c where createdDate=Today Limit 1];
        System.assert(ap!=null, 'Its having null values');
        KAM_EngagementPlanGrpCntl epgc=new KAM_EngagementPlanGrpCntl();
        String res=epgc.getDetails(JSON.serialize(new Map<String, Object> {'accountPlan'=> ap}));
        List<Account> acc=[
                SELECT Id, Name
                   FROM Account
                WHERE CreatedDate=Today Limit 1
            ];
        //System.debug('res===========>'+JSON.deserializeUntyped(res));
        System.assertEquals(JSON.serialize(acc), res);
    }
*/