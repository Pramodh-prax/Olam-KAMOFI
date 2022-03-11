@isTest(seeAllData=false)
public class OpportunityVolumeRollUpPromiseTest {
    
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
        newOpp.CloseDate=system.today().addDays(10);
        newOpp.Business_Unit__c='Cocoa';
        newOpp.StageName='Offering';
        newOpp.RecordTypeId=OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID;
        newOpp.Pricebook2Id = pb.Id;

        Opportunity newOpp1=new Opportunity();
        newOpp1.AccountId=acc.Id;
        newOpp1.Name='Sample opp';
        newOpp1.CloseDate=system.today().addDays(10);
        newOpp1.Business_Unit__c='Cocoa';
        newOpp1.StageName='Offering';
        newOpp1.RecordTypeId=OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID;
        newOpp1.Pricebook2Id = pb.Id;
        insert new List<Opportunity> {newOpp, newOpp1};
		//Create a Quote
        Quote quote = TestData_Factory.createQuote(acc, newOpp, true);
        quote.status ='Customer Accepted';
        update quote;
        //Create a Quote
        Quote quote1 = TestData_Factory.createQuote(acc, newOpp1, true);
        quote1.status ='Customer Accepted';
        update quote1;

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
        oppLineItem.Sampling_Status__c='1';
        oppLineItem.UoM__c = 'G';
        oppLineItem.Quantity_of_Sample_Grams__c = 100; 
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

    @isTest
    static void basic_test_create_budget () {
        List<Opportunity> oppList =  [SELECT Id, AccountId, Business_Unit__c, CloseDate, OwnerId FROM Opportunity WHERE Name = 'Sample opp' LIMIT 2];
        System.assert(oppList != null && !oppList.isEmpty() && oppList.size() > 1, 'Unable to find opportunities');

        // for (Opportunity opp : oppList) {
        //     opp.StageName = OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON;
        //     opp.Actual_Developing_Hours__c = 20;    
        // }

        oppList[0].StageName = OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON;
        oppList[0].Actual_Developing_Hours__c = 20; 
        update oppList[0];

        oppList[1].StageName = OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON;
        oppList[1].Actual_Developing_Hours__c = 20;  
        update oppList[1];

        Test.startTest();

        OpportunityVolumeRollUpPromise promiseObj = new OpportunityVolumeRollUpPromise (oppList [0]);
    
        for (Integer index = 1; index < oppList.size(); index ++) {
            promiseObj.then(new OpportunityVolumeRollUpPromise (oppList[index]));
        }

        System.enqueueJob(promiseObj);
        Test.stopTest();

        List<Budget_vs_Actuals__c> budgets = [SELECT Id, Account__c, Business_Unit__c, Year__c, 
                                        (SELECT Id, Category__c, Sub_Category__c, Sub_Category_2__c FROM Budget_vs_Actual_Lines__r)
                                        FROM Budget_vs_Actuals__c
                                        WHERE  Account__c =: oppList[0].AccountId 
                                        AND Business_Unit__c =: oppList[0].Business_Unit__c
                                        AND Year__c =: String.valueOf (oppList[0].CloseDate.year ())
                                        LIMIT 1
                                    ];
        //System.assert(budgets != null && budgets.size () > 0, 'Budget vs Actuals records not created');
        //System.assertEquals(oppList[0].AccountId, budgets[0].Account__c, 'Account Id mismatch');
        //System.assertEquals(oppList[0].Business_Unit__c, budgets[0].Business_Unit__c, 'BU Id mismatch');
        //System.assertEquals(String.valueOf(oppList[0].CloseDate.year ()), budgets[0].Year__c, 'Year Id mismatch');

        Set<String> catSet = new Set<String> {'Cocoa Liquor', 'Cocoa Beans'};
        //System.assert(budgets[0].Budget_vs_Actual_Lines__r.size () ==  2, 'Line items did not created/ mismatch');
       // for (Budget_vs_Actual_Line__c line : budgets[0].Budget_vs_Actual_Lines__r) {
            //System.assert(catSet.contains(line.Category__c), 'Line item Category__c mismatch');
        //}
    }
    @isTest
    static void test_no_budget_creation () {
        List<Opportunity> oppList =  [SELECT Id, AccountId, Business_Unit__c, CloseDate, OwnerId FROM Opportunity WHERE Name = 'Sample opp' LIMIT 2];
        System.assert(oppList != null && !oppList.isEmpty() && oppList.size() > 1, 'Unable to find opportunities');
        Test.startTest();

        OpportunityVolumeRollUpPromise promiseObj = new OpportunityVolumeRollUpPromise (oppList [0]);
    
        for (Integer index = 1; index < oppList.size(); index ++) {
            promiseObj.then(new OpportunityVolumeRollUpPromise (oppList[index]));
        }

        System.enqueueJob(promiseObj);
        Test.stopTest();

        List<Budget_vs_Actuals__c> budgets = [SELECT Id, Account__c, Business_Unit__c, Year__c, 
                                        (SELECT Id, Category__c, Sub_Category__c, Sub_Category_2__c FROM Budget_vs_Actual_Lines__r)
                                        FROM Budget_vs_Actuals__c
                                        WHERE  Account__c =: oppList[0].AccountId 
                                        AND Business_Unit__c =: oppList[0].Business_Unit__c
                                        AND Year__c =: String.valueOf (oppList[0].CloseDate.year ())
                                        LIMIT 1
                                    ];
        System.assert(budgets != null && budgets.size () > 0, 'Budget vs Actuals records not created');
        System.assertEquals(oppList[0].AccountId, budgets[0].Account__c, 'Account Id mismatch');
        System.assertEquals(oppList[0].Business_Unit__c, budgets[0].Business_Unit__c, 'BU Id mismatch');
        System.assertEquals(String.valueOf(oppList[0].CloseDate.year ()), budgets[0].Year__c, 'Year Id mismatch');

        System.assert(budgets[0].Budget_vs_Actual_Lines__r.size () ==  0, 'Line items are created');
    }
    
    @isTest
    static void test_no_budget_creation_constructor () {
        List<Opportunity> oppList =  [SELECT Id, AccountId, Business_Unit__c, CloseDate, OwnerId FROM Opportunity WHERE Name = 'Sample opp' LIMIT 2];
        System.assert(oppList != null && !oppList.isEmpty() && oppList.size() > 1, 'Unable to find opportunities');
        Test.startTest();

        OpportunityVolumeRollUpPromise promiseObj = new OpportunityVolumeRollUpPromise (oppList [0],
            new List<OpportunityVolumeRollUpPromise> {
                new OpportunityVolumeRollUpPromise (oppList [1])
            }                                                                               
        );

        System.enqueueJob(promiseObj);
        Test.stopTest();

        List<Budget_vs_Actuals__c> budgets = [SELECT Id, Account__c, Business_Unit__c, Year__c, 
                                        (SELECT Id, Category__c, Sub_Category__c, Sub_Category_2__c FROM Budget_vs_Actual_Lines__r)
                                        FROM Budget_vs_Actuals__c
                                        WHERE  Account__c =: oppList[0].AccountId 
                                        AND Business_Unit__c =: oppList[0].Business_Unit__c
                                        AND Year__c =: String.valueOf (oppList[0].CloseDate.year ())
                                        LIMIT 1
                                    ];
        System.assert(budgets != null && budgets.size () > 0, 'Budget vs Actuals records not created');
        System.assertEquals(oppList[0].AccountId, budgets[0].Account__c, 'Account Id mismatch');
        System.assertEquals(oppList[0].Business_Unit__c, budgets[0].Business_Unit__c, 'BU Id mismatch');
        System.assertEquals(String.valueOf(oppList[0].CloseDate.year ()), budgets[0].Year__c, 'Year Id mismatch');

        System.assert(budgets[0].Budget_vs_Actual_Lines__r.size () ==  0, 'Line items are created');
    }

    @isTest
    static void test_no_budget_creation_exception () {
        List<Opportunity> oppList =  [SELECT Id, Business_Unit__c, CloseDate, OwnerId FROM Opportunity WHERE Name = 'Sample opp' LIMIT 2];
        System.assert(oppList != null && !oppList.isEmpty() && oppList.size() > 1, 'Unable to find opportunities');
        Test.startTest();

        OpportunityVolumeRollUpPromise promiseObj = new OpportunityVolumeRollUpPromise (oppList [0]);
    
        for (Integer index = 1; index < oppList.size(); index ++) {
            promiseObj.then(new OpportunityVolumeRollUpPromise (oppList[index]));
        }

        System.enqueueJob(promiseObj);
        Test.stopTest();
        
        List<KAM_Queuable_Error_Log__c> errors = [SELECT Id, Apex_Class__c FROM KAM_Queuable_Error_Log__c LIMIT 1];
        System.assert(errors.size() > 0, 'Exception log not captured');
        System.assertEquals('OpportunityVolumeRollUpPromise', errors[0].Apex_Class__c, 'Mismatch in class name');
    }
}