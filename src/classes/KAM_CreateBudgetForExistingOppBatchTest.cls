@isTest(seeAllData=false)
public class KAM_CreateBudgetForExistingOppBatchTest {
    @TestSetup
    static void makeData(){
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'Custom PB';
        pb.IsActive = true;            
        insert pb;

        Product2 product1 = creaeProduct ('P1', 'Some desc', 'SFDC-123', '03-Cocoa and Speciality', 'Cocoa Liquor', 'Natural', null, '1');
        Product2 product2 = creaeProduct ('P1', 'Some desc', 'SFDC-123', '03-Cocoa and Speciality', 'Cocoa Beans', null, null, '2');
        insert new List<Product2> {product1, product2};

        PricebookEntry pbe1 = createPriceBookEntry(product1, pb);
        PricebookEntry pbe2 = createPriceBookEntry(product2, pb);
        insert new List<PricebookEntry> {pbe1, pbe2};
        

        Account acc=new Account();
        acc.Name='Test';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;

        Opportunity newOpp=new Opportunity();
        newOpp.AccountId=acc.Id;
        newOpp.Name='Sample opp';
        newOpp.CloseDate=system.today();
        newOpp.Business_Unit__c='Cocoa';
        newOpp.StageName='Offering';
        newOpp.RecordTypeId=OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID;
        newOpp.Pricebook2Id = pb.Id;

        Opportunity newOpp1=new Opportunity();
        newOpp1.AccountId=acc.Id;
        newOpp1.Name='Sample opp';
        newOpp1.CloseDate=system.today();
        newOpp1.Business_Unit__c='Cocoa';
        newOpp1.StageName='Offering';
        newOpp1.RecordTypeId=OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID;
        newOpp1.Pricebook2Id = pb.Id;
        insert new List<Opportunity> {newOpp, newOpp1};
	
        //Create a Quote
        Quote quote = TestData_Factory.createQuote(acc, newOpp, true);
		Quote quote1 = TestData_Factory.createQuote(acc, newOpp1, true);
        
        OpportunityLineItem oppLineItem = createOpportunityLine (newOpp.Id, pbe1.Id);
        OpportunityLineItem oppLineItem1 = createOpportunityLine (newOpp.Id, pbe2.Id);

        OpportunityLineItem oppLineItem2 = createOpportunityLine (newOpp1.Id, pbe1.Id);
        OpportunityLineItem oppLineItem3 = createOpportunityLine (newOpp1.Id, pbe2.Id);
        insert new List<OpportunityLineItem> {oppLineItem, oppLineItem1, oppLineItem2, oppLineItem3};

    }
    
    static OpportunityLineItem createOpportunityLine (Id oppId, Id pbeId) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = oppId;
        oppLineItem.PricebookEntryId = pbeId;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;

        return oppLineItem;
    }
    static Product2 creaeProduct (String name, String description, String productCode, String productFamily, String category, String subCat, String subCat2, String devCode) {
        return new Product2 (
            Name = name,
            Description = description,
            ProductCode =  productCode,
            isActive = true,
            Family = productFamily,
            Product_Category__c = category,
            Product_Sub_Category__c = subCat,
            Product_Sub_Category_2__c = subCat2,
            Development_Code__c = devCode
        );
    }

    static PricebookEntry createPriceBookEntry (Product2 p, PriceBook2 pb) {
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UseStandardPrice = false;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        
        return standardPrice;
    }
    
    @isTest static void testWithoutParameters() {
        List<Quote> q=[select id,Status from Quote];
        for (Quote qu:q){
            qu.status = 'Customer Accepted';
        }
        update q;
        List<Opportunity> oppList =[SELECT Id, StageName FROM Opportunity];
        
        for(Opportunity opp :oppList){
            opp.StageName = OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON;
        }
        update oppList[0];
        update oppList[1];
        
        Test.startTest();
        Database.executeBatch(new KAM_CreateBudgetForExistingOppBatch(),1);
        Test.stopTest();
        
        //System.assertEquals([SELECT Id FROM Budget_vs_Actuals__c].size(), 1);
        //System.assertEquals([SELECT Id FROM Budget_vs_Actual_Line__c].size(), 2);
    }
    

    @isTest static void testWithoutForYear() {
        List<Quote> q1=[select id,Status from Quote];
        for (Quote qu:q1){
            qu.status = 'Customer Accepted';
        }
        update q1;
        List<Opportunity> oppList =[SELECT Id, StageName FROM Opportunity];
        for(Opportunity opp :oppList){
            opp.StageName = OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON;
        }
        update oppList[0];
        update oppList[1];
        
        Test.startTest();
        Database.executeBatch(new KAM_CreateBudgetForExistingOppBatch(System.Today().year()),1);
        Test.stopTest();
        
        //System.assertEquals([SELECT Id FROM Budget_vs_Actuals__c].size(), 1);
        //System.assertEquals([SELECT Id FROM Budget_vs_Actual_Line__c].size(), 2);
    }    
}