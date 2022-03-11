@isTest
public class FetchQLAandQLIDetailsTest {
	@testSetup
    public static void createData()
    {
         Account acc=new Account();
        acc.Name='Spices';
        acc.BillingCountry='India';
        acc.BillingStreet='xyz area';
        insert acc;
        
        Contact con =new Contact();
        con.AccountId=acc.Id;
        con.LastName='Ben';
        con.Email='abc@gmail.com';
        insert con;
       
         /*Product2 p=new Product2();
        p.Name='BP-14';
        p.IsActive=true;
		insert p;  
        
        Pricebook2 pb2 = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
		 PricebookEntry pbe=new PricebookEntry();
        pbe.Product2Id=p.Id;
        pbe.Pricebook2Id=pb2.Id;
        pbe.UnitPrice=54;
        insert pbe;*/
        
        Product2 prod = new Product2(
            Name = 'Cocoa Beans',
            IsActive = true
        );
        insert prod;
        
        /*Product2 prod2 = new Product2(
            Name = 'Cocoa Butter',
            IsActive = true
        );
        insert prod2;*/
        
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('PBI '+pricebookId);
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe;
        
        /*PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod2.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe2;*/
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='Gain';
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
        oli.Product_Configuration__c='[ {"customer_sap_id": "cust123","customer_material_code": "6642331","olam_material_code": "100000009688","configurations":[{"mic": "-U100","varient_character_mapping": "","description": "MOLD COUNT PER GRAM","uom": "%","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,000 - 500,000","customer_range": "0,000 - 500,000"}, { "mic": "","varient_character_mapping": "MOIST","description": "Moist 6","uom": "","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,00 - 500,00","customer_range": ""}]}]';
        insert oli;
        
        Quote q=new Quote();
        q.OpportunityId=opp.Id;
        //q.ContactId=con.Id;
        //q.AccountId=acc.Id;
        q.Name=opp.Name;
        q.Bussiness_Unit__c=opp.Business_Unit__c;
        q.ExpirationDate=opp.CloseDate;
        //q.Ship_To_Party__c=acc.Id;
        q.Status='Draft';
        
        insert q;
        
        QuoteLineItem qli=new QuoteLineItem();
        qli.QuoteId=q.Id;
        //qli.Product2Id=p.Id;
        qli.PricebookEntryId=pbe.Id;
        qli.UnitPrice = 0;
        qli.Volume__c=3;
        qli.Quantity=5;
        qli.Product_Configuration__c='[{"olam_material_code":"100000039072","customer_sap_id":"1234","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 700,00"}]}]'; 
        insert qli;
        
        Quote_Line_Approval__c qla=new Quote_Line_Approval__c();
        qla.Account__c=acc.Id;
        qla.Quote_Line_Item__c=qli.Id;
        qla.Quote__c=q.Id;
        
        insert qla;
    }
    public static testmethod void testData()
    {
       
        Quote_Line_Approval__c qla=[SELECT Id,Name,Product_Name__c,Price__c,Volume__c,Inco_Terms__c,Payment_Terms__c,CurrencyIsoCode,Quote_Line_Item__r.Quote.Contract_Start_Date__c,Quote_Line_Item__r.Quote.Contract_End_Date__c,Quote_Line_Item__r.Approval_Status__c,Quote_Line_Item__r.Product_Configuration__c,Quote_Line_Item__r.Unit_Of_Measure__c,Quote_Line_Item__r.Quote.Account.Name  FROM Quote_Line_Approval__c ];
        //system.debug('qla============>'+qla);
        system.assert(qla!=null, 'Null values found');
        FetchQLAandQLIDetails fd=new FetchQLAandQLIDetails();
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
      
        fd.quoteLineApprovalId=qla.Id;
       // 
        fd.getQuoteLineApproval();
        fd.getProductConfig();
        system.debug('getqla============>'+fd.getQuoteLineApproval());
        
    }
    
}