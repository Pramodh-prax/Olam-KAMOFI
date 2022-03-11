@isTest
public class OpportunitySelectorTest {
    
     @testSetUp
    static void createData () 
    {
        Account acc=new Account();
        acc.Name='Test';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
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
        Opp1.StageName='Closing Won';
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
        
    }
    
    /*public static testmethod void  getClosedServiceAndPresentationOpportunitiesTest()
    {
        Account acc=[select id from account where name='Test'];
        system.assert(acc!=null, 'Not Found Account');
        String bu='Cocoa';
        Date startDate=System.today();
        Date endDate=system.today().addDays(36);
        List<Opportunity> res=OpportunitySelector.getClosedServiceAndPresentationOpportunities(acc.Id,bu,startDate,endDate);
        system.assert(res!=null, 'not found mapping result');
        system.assertEquals(res[0].AccountId, acc.Id, 'Result not match which expected');
    }*/
    public static testmethod void getDefendDevelopGainOpportunitiesTest()
    {
         Account acc=[select id from account where name='Test'];
        system.assert(acc!=null, 'Not Found Account');
        String bu='Cocoa';
        Date startDate=System.today();
        Date endDate=system.today().addDays(36);
        List<Opportunity> res=OpportunitySelector.getDefendDevelopGainOpportunities(acc.Id,bu,startDate,endDate);
        system.assert(res!=null, 'not found mapping result');
        system.assertEquals(res[0].AccountId, acc.Id, 'Result not match which expected');

    }
    public static testmethod void getOpenDefendDevelopOpportunitiesTest()
    {
        Account acc=[select id from account where name='Test'];
        system.assert(acc!=null, 'Not Found Account');
        String bu='Cocoa';
        Date startDate=System.today();
        Date endDate=system.today().addDays(36);
        List<Opportunity> res=OpportunitySelector.getOpenDefendDevelopOpportunities(acc.Id,bu,startDate,endDate);
        system.assert(res!=null, 'not found mapping result');
       
    }
    public static testmethod void getOpportunityRecordTypeNameFromIdTest()
    {
    Id RecordTypeIdDefendOpportunity1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defend_Opportunity').getRecordTypeId();
    String res=OpportunitySelector.getOpportunityRecordTypeNameFromId(RecordTypeIdDefendOpportunity1);
    system.assert(res!=null, 'not found mapping result');        
    } 
}