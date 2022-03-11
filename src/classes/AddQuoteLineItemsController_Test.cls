@isTest
public class AddQuoteLineItemsController_Test {
    @testSetup
    public static void setupData()
    {
        //Create an Account
        //Account acc = TestData_Factory.createAccount(true);
        Account acc = new Account(Name = 'UNIT TEST', Regions__c='USA',SAP_Account_ID__c='123', BillingStreet = 'Test 1 street', BillingCountry = 'Usa');
        insert acc;
        //Get the pricebookId
        //Id pricebookId = Test.getStandardPricebookId();
        
        Integration_Details__c intergration= new  Integration_Details__c(Name='SAP Product Configuration',
                                                                         username__c='olam.pi@olamnet.com',password__c='OlamPI@123',content_Type__c='application/json',Method__c='POST',
                                                                         Endpoint__c='https://olamapi.prod.apimanagement.eu10.hana.ondemand.com:443/ProductConfig_QA',timeOut__c=12000);
        insert intergration;
        System.debug('intergration ((: '+intergration.Username__c);
        Pricebook2 pricebook = TestData_Factory.createPriceBook(true);
        Id pricebookId = pricebook.Id;
        
        //Create an Opportunity
        Opportunity opp = TestData_Factory.createOpportunity(acc, pricebookId, true);
        
        //Create a Quote
        
        Quote quote = TestData_Factory.createQuote(acc, opp, true);
        
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'TestOppnew';
        opp1.StageName = 'Briefing';
        opp1.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        opp1.CloseDate = System.today();
        opp1.Business_Unit__c = 'Cocoa';
        //opp1.Application__c = 'Bakery';
        opp1.CurrencyIsoCode = 'USD';
        insert opp1;
        Quote quote1=new Quote();
        quote1.OpportunityId=opp1.Id;
        //quote.AccountId = acc.Id;
        quote1.Name=opp1.Name;
        quote1.Bussiness_Unit__c=opp1.Business_Unit__c;
        quote1.ExpirationDate=opp1.CloseDate;
        quote1.Status='Draft';
        insert quote1;
        
        Opportunity oppDairy = new Opportunity(AccountId = acc.Id,Name = 'TestOppDairy',StageName = 'Briefing'
                                               ,RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId()
                                               ,CloseDate = System.today(),Business_Unit__c = 'Dairy',
                                               //Application__c = 'Bakery',
                                               CurrencyIsoCode = 'USD');
        
        insert oppDairy;
        Quote quoteDairy=new Quote(OpportunityId=oppDairy.Id,Name=oppDairy.Name,Bussiness_Unit__c=oppDairy.Business_Unit__c
                                   ,ExpirationDate=oppDairy.CloseDate,Status='Draft');
        insert quoteDairy;
        
        Opportunity oppEN = new Opportunity(AccountId = acc.Id,Name = 'TestOppEN',StageName = 'Briefing'
                                            ,RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId()
                                            ,CloseDate = System.today(),Business_Unit__c = 'Edible_Nuts',
                                            //Application__c = 'Bakery',
                                            CurrencyIsoCode = 'USD');
        
        insert oppEN;
        Quote quoteEN=new Quote(OpportunityId=oppEN.Id,Name=oppEN.Name,Bussiness_Unit__c=oppEN.Business_Unit__c
                                ,ExpirationDate=oppEN.CloseDate,Status='Draft');
        insert quoteEN;
        
        Opportunity oppBuNull = new Opportunity(AccountId = acc.Id,Name = 'TestOppBUNull',StageName = 'Briefing'
                                                ,RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId()
                                                ,CloseDate = System.today(),Business_Unit__c = '',
                                               //Application__c = 'Bakery',
                                                CurrencyIsoCode = 'USD');
        
        insert oppBuNull;
        Quote quoteNull=new Quote(OpportunityId=oppBuNull.Id,Name=oppBuNull.Name,Bussiness_Unit__c=oppBuNull.Business_Unit__c
                                  ,ExpirationDate=oppBuNull.CloseDate,Status='Draft');
        insert quoteNull;
        
        Opportunity oppSpice = new Opportunity(AccountId = acc.Id,Name = 'SpiceBUOpp',StageName = 'Briefing'
                                               ,RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId()
                                               ,CloseDate = System.today(),Business_Unit__c = 'Spice',
                                               //Application__c = 'Bakery',
                                               CurrencyIsoCode = 'USD');
        
        insert oppSpice;
        Quote quoteSpice=new Quote(OpportunityId=oppSpice.Id,Name=oppSpice.Name,Bussiness_Unit__c=oppSpice.Business_Unit__c
                                   ,ExpirationDate=oppSpice.CloseDate,Status='Draft');
        insert quoteSpice;
        //Create a Product
        Product2 prod = TestData_Factory.createProduct('12-Spices', 'Tropical', 'Pepper', 'Black Pepper', true);
        
        //Create a PricebookEntry
        PricebookEntry pbe = TestData_Factory.createPricebookEntry(pricebookId, prod, true);
        
        //PricebookEntry pbe = [Select Id from PricebookEntry where Product2Id =: prod.Id and CurrencyIsoCode =: opp.CurrencyIsoCode limit 1];
        
        //Create a QuoteLineItem
        //QuoteLineItem qLI = TestData_Factory.createQuoteLineItem(pbe, prod, quote, true);
        QuoteLineItem qli=new QuoteLineItem();
        qli.QuoteId=quote.Id;
        //qli.Product2Id=p.Id;
        qli.PricebookEntryId=pbe.Id;
        qli.UnitPrice = 11;
        qli.Volume__c=3;
        qli.Quantity=5;
        qli.Approver_Comment__c = 'Test';
        qli.Product_Configuration__c='[{ "customer_sap_id" : "1000018", "customer_material_code" : "321321355", "olam_material_code" : "100000000061"},{"customer_sap_id" : "1000018", "customer_material_code" : "33112244", "olam_material_code" : "100000000091"}]';
        insert qli;
        System.debug('qLI: '+qLI);
        
        
        //Create a Product Config Master
        // ProductConfigMaster__c prodConfigMaster = TestData_Factory.createProdConfigMaster(prod,true);
        ProductConfigMaster__c prodConfigMaster =  new ProductConfigMaster__c(
            Product_Category__c='BLEND',
            Product__c=prod.id,
            Name='Product',
            Product_Configuration__c='[{"olam_material_code":"100000039072","customer_sap_id":"1234","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 700,00"}]}]'
        );
        insert prodConfigMaster;
        
        prod.Is_Product_Config_Required__c = true;
        update prod;
        //Create an Approved SKU
        Asset approvedSKU = TestData_Factory.createApprovedSKU(acc,prod,true);
        
    }
    @isTest
    public static void getPriceBooksTest1()
    {
        Quote quote = [Select id from Quote limit 1];
        System.debug('quote: '+quote);
        Test.startTest();
        AddQuoteLineItemsController.getPriceBooks(quote.Id);
        
        // quote.Pricebook2Id = Null;
        // update quote;
        Quote quote1 = [Select id from Quote where name='TestOppnew' ];
        List<PriceBook2> r1=  AddQuoteLineItemsController.getPriceBooks(quote1.Id);
        System.assert(r1!=null, 'Result Is Null');
        Quote quoteDairy = [Select id from Quote where name='TestOppDairy' ];
        AddQuoteLineItemsController.getPriceBooks(quoteDairy.Id);
        Quote quoteEN = [Select id from Quote where name='TestOppEN' ];
        AddQuoteLineItemsController.getPriceBooks(quoteEN.Id);
        Quote quoteNull = [Select id from Quote where name='TestOppBUNull' ];
        AddQuoteLineItemsController.getPriceBooks(quoteNull.Id);
        List<Quote> quoteSpice = [Select id from Quote where name='SpiceBUOpp' ];
        AddQuoteLineItemsController.getPriceBooks(quoteSpice[0].Id);
        
        Test.stopTest();
    }
    @isTest
    public static void updateQuotePriceBookTest1()
    {
        Quote quote = [Select id,PriceBook2Id from Quote limit 1];
        System.debug('quote: '+quote);
        Id pricebookId = Test.getStandardPricebookId();
        Test.startTest();
        AddQuoteLineItemsController.updateQuotePriceBook(quote.Id,pricebookId);
        AddQuoteLineItemsController.updateQuotePriceBook(quote.Id,'pricebookId');
        AddQuoteLineItemsController.updateQuotePriceBook(quote.Id,quote.PriceBook2Id);
        Test.stopTest();
    }
    @isTest
    public static void getIsApprovalRequiredValuesTest1()
    {
        Quote quote = [Select id from Quote limit 1];
        System.debug('quote: '+quote);
        Id pricebookId = Test.getStandardPricebookId();
        Test.startTest();
        AddQuoteLineItemsController.getIsApprovalRequiredValues(quote.Id);
        Test.stopTest(); //Unit_Of_Measure__c
    }
    @isTest
    public static void getselectOptionsTest1()
    {
        QuoteLineItem qli = new QuoteLineItem();
        AddQuoteLineItemsController adQLI = new AddQuoteLineItemsController();
        Test.startTest();
        AddQuoteLineItemsController.getselectOptions(qli,'Unit_Of_Measure__c');
        AddQuoteLineItemsController.getQueryString('Quote');
        Test.stopTest(); 
    }
    @isTest
    public static void fetchLineItemWrapperTest1()
    {
        Quote quote = [Select id from Quote limit 1];
        Asset apSKU = [Select id,AccountId,Product2ID,Customer_Material_Code__c,Product_Configuration__c,Product2.Product_Category__c,Product2.Product_Sub_Category__c,Product2.Product_Sub_Category_2__c,Product2.Family,Product2.Brand__c,Product2.External_Product_Code__c from Asset];
        Test.startTest();
        List<AddQuoteLineItemsController.LineItemWrapper> lstLineItemWrapper = new List<AddQuoteLineItemsController.LineItemWrapper>();
        lstLineItemWrapper = AddQuoteLineItemsController.fetchLineItemWrapper(quote.Id,apSKU.Customer_Material_Code__c,apSKU.Product2.Product_Category__c,apSKU.Product2.Product_Sub_Category__c,apSKU.Product2.Product_Sub_Category_2__c,apSKU.Product2.Brand__c,apSKU.Product2.Family);
        System.debug('lstLineItemWrapper: '+lstLineItemWrapper);
        lstLineItemWrapper = AddQuoteLineItemsController.fetchLineItemWrapper(quote.Id,apSKU.Product2.External_Product_Code__c,apSKU.Product2.Product_Category__c,apSKU.Product2.Product_Sub_Category__c,apSKU.Product2.Product_Sub_Category_2__c,apSKU.Product2.Brand__c,apSKU.Product2.Family);
        System.debug('lstLineItemWrapper: '+lstLineItemWrapper);
        lstLineItemWrapper = AddQuoteLineItemsController.fetchLineItemWrapper(quote.Id,'','','','','','');
        System.debug('lstLineItemWrapper: '+lstLineItemWrapper);
        Test.stopTest(); 
    }
    @isTest
    public static void fetchProductConfigForSelectedProductsTest1()
    {
        Quote quote = [Select id from Quote limit 1];
        Asset apSKU = [Select id,AccountId,Product2ID,Customer_Material_Code__c,Product_Configuration__c,Product2.Product_Category__c,Product2.Product_Sub_Category__c,Product2.Product_Sub_Category_2__c,Product2.Family,Product2.Brand__c,Product2.External_Product_Code__c from Asset];
        Test.startTest();
        
        
        List<ProductConfigSAPWrapper> listOfProdConfigSAPWrapper = new List<ProductConfigSAPWrapper>();
        ProductConfigSAPWrapper sapWrapper = new ProductConfigSAPWrapper();
        sapWrapper.customer_sap_id ='1234';
        sapWrapper.customer_material_code ='';
        sapWrapper.olam_material_code ='100000039072'; //Product External_Product_Code;
        
        List<ProductConfigSAPWrapper.ProductConfigWrapper> listOfProdConfigWrap = new List<ProductConfigSAPWrapper.ProductConfigWrapper>();
        
        ProductConfigSAPWrapper.ProductConfigWrapper prodConfigWrap = new ProductConfigSAPWrapper.ProductConfigWrapper();
        prodConfigWrap.mic = '-U100';
        prodConfigWrap.varient_character_mapping = 'Test';
        prodConfigWrap.description = 'MOLD COUNT PER GRAM';
        prodConfigWrap.uom = '%';
        prodConfigWrap.quantitative = 'Yes';
        prodConfigWrap.qualitative = '';
        prodConfigWrap.olam_range = '0,00 - 500,00';
        prodConfigWrap.customer_range = '0,000 - 500,000';
        prodConfigWrap.indicator = 'Product';
        listOfProdConfigWrap.add(prodConfigWrap);
        sapWrapper.configurations = listOfProdConfigWrap;
        System.debug('listOfProdConfigWrap** '+listOfProdConfigWrap);
        listOfProdConfigSAPWrapper.add(sapWrapper);
        String prodConfig = Json.serialize(listOfProdConfigSAPWrapper);
        System.debug('prodConfig: '+prodConfig); 
        
        //--------------------------
        PricebookEntry pbe=[select id,Product2.External_Product_Code__c from PricebookEntry limit 1];
        AddQuoteLineItemsController.LineItemWrapper lineItemWrapper = new AddQuoteLineItemsController.LineItemWrapper();
        lineItemWrapper.isChecked=false;
        lineItemWrapper.customerMaterialCode='12345';
        lineItemWrapper.unitPrice=1;
        lineItemWrapper.volume=2;
        lineItemWrapper.unitOfMeasure='KG';
        lineItemWrapper.isPLMApprovalRequired='';
        lineItemWrapper.isProdConfigFetched=false;
        lineItemWrapper.isFileUploaded=false;
        lineItemWrapper.isProductConfigRequired=true;
        lineItemWrapper.customerMaterialCodeUserInput='34355';
        lineItemWrapper.prodConfigSource='abc';
        lineItemWrapper.accountSAPId='123';
        AddQuoteLineItemsController.ProductConfigWrapperFinal ProductConfigWrapperFinal=new AddQuoteLineItemsController.ProductConfigWrapperFinal();
        ProductConfigWrapperFinal.prodConfigFinal=prodConfigWrap;
        ProductConfigWrapperFinal.new_range='200';
        List<AddQuoteLineItemsController.ProductConfigWrapperFinal> ListOFProductConfigWrapperFinal=new List<AddQuoteLineItemsController.ProductConfigWrapperFinal>();
        ListOFProductConfigWrapperFinal.add(ProductConfigWrapperFinal);
        lineItemWrapper.objPBE=pbe;
        lineItemWrapper.listOfProductConfigWrapperFinal=ListOFProductConfigWrapperFinal;
        //lineItemWrapper.listOfContentDocIds=
        List<AddQuoteLineItemsController.LineItemWrapper> listoflineItemWrapper = new List<AddQuoteLineItemsController.LineItemWrapper>();
        listoflineItemWrapper.add(lineItemWrapper);
        AddQuoteLineItemsController.createQuoteLineItem(quote.Id, listoflineItemWrapper);
        //-----------------------
        
        
        
        
        List<AddQuoteLineItemsController.LineItemWrapper> lstLineItemWrapper = new List<AddQuoteLineItemsController.LineItemWrapper>();
        lstLineItemWrapper = AddQuoteLineItemsController.fetchLineItemWrapper(quote.Id,apSKU.Customer_Material_Code__c,apSKU.Product2.Product_Category__c,apSKU.Product2.Product_Sub_Category__c,apSKU.Product2.Product_Sub_Category_2__c,apSKU.Product2.Brand__c,apSKU.Product2.Family);
        
        System.debug('lstLineItemWrapper: '+lstLineItemWrapper);
        System.debug('quote id*******'+quote.Id);
        //  AddQuoteLineItemsController.createQuoteLineItem(quote.Id, lstLineItemWrapper);
        //AddQuoteLineItemsController.fetchProductConfigForSelectedProducts(quote.id, lstLineItemWrapper, true);
        delete apSKU;
        Test.setMock(HttpCalloutMock.class, new MockGenerator());  
        AddQuoteLineItemsController.fetchProductConfigForSelectedProducts(quote.id, lstLineItemWrapper, true);
        Test.stopTest(); 
    }   
    @isTest
    public static void testAPI()
    {
        Quote quote = [Select id from Quote limit 1];
        Asset apSKU = [Select id,AccountId,Product2ID,Customer_Material_Code__c,Product_Configuration__c,Product2.Product_Category__c,Product2.Product_Sub_Category__c,Product2.Product_Sub_Category_2__c,Product2.Family,Product2.Brand__c,Product2.External_Product_Code__c from Asset];
        List<AddQuoteLineItemsController.LineItemWrapper> lstLineItemWrapper = new List<AddQuoteLineItemsController.LineItemWrapper>();
        lstLineItemWrapper = AddQuoteLineItemsController.fetchLineItemWrapper(quote.Id,apSKU.Customer_Material_Code__c,apSKU.Product2.Product_Category__c,apSKU.Product2.Product_Sub_Category__c,apSKU.Product2.Product_Sub_Category_2__c,apSKU.Product2.Brand__c,apSKU.Product2.Family);
       
      
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockGenerator());  
        AddQuoteLineItemsController.fetchProductConfigForSelectedProducts(quote.id, lstLineItemWrapper, true);
        Test.stopTest(); 
        
        /*
        PricebookEntry pbe=[select id,Product2.External_Product_Code__c,Product2.Is_Product_Config_Required__c from PricebookEntry limit 1];
        AddQuoteLineItemsController.LineItemWrapper lineItemWrapper = new AddQuoteLineItemsController.LineItemWrapper();
        lineItemWrapper.isChecked=false;
        lineItemWrapper.customerMaterialCode='12345';
        lineItemWrapper.unitPrice=1;
        lineItemWrapper.volume=2;
        lineItemWrapper.unitOfMeasure='KG';
        lineItemWrapper.isPLMApprovalRequired='';
        lineItemWrapper.isProdConfigFetched=false;
        lineItemWrapper.isFileUploaded=false;
        lineItemWrapper.isProductConfigRequired=true;
        lineItemWrapper.customerMaterialCodeUserInput='34355';
        lineItemWrapper.prodConfigSource='abc';
        lineItemWrapper.accountSAPId='123';
        lineItemWrapper.objPBE=pbe;
         //lineItemWrapper.listOfContentDocIds=
            List<AddQuoteLineItemsController.LineItemWrapper> listoflineItemWrapper = new  List<AddQuoteLineItemsController.LineItemWrapper>();
        listoflineItemWrapper.add(lineItemWrapper);
        Test.setMock(HttpCalloutMock.class, new MockGenerator()); 
        AddQuoteLineItemsController.fetchProductConfigForSelectedProducts(quote.id, listoflineItemWrapper, true);
     */
    }
    
    
}