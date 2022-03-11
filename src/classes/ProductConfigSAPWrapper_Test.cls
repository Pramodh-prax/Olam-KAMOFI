//created by ashwini godase
@isTest
public class ProductConfigSAPWrapper_Test {
    
     @testSetup
    public static void setupData()
    {
        //Create an Account
        //Account acc = TestData_Factory.createAccount(true);
        Account acc = new Account();
        acc.name='TestForIcon';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        //acc.Segment__c = 'Agent/ Distributor';
        insert acc;
        
        //Get the pricebookId
        Id pricebookId = Test.getStandardPricebookId();
        
       
        Product2 prod = new Product2(
            Name = 'Cocoa123',
            IsActive = true
        );
        insert prod;
        // Id pricebookId = Test.getStandardPricebookId();
        System.debug('PBI '+pricebookId);
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe;
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='TestOppForGainProdConfg';
        //opp.ContactId=con.Id;
        opp.StageName='Offering';
        opp.CloseDate=System.today()+1;
        opp.Type='New Business';
        opp.Business_Unit__c='Spice';
        opp.Pricebook2Id=pricebookId;
        //opp.CurrencyIsoCode='USD - U.S. Dollar';
        insert opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.UnitPrice=44;
        oli.PricebookEntryId=pbe.Id;
        insert oli;
        Quote quote=new Quote();
        quote.OpportunityId=opp.Id;
        quote.Name=opp.Name;
        quote.Bussiness_Unit__c=opp.Business_Unit__c;
        quote.ExpirationDate=opp.CloseDate;
        quote.Status='Draft';
        insert quote;
        QuoteLineItem qli=new QuoteLineItem();
        qli.QuoteId=quote.Id;
        //qli.Product2Id=p.Id;
        qli.PricebookEntryId=pbe.Id;
        qli.UnitPrice = 0;
        qli.Volume__c=3;
        qli.Quantity=5;
        qli.Approver_Comment__c = 'Test';
        qli.Product_Configuration__c='[{"olam_material_code":"100000039072","customer_sap_id":"1234","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 500,00"}]}]';
        insert qli;
         
    }
    @isTest
    public static void QuoteLineProductConfigCntl()
    {
        test.startTest();
        List<QuoteLineItem> QuoLIList = [Select id,Product2.Name,quoteid,Approval_Status__c,Product_Configuration__c from QuoteLineItem];
        String result=QuoteLineProductConfigCntl.getConfigurations(QuoLIList[0].id);
        System.debug('result:'+result);
        System.assert(result!=null && result!='', 'Result is null');
        
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
        
        listOfProdConfigSAPWrapper.add(sapWrapper);
        
        String prodConfig = Json.serialize(listOfProdConfigSAPWrapper);
        System.debug('prodConfig: '+prodConfig); 
        String json='{"olam_material_code":"100000039072","customer_sap_id":"1234","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 500,00"}]}';
        String result1=QuoteLineProductConfigCntl.saveConfigurtions(QuoLIList[0].id, json);
        System.assert(result1!=null && result1!='', 'Result is null');
      
        test.stopTest();
    }
     @isTest
    public static void CatchException()
    {
        test.startTest();
        QuoteLineItem qli=new QuoteLineItem();
        String json='{"olam_material_code":"100000039072","customer_sap_id":"1234","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 500,00"}]}';
        String result1=QuoteLineProductConfigCntl.saveConfigurtions(qli.id, json);
        test.stopTest();
    }
}