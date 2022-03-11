@isTest
public class OpportunityLineItemSelectorTest {

    
    public static testmethod void test_getOpportunityLines()
    {
         Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
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
        p_test.Name='TEST_PRODUCT';
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
        oppLine.OpportunityId=opp1.Id;
        oppLine.Sample_Sent_Date__c=System.today();
        oppLine.Sampling_Status__c='7';
        oppLine.UoM__c = 'G';
        oppLine.Quantity_of_Sample_Grams__c = 100;
        oppLine.PricebookEntryId=pbe.id;
        insert oppLine;
        
        
        Date startDate=System.today();
        Date endDate=System.today().addDays(16);
        String bu='Cocoa';
        
        List<OpportunityLineItem> res= OpportunityLineItemSelector.getOpportunityLines(acc.Id, startDate, endDate, bu);         
        system.assert(res!=null && (!res.isEmpty ()), 'Opportunity Not Found');
        
       
    }
}