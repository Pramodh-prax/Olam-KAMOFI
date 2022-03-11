@isTest
public class RequestForSamplingControllerTest {
    @testSetup
    public static void testData() {
        //Opportunities
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        lstOpportunity.add(new Opportunity(Name='opp1', StageName='Preparation', CloseDate=system.today()));
        
        Database.SaveResult[] oppResult = Database.insert(lstOpportunity, false);
        List<Id> oppSuccessId = new List<Id>();
        for(Database.SaveResult result : oppResult) {
            if(result.isSuccess()) {
                oppSuccessId.add(result.getId());
            }
        }
        
        //Products
        List<Product2> lstProduct = new List<Product2>();
        lstProduct.add(new Product2(Name='p1'));
        
        Database.SaveResult[] productResult = Database.insert(lstProduct, false);
        List<Id> prodSuccessId = new List<Id>();
        for(Database.SaveResult result : productResult) {
            if(result.isSuccess()) {
                prodSuccessId.add(result.getId());
            }
        }
        
        //Pricebook
        List<Pricebook2> lstPriceBook = new List<Pricebook2>();
        lstPriceBook.add(new Pricebook2(name='Price Book'));
        
        Database.SaveResult[] priceBookResult = Database.insert(lstPriceBook, false);
        List<Id> priceBookId = new List<Id>();
        for(Database.saveResult result : priceBookResult) {
            if(result.isSuccess()) {
                priceBookId.add(result.getId());
            }
        }
        
        //PriceBookEntry
        List<PriceBookEntry> lstPriceBookEntry = new List<PriceBookEntry>();
        lstPriceBookEntry.add(new PriceBookEntry(UnitPrice=100, Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prodSuccessId[0], isActive = true));
        
        Database.SaveResult[] priceBookEntryResult = Database.insert(lstPriceBookEntry, false);
        List<Id> priceBookEntryId = new List<Id>();
        for(Database.saveResult result : priceBookEntryResult) {
            if(result.isSuccess()) {
                priceBookEntryId.add(result.getId());
            }
        }
        
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
        //lstOpportunityLineItem.add(new OpportunityLineItem(Name='n1', UnitPrice='100'));
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = oppSuccessId[0];
        oli.Product2Id = prodSuccessId[0];
        oli.PricebookEntryId = priceBookEntryId[0];
        oli.Sampling_Status__c='7';
        oli.UoM__c = 'G';
        oli.Quantity_of_Sample_Grams__c = 100;
        lstOpportunityLineItem.add(oli);     
        insert lstOpportunityLineItem;
    }

    @isTest    
    public static void fetchOpportunityLineItemWrapperTest() {
        List<Opportunity> oppRecordId = [SELECT id, Name From Opportunity Limit 1];
        List<RequestForSamplingController.OpportunityLineItemWrapper> OpportunityLineItemWrapperList = new List<RequestForSamplingController.OpportunityLineItemWrapper>();
        OpportunityLineItemWrapperList = RequestForSamplingController.fetchOpportunityLineItemWrapper(oppRecordId[0].Id);
        System.debug('OpportunityLineItemWrapperList=> '+OpportunityLineItemWrapperList);
        System.assertEquals(1, OpportunityLineItemWrapperList.size());
        
        OpportunityLineItemWrapperList[0].firstSampleDueDate =System.Today();
        OpportunityLineItemWrapperList[0].PDandIUserId = UserInfo.getUserId();
        
        String response = RequestForSamplingController.processSampleRequests(OpportunityLineItemWrapperList);
        System.debug('response=>'+response);
        //System.assertEquals('SUCCESS', response);
    }
}