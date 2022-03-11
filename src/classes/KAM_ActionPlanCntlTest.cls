@isTest
public class KAM_ActionPlanCntlTest {

    @testSetup
    public static void createData()
    {
        List<Account> accList = new List<Account>();
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        accList.add(acc);
        
        Account acc1 = new Account();
        acc1.Name = 'Test1';
        acc1.BillingCity = 'Testcity';
        acc1.BillingCountry = 'india';
        acc1.Customer_Group__c='Test Group';
        accList.add(acc1);
        
        insert accList;
        
         Account_Plans__c app1 = new Account_Plans__c();
        app1.Name = 'test1';
        app1.Account__c = acc1.id;
         app1.Type__c='group';
        app1.BU_Identifier__c='Cocoa';
        app1.StartDate__c=system.today();
        app1.EndDate__c=system.today().addDays(365);
        insert app1;
        
         Id RecordTypeIdDefendOpportunity4 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity Opp3=new Opportunity();
        Opp3.AccountId=acc1.Id;
        Opp3.Name='NewOpportunityService';
        Opp3.CloseDate=system.today();
        Opp3.Business_Unit__c='Cocoa';
        Opp3.StageName='Closing Won';
        Opp3.RecordTypeId=RecordTypeIdDefendOpportunity4;
        Opp3.Estimated_Volume_MT__c=200;
        oppList.add(Opp3);
        
         Id RecordTypeIdDefendOpportunity5 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
        Opportunity Opp4=new Opportunity();
        Opp4.AccountId=acc1.Id;
        Opp4.Name='NewOpportunityPresent';
        Opp4.CloseDate=system.today();
        Opp4.Business_Unit__c='Cocoa';
        Opp4.StageName=' Offering';
        Opp4.RecordTypeId=RecordTypeIdDefendOpportunity5;
        Opp4.Estimated_Volume_MT__c=200;
        oppList.add(Opp4);
        
        Id RecordTypeIdDefendOpportunity6 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defend_Opportunity').getRecordTypeId();
        Opportunity Opp5=new Opportunity();
        Opp5.AccountId=acc1.Id;
        Opp5.Name='NewOpportunityDefend';
        Opp5.CloseDate=system.today();
        Opp5.Business_Unit__c='Cocoa';
        Opp5.StageName=' Offering';
        Opp5.RecordTypeId=RecordTypeIdDefendOpportunity6;
        Opp5.Estimated_Volume_MT__c=200;
        oppList.add(Opp5);
        
        Id RecordTypeIdDefendOpportunity7 =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Develop_Opportunity').getRecordTypeId();
        Opportunity Opp6=new Opportunity();
        Opp6.AccountId=acc1.Id;
        Opp6.Name='NewOpportunityDefend';
        Opp6.CloseDate=system.today();
        Opp6.Business_Unit__c='Cocoa';
        Opp6.StageName=' Offering';
        Opp6.RecordTypeId=RecordTypeIdDefendOpportunity7;
        Opp6.Estimated_Volume_MT__c=200;
        oppList.add(Opp6);
        
        insert oppList;
        
         Account_Plans__c ap = new Account_Plans__c();
        ap.Name = 'test';
        ap.Account__c = acc.id;
         ap.BU_Identifier__c='Cocoa';
        ap.StartDate__c=system.today();
        ap.EndDate__c=system.today().addDays(20);
        insert ap;
        
        List<Opportunity> oppList2 = new List<Opportunity>();
        
        Id RecordTypeIdDefendOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        Opportunity Opp=new Opportunity();
        Opp.AccountId=acc.Id;
        Opp.Name='NewOpportunityService';
        Opp.CloseDate=system.today();
        Opp.Business_Unit__c='Cocoa';
        Opp.StageName='Closing Won';
        Opp.RecordTypeId=RecordTypeIdDefendOpportunity;
        opp.Estimated_Volume_MT__c=200;
        oppList2.add(Opp);
        
        Id RecordTypeIdDefendOpportunity1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defend_Opportunity').getRecordTypeId();
        Opportunity Opp1=new Opportunity();
        Opp1.AccountId=acc.Id;
        Opp1.Name='NewOpportunityDefend';
        Opp1.CloseDate=system.today();
        Opp1.Business_Unit__c='Cocoa';
        Opp1.StageName=' Offering';
        Opp1.RecordTypeId=RecordTypeIdDefendOpportunity1;
        opp1.Estimated_Volume_MT__c=200;
        oppList2.add(Opp1);
        
        Id RecordTypeIdDefendOpportunity2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
        Opportunity Opp2=new Opportunity();
        Opp2.AccountId=acc.Id;
        Opp2.Name='NewOpportunityPresent';
        Opp2.CloseDate=system.today();
        Opp2.Business_Unit__c='Cocoa';
        Opp2.StageName=' Offering';
        Opp2.RecordTypeId=RecordTypeIdDefendOpportunity2;
        Opp2.Estimated_Volume_MT__c=200;
        oppList2.add(Opp2);
        
        insert oppList2;
        
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
        
        List<OpportunityLineItem> oppLineList = new List<OpportunityLineItem>();
        
        OpportunityLineItem oppLine=new OpportunityLineItem();
        oppLine.Product2Id=p_test.Id;
        oppLine.OpportunityId=opp.Id;
        oppLine.Sample_Sent_Date__c=System.today();
        oppLine.Sampling_Status__c='7';
        oppLine.UoM__c ='G';
        oppLine.Quantity_of_Sample_Grams__c = 100;
        oppLine.PricebookEntryId=pbe.id;
        oppLineList.add(oppLine);
        
        
        OpportunityLineItem oppLine1=new OpportunityLineItem();
        oppLine1.Product2Id=p_test.Id;
        oppLine1.OpportunityId=opp1.Id;
        oppLine1.Sample_Sent_Date__c=System.today();
        oppLine1.Sampling_Status__c='7';
        oppLine1.UoM__c ='G';
        oppLine1.Quantity_of_Sample_Grams__c = 100;
        oppLine1.PricebookEntryId=pbe.id;
        oppLineList.add(oppLine1);
        
         OpportunityLineItem oppLine2=new OpportunityLineItem();
        oppLine2.Product2Id=p_test.Id;
        oppLine2.OpportunityId=opp2.Id;
        oppLine2.Sample_Sent_Date__c=System.today();
        oppLine2.Sampling_Status__c='7';
        oppLine2.UoM__c ='G';
        oppLine2.Quantity_of_Sample_Grams__c = 100;
        oppLine2.PricebookEntryId=pbe.id;
        oppLineList.add(oppLine2);
        
        insert oppLineList;
        
        ContentDocument cd=new ContentDocument();
        
        
            
  }
    
     public static testmethod void test_getDetails()
    {
        Test.startTest();
        Account_Plans__c ap=[Select id,name,Account__c,BU_Identifier__c from Account_Plans__c where BU_Identifier__c='cocoa' Limit 1];
        System.assert(ap!=null, 'Its having null values');
        KAM_ActionPlanCntl apc=new KAM_ActionPlanCntl();
       String res= apc.getDetails(JSON.serialize(new Map<String, Object> {'accountPlan'=> ap}));
        system.assert(res!=null, 'not found response');
       String res1= apc.getDetails(JSON.serialize(ap));
        
        Test.stopTest();
        
    }
   
     public static testmethod void test_getClosedServiceAndPresentationOpportunities()
    {
        Test.startTest();
        Account_Plans__c ap=[Select id,name,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c  where name='test'];
        System.assert(ap!=null, 'Its having null values');
       system.debug(ap);
       List<Opportunity> res= KAM_ActionPlanCntl.getPresentationOpportunities(ap);
        system.assert(res!=null && !res.isEmpty(), 'Opportunity not found');
        
        
         List<Opportunity> res1= KAM_ActionPlanCntl.getServiceOpportunities(ap);
        system.assert(res1!=null && !res1.isEmpty(), 'Opportunity not found');
        
        Account_Plans__c ap1=[Select id,name,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c  where name='test1'];
        res = KAM_ActionPlanCntl.getGroupServiceOpportunities (ap1, JSON.serialize(new Set<Id> {ap1.Account__c}));
        res1 = KAM_ActionPlanCntl.getGroupPresentationOpportunities (ap1, JSON.serialize(new Set<Id> {ap1.Account__c}));
        try{
              Account_Plans__c ap2=[Select id,StartDate__c,EndDate__c,BU_Identifier__c from Account_Plans__c  Limit 1];
      
             KAM_ActionPlanCntl.getServiceOpportunities(ap2);
             KAM_ActionPlanCntl.getPresentationOpportunities(ap2);
            
        }catch(exception e)
        {
            system.debug(e);
        }
        Test.stopTest();
        
    }
    public static testmethod void test_getOpenDefendDevelopOpportunities()
    {
        Test.startTest();
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c where name='test'  Limit 1];
        System.assert(ap!=null, 'Its having null values');
        List<opportunity> res=KAM_ActionPlanCntl.getOpenDefendDevelopOpportunities(ap);
        system.assert(res!=null && !res.isEmpty(), 'Opportunity not found');
         try{
              Account_Plans__c ap1=[Select id,StartDate__c,EndDate__c,BU_Identifier__c from Account_Plans__c  Limit 1];
      
             List<Opportunity> res1= KAM_ActionPlanCntl.getOpenDefendDevelopOpportunities(ap1);
        }catch(exception e)
        {
            system.debug(e);
        }
        Test.stopTest();
       
    }
      public static testmethod void getDefendDevelopGainOpportunitiesTest()
    {
        Test.startTest();
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c where name='test1' Limit 1];
        System.assert(ap!=null, 'Its having null values');
        
        List<opportunity> res=KAM_ActionPlanCntl.getDefendDevelopGainOpportunities(ap);
        
        res=KAM_ActionPlanCntl.getGroupOpenDefendDevelopOpportunities(ap, JSON.serialize(new Set<Id> {ap.Account__c}));
        system.assert(res!=null && !res.isEmpty(), 'Opportunity not found');
        
         try{
              Account_Plans__c ap1=[Select id,StartDate__c,EndDate__c,BU_Identifier__c from Account_Plans__c  Limit 1];
      
             List<Opportunity> res1= KAM_ActionPlanCntl.getDefendDevelopGainOpportunities(ap1);
        }catch(exception e)
        {
            system.debug(e);
        }
        
       Test.stopTest();
    }
    public static testmethod void getCommentsTest()
    {
        Test.startTest();
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c  Limit 1];
        System.assert(ap!=null, 'Its having null values');
        String res=KAM_ActionPlanCntl.getComments(ap);
        Test.stopTest();
        
    }
    
   
   
     public static testmethod void test_saveComments()
    {
        Test.startTest();
        Account_Plans__c ap=[Select id,StartDate__c,EndDate__c,BU_Identifier__c,Account__c from Account_Plans__c  Limit 1];
        System.assert(ap!=null, 'Its having null values');
        String Result=KAM_ActionPlanCntl.saveComments(ap, null, 'Testing Purpose');
         System.assert(Result!=null, 'no result found');
         Map<String,object > Result1 = (Map<String,object >) JSON.deserializeUntyped(Result);
        String Result2=KAM_ActionPlanCntl.saveComments(ap, String.ValueOf(Result1.get('contentDocumentId')),'Testing1');
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(Result2);
        System.assert(!resultMap.isEmpty (), 'unable to save comments');
        
        String res=KAM_ActionPlanCntl.getComments(ap); 
         Map<String, Object> resultMap1 = (Map<String, Object>) JSON.deserializeUntyped(res);
        System.assert(!resultMap1.isEmpty (), 'unable to save comments');
        
         try{
         Account_Plans__c ap1=[Select StartDate__c,EndDate__c,BU_Identifier__c from Account_Plans__c  Limit 1];
         KAM_ActionPlanCntl.saveComments(ap1, null, 'Testing Purpose');
        }catch(exception e)
        {
            system.debug(e);
        }
        Test.stopTest();
    }
}