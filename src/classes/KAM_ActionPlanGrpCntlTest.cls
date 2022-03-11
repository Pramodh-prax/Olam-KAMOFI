@isTest
public class KAM_ActionPlanGrpCntlTest {
 @testSetup
    public static void createData()
    {
         Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        acc.Customer_Group__c='demo';
        insert acc;
        
      
        Account_Plans__c ap=new Account_Plans__c();
        ap.Account__c=acc.Id;
        ap.StartDate__c=system.today();
        ap.EndDate__c=system.today().addDays (365);
        ap.BU_Identifier__c='Cocoa';
        ap.Type__c='Group';
        ap.Year__c=String.valueOf(System.today().year ());
        ap.Description__c='This is a test class';
        ap.Name='TestDemo';
        insert ap;
        
         
        Id RecordTypeIdDefendOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        Opportunity Opp=new Opportunity();
        Opp.AccountId=acc.Id;
        Opp.Name='NewOpportunity';
        Opp.CloseDate=system.today();
        Opp.Business_Unit__c='Cocoa';
        Opp.StageName='Closing Won';
        Opp.RecordTypeId=RecordTypeIdDefendOpportunity;
        opp.Estimated_Volume_MT__c=200;
        insert Opp;
        
        Id RecordTypeIdDefendOpportunity1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defend_Opportunity').getRecordTypeId();
        Opportunity Opp1=new Opportunity();
        Opp1.AccountId=acc.Id;
        Opp1.Name='NewOpportunity';
        Opp1.CloseDate=system.today();
        Opp1.Business_Unit__c='Cocoa';
        Opp1.StageName=' Offering';
        Opp1.RecordTypeId=RecordTypeIdDefendOpportunity1;
        opp1.Estimated_Volume_MT__c=200;
        insert Opp1;
        
         Product2 p_test= new Product2(Name='Product1');
        /*p_test.Name='TEST_PRODUCT';
        p_test.Product_Sub_Category__c='';
        p_test.Product_Category__c=' Cocoa Cake';
        p_test.Product_Sub_Category_2__c='';*/
        insert p_test;
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('PBI '+pricebookId);
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = p_test.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe;
        
        OpportunityLineItem oppLine=new OpportunityLineItem();
        oppLine.Product2Id=p_test.Id;
        oppLine.OpportunityId=opp.Id;
        oppLine.Sample_Sent_Date__c=System.today();
        oppLine.Sampling_Status__c='7';
        oppLine.UoM__c = 'G';
        oppLine.Quantity_of_Sample_Grams__c = 100;
        oppLine.PricebookEntryId=pbe.id;
        insert oppLine;
        
        
        OpportunityLineItem oppLine1=new OpportunityLineItem();
        oppLine1.Product2Id=p_test.Id;
        oppLine1.OpportunityId=opp1.Id;
        oppLine1.Sample_Sent_Date__c=System.today();
        oppLine1.Sampling_Status__c='7';
        oppLine1.UoM__c = 'G';
        oppLine1.Quantity_of_Sample_Grams__c = 100;
        oppLine1.PricebookEntryId=pbe.id;
        insert oppLine1;
        
        ContentDocument cd=new ContentDocument();
        
    }
    
     public static testmethod void testGetDetails () {
       List<Account_Plans__c> accPlan = [SELECT Id,Name,StartDate__c,EndDate__c,BU_Identifier__c,Customer_Group__c FROM Account_Plans__c ];
        System.assert(accPlan != null && !accPlan.isEmpty (), 'Unable to find the accountPlan');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'Group_Action_Plan\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find BudgetActualsGrp component details ' );
        
        String res 
            = KAM_AccountPlanOverviewCntl.getDetails(
                JSON.serialize(accountPlanMetaData[0]),
                JSON.serialize(new Map<String, Object> {'accountPlan' => accPlan[0]})
            );
        List<Account> accounts = (List<Account>) JSON.deserialize(res, List<Account>.class);
        System.assert(!accounts.isEmpty (), 'no accounts found');
         
         try{
         Account_Plans__c ap1=[Select StartDate__c,EndDate__c,BU_Identifier__c from Account_Plans__c  Limit 1];
        KAM_AccountPlanOverviewCntl.getDetails(
                JSON.serialize(accountPlanMetaData[0]),
                JSON.serialize(new Map<String, Object> {'accountPlan' =>ap1}));
        }catch(exception e)
        {
            system.debug(e);
        }
       
         
        
     }
    
    
    
    public static testmethod void test_getDetailsNull()
    {
        Account_Plans__c ap=new Account_Plans__c();
        KAM_ActionPlanGrpCntl apgc=new KAM_ActionPlanGrpCntl();
        apgc.getDetails(JSON.serialize(new Map<String, Object> {''=> ap}));
    }
    
    public static testmethod void test_getDefendDevelopGainOpportunities()
    {
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c from Account_Plans__c where createdDate=Today Limit 1];
        System.assert(ap!=null, 'Its having null values');
        KAM_ActionPlanGrpCntl.getDefendDevelopGainOpportunities(JSON.serialize(ap));
    }
    
     public static testmethod void getGroupDefendDevelopGainOpportunitiesTest()
    {
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c  Limit 1];
        System.assert(ap!=null, 'Its having null values');
        //List<opportunity> res=KAM_ActionPlanGrpCntl.getDefendDevelopGainOpportunities(ap);
        List<opportunity> res=KAM_ActionPlanGrpCntl.getGroupDefendDevelopGainOpportunities(ap, JSON.serialize(new Set<Id> {ap.Account__c}));
        system.assert(res!=null && !res.isEmpty(), 'Opportunity not found');
        try{
         Account_Plans__c ap1=[Select StartDate__c,EndDate__c from Account_Plans__c  Limit 1];
         KAM_ActionPlanGrpCntl.getGroupDefendDevelopGainOpportunities(ap1, JSON.serialize(new Set<Id> {ap.Account__c}));
        }catch(exception e)
        {
            system.debug(e);
        }
    }
    public static testmethod void getCommentsTest()
    {
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c  Limit 1];
        System.assert(ap!=null, 'Its having null values');
        String res=KAM_ActionPlanGrpCntl.getComments(ap);
        try{
         Account_Plans__c ap1=[Select StartDate__c,EndDate__c,BU_Identifier__c from Account_Plans__c  Limit 1];
         String res1=KAM_ActionPlanGrpCntl.getComments(ap1);
        }catch(exception e)
        {
            system.debug(e);
        }
            //KAM_ActionPlanGrpCntl.saveComments(ap, '0691s000000b1lwAAA', 'Testing Purpose');
        
    }
    
   
    public static testmethod void test_saveComments()
    {
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c  Limit 1];
        System.assert(ap!=null, 'Its having null values');
        String Result=KAM_ActionPlanGrpCntl.saveComments(ap, null, 'Testing Purpose');
         System.assert(Result!=null, 'no result found');
         Map<String,object > Result1 = (Map<String,object >) JSON.deserializeUntyped(Result);
        String Result2=KAM_ActionPlanGrpCntl.saveComments(ap, String.ValueOf(Result1.get('contentDocumentId')),'Testing1');
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(Result2);
        System.assert(!resultMap.isEmpty (), 'unable to save comments');
        
        String res=KAM_ActionPlanGrpCntl.getComments(ap); 
         Map<String, Object> resultMap1 = (Map<String, Object>) JSON.deserializeUntyped(res);
        System.assert(!resultMap1.isEmpty (), 'unable to save comments');
        
         try{
         Account_Plans__c ap1=[Select StartDate__c,EndDate__c,BU_Identifier__c from Account_Plans__c  Limit 1];
         KAM_ActionPlanGrpCntl.saveComments(ap1, null, 'Testing Purpose');
        }catch(exception e)
        {
            system.debug(e);
        }
        
       
        //String Result=KAM_ActionPlanGrpCntl.saveComments(Acc, null, 'Testing Purpose');
    }
}

/*
 public static testmethod void test_getDetails()
    {
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c from Account_Plans__c where createdDate=Today Limit 1];
        System.assert(ap!=null, 'Its having null values');
        KAM_ActionPlanGrpCntl apgc=new KAM_ActionPlanGrpCntl();
        apgc.getDetails(JSON.serialize(new Map<String, Object> {'accountPlan'=> ap}));
    }
*/