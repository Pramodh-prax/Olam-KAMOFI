@isTest
public class UploadCSVonOppTest {
    //Public Opportunity OppRec;
    
    @testSetup
    public static void prepare() {
        
        Account acc = new Account(Name = 'UNIT TEST account', BillingStreet = 'Test 1 street', BillingCountry = 'Singapore');
        insert acc;
        
        Id RecordTypeIdTenderOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Tendering_Opportunity').getRecordTypeId();
        Opportunity opp1 = new Opportunity(AccountId = acc.Id, 
                                              Name = 'unittest - opp1',
                                              StageName = 'New',
                                              CloseDate = date.newInstance(2050, 11, 21),
                                              RFP_Open_Date__c = date.newInstance(2050, 07, 21),
                                              RFP_Due_Date__c = date.newInstance(2050, 08, 21),
                                              RecordTypeId = RecordTypeIdTenderOpportunity,
                                              Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA);
        
        insert opp1;
        
        //add pricebook
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        /*Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );*/
        
        //Create product and add External code
        Product2 product1 = new Product2(Name = 'UNIT TEST Product 1',External_Product_Code__c='000000100000041429');
        insert product1;
    }
    @isTest
    public static void CheckPriceBook1() {
        Test.startTest();
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        UploadCSVonOpp.CheckPriceBook(opp1.Id);
        
        UploadCSVonOpp.CheckPriceBook(opp1.Id);
        Test.stopTest();
    }
    @isTest
    public static void CheckPriceBook2() {
        Test.startTest();
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        opp1.Pricebook2Id = NULL;
        opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA;
        update opp1;
        UploadCSVonOpp.CheckPriceBook(opp1.Id);
        
        opp1.Pricebook2Id = NULL;
        opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_DAIRY;
        update opp1;
        UploadCSVonOpp.CheckPriceBook(opp1.Id);
        
        opp1.Pricebook2Id = NULL;
        opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_EDIBLE_NUTS;
        update opp1;
        UploadCSVonOpp.CheckPriceBook(opp1.Id);
        
        opp1.Pricebook2Id = NULL;
        opp1.Business_Unit__c = '';
        update opp1;
        UploadCSVonOpp.CheckPriceBook(opp1.Id);
        
        Test.stopTest();
    }
    @isTest
    public static void getTenderMetadatDetails1() {
        Test.startTest();
        UploadCSVonOpp.getTenderMetadatDetails();
        Test.stopTest();
    }
    @isTest
    public static void insertData1() {
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        //opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA;
        //update opp1;
        Test.startTest();
        String strfromle ='{"Product Family":"Cocoa","Product Category":"Cocoa Liquor","Product Sub Category":"Natural","Product Sub Category 2":"","Olam Material Code":"","Olam Material Description":"Product three","Customer Material Code":654322,"Customer Material Specification":654322,"Customer Material Description":"Product three","Package Type":"Package Type two","Region":"Southern Asia","Country":"India","Key Incoterm":"CFR","Contract start date":"18/09/2021","Contract end date":"20/09/2021","Tentative Bid Volumes":50,"Finalised Volume":50,"UoM":"MT","Price/UoM":67,"Is offered by Olam?":"No","Approved to Supply":"Yes","Reason":"Some reason"}';
        UploadCSVonOpp.insertData(strfromle,opp1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void insertData2() {
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        //opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA;
        //update opp1;
        Test.startTest();
        String strfromle ='{"Product Family":"Cocoa","Product Category":"Cocoa Liquor","Product Sub Category":"Natural","Product Sub Category 2":"","Olam Material Code":"","Olam Material Description":"Product three","Customer Material Code":654322,"Customer Material Specification":654322,"Customer Material Description":"Product three","Package Type":"Package Type two","Region":"Southern Asia","Country":"India","Key Incoterm":"CFR","Contract start date":"18/09/2021","Contract end date":"20/09/2021","Tentative Bid Volumes":50,"Finalised Volume":50,"UoM":"MT","Price/UoM":67,"Is offered by Olam?":"Yes","Approved to Supply":"Yes","Reason":"Some reason"}';
        UploadCSVonOpp.insertData(strfromle,opp1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void insertData3() {
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        //opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA;
        //update opp1;
        Test.startTest();
        String strfromle ='{"Product Family":"","Product Category":"Cocoa Liquor","Product Sub Category":"Natural","Product Sub Category 2":"","Olam Material Code":"","Olam Material Description":"Product three","Customer Material Code":654322,"Customer Material Specification":654322,"Customer Material Description":"Product three","Package Type":"Package Type two","Region":"Southern Asia","Country":"India","Key Incoterm":"CFR","Contract start date":"18/09/2021","Contract end date":"20/09/2021","Tentative Bid Volumes":50,"Finalised Volume":50,"UoM":"MT","Price/UoM":67,"Is offered by Olam?":"Yes","Approved to Supply":"Yes","Reason":"Some reason"}';
        UploadCSVonOpp.insertData(strfromle,opp1.Id);
        Test.stopTest();
    }
    @isTest
    public static void insertData4() {
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        //opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA;
        //update opp1;
        Test.startTest();
        String strfromle ='{"Product Family":"ABC","Product Category":"Cocoa Liquor","Product Sub Category":"Natural","Product Sub Category 2":"","Olam Material Code":"","Olam Material Description":"Product three","Customer Material Code":654322,"Customer Material Specification":654322,"Customer Material Description":"Product three","Package Type":"Package Type two","Region":"Southern Asia","Country":"India","Key Incoterm":"CFR","Contract start date":"18/09/2021","Contract end date":"20/09/2021","Tentative Bid Volumes":50,"Finalised Volume":50,"UoM":"MT","Price/UoM":67,"Is offered by Olam?":"Yes","Approved to Supply":"Yes","Reason":"Some reason"}';
        UploadCSVonOpp.insertData(strfromle,opp1.Id);
        Test.stopTest();
    }
    @isTest
    public static void insertData5() {
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        //opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA;
        //update opp1;
        Test.startTest();
        String strfromle ='{"Product Family":"Cocoa","Product Category":"Cocoa Liquor","Product Sub Category":"Natural","Product Sub Category 2":"","Olam Material Code":"xyz","Olam Material Description":"Product three","Customer Material Code":654322,"Customer Material Specification":654322,"Customer Material Description":"Product three","Package Type":"Package Type two","Region":"Southern Asia","Country":"India","Key Incoterm":"CFR","Contract start date":"18/09/2021","Contract end date":"20/09/2021","Tentative Bid Volumes":50,"Finalised Volume":50,"UoM":"MT","Price/UoM":67,"Is offered by Olam?":"Yes","Approved to Supply":"Yes","Reason":"Some reason"}';
        UploadCSVonOpp.insertData(strfromle,opp1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void insertData6() {
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        Product2 prod1 = new Product2();
        prod1 = [select id,name,External_Product_Code__c from Product2 limit 1]; //External_Product_Code__c
        //opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA;
        //update opp1;
        Test.startTest();
        String strfromle ='{"Product Family":"Cocoa","Product Category":"Cocoa Liquor","Product Sub Category":"Natural","Product Sub Category 2":"","Olam Material Code":"100000041429","Olam Material Description":"Product three","Customer Material Code":654322,"Customer Material Specification":654322,"Customer Material Description":"Product three","Package Type":"Package Type two","Region":"Southern Asia","Country":"India","Key Incoterm":"CFR","Contract start date":"18/09/2021","Contract end date":"20/09/2021","Tentative Bid Volumes":50,"Finalised Volume":50,"UoM":"MT","Price/UoM":67,"Is offered by Olam?":"Yes","Approved to Supply":"Yes","Reason":"Some reason"}';
        UploadCSVonOpp.insertData(strfromle,opp1.Id);
        Test.stopTest();
    }
     @isTest
    public static void insertData7() {
        Opportunity opp1 = new Opportunity();
        opp1 = [select id,Pricebook2Id,name,Business_Unit__c from Opportunity limit 1];
        Product2 prod1 = new Product2();
        prod1 = [select id,name,External_Product_Code__c from Product2 limit 1]; //External_Product_Code__c
        //opp1.Business_Unit__c = OpportunityConstants.OPPORTUNITY_BU_COCOA;
        //update opp1;
        Test.startTest();
        String strfromle ='{}';
        UploadCSVonOpp.insertData(strfromle,'');
        
        strfromle ='{"Product Family":"Cocoa","Product Category":"Cocoa Liquor","Product Sub Category":"Natural","Product Sub Category 2":"","Olam Material Code":"","Olam Material Description":"Product three","Customer Material Code":654322,"Customer Material Specification":654322,"Customer Material Description":"Product three","Package Type":"Package Type two","Region":"Southern Asia","Country":"India","Key Incoterm":"CFR","Contract start date":"18/099/2021","Contract end date":"20/09/2021","Tentative Bid Volumes":50,"Finalised Volume":50,"UoM":"MT","Price/UoM":67,"Is offered by Olam?":"Yes","Approved to Supply":"Yes","Reason":"Some reason"}';
        UploadCSVonOpp.insertData(strfromle,opp1.Id);
        
        strfromle ='{}';
        UploadCSVonOpp.insertData(strfromle,opp1.Id);
        Test.stopTest();
    }
    
}