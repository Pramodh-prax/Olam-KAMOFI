@isTest
public class TestData_Factory{
    public Static Account createAccount(Boolean bInsert){
        Account acc = new Account();
        acc.name='Test01';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        acc.Segment__c = 'Bakery';
        if(bInsert){
            insert acc;
        }
        return acc;
    }
    public Static Opportunity createOpportunity(Account acc, Id pricebookId, Boolean bInsert ){
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Briefing';
        opp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        opp.CloseDate = System.today();
        opp.Business_Unit__c = 'Cocoa';
        opp.Application__c = 'Bakery';
        opp.Pricebook2Id = pricebookId;
        opp.CurrencyIsoCode = 'USD';
        if(bInsert){
            insert opp;
        }
        return opp;
    }
    public Static Quote createQuote(Account acc, Opportunity opp, Boolean bInsert ){
        Quote quote=new Quote();
        quote.OpportunityId=opp.Id;
        //quote.AccountId = acc.Id;
        quote.Name=opp.Name;
        quote.Bussiness_Unit__c=opp.Business_Unit__c;
        quote.ExpirationDate=opp.CloseDate;
        quote.Status='Draft';
        if(bInsert){
            insert quote;
        }
        return quote;
    }
    public Static Product2 createProduct(String Family,String Category, String SubCategory,String SubCategory2, Boolean bInsert ){
        Product2 prod = new Product2();
        prod.Name = 'Cocoa Beans';
        prod.IsActive = true;
        prod.Family = Family;
        prod.Product_Category__c = Category;
        prod.Product_Sub_Category__c = SubCategory;
        prod.Product_Sub_Category_2__C = SubCategory2;
        prod.Brand__c = '';
        prod.External_Product_Code__c = 'externalProductCode';
        if(bInsert){
            insert prod;
        }
        return prod;
    }
    public Static PricebookEntry createPricebookEntry(Id pricebookId, Product2 prod, Boolean bInsert ){
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        if(bInsert){
            insert pbe;
        }
        return pbe;
    }
    public Static QuoteLineItem createQuoteLineItem(PricebookEntry pbe, Product2 prod, Quote quote, Boolean bInsert ){
        QuoteLineItem qLI = new QuoteLineItem();
        qLI.QuoteId = quote.Id;
        qLI.Approval_Required__c = 'No';
        //qLI.Approval_Status__c = 'Not Started';
        qLI.PricebookEntryId = pbe.Id;
     
        qLI.Product2Id = prod.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 1;
        if(bInsert){
            insert qLI;
        }
        return qLI;
    }
    
    
      public Static QuoteLineItem createQuoteLineItemNew(PricebookEntry pbe, Product2 prod, Quote quote,String appstatus, Boolean bInsert ){
        QuoteLineItem qLI = new QuoteLineItem();
        qLI.QuoteId = quote.Id;
        qLI.Approval_Required__c = 'Yes';
       qLI.Approval_Status__c =appstatus;
        qLI.PricebookEntryId = pbe.Id;
        qLI.Product2Id = prod.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 1;
        if(bInsert){
            insert qLI;
        }
        return qLI;
    }
    public static ContentVersion createContentVersion(Boolean bInsert){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        if(bInsert){
            insert cv;
        }
        return cv;
    }
    public static Asset createApprovedSKU(Account acc, Product2 prod,Boolean bInsert){
        Asset approvedSKU = new Asset();
        approvedSKU.Name = 'approvedSKUCheck';
        approvedSKU.AccountId = acc.Id;
        approvedSKU.Product2Id = prod.Id;
        approvedSKU.Customer_Material_Code__c ='approvedSKUCheck';
        approvedSKU.Product_Configuration__c ='[{"olam_material_code":"100000039072","customer_sap_id":"6767","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 500,00"}]}]';   if(bInsert){
            insert approvedSKU;
        }
        return approvedSKU;
    }
    public static ProductConfigMaster__c createProdConfigMaster(Product2 prod,Boolean bInsert){
        ProductConfigMaster__c prodConfigMaster = new ProductConfigMaster__c();
        prodConfigMaster.Name = 'prodConfigMaster';
        prodConfigMaster.Product_Category__c = prod.Product_Category__c;
        prodConfigMaster.Product_Sub_Category__c = prod.Product_Sub_Category__c;
        prodConfigMaster.Product_Sub_Category_2__C = prod.Product_Sub_Category_2__C;
        //prodConfigMaster.Product_Configuration__c ='[{"category": "","mic": "MOLD6","varient_character_mapping": "ZVAR_MULTI_MOLD6","description": "MOLD 6","uom": "", "quantitative": "Yes","qualitative": "","olam_range": "0,00 - 500,00","customer_range": "0,00 - 500,00"},{"category": "","mic": "MOLD6","varient_character_mapping": "ZVAR_MULTI_MOLD6","description": "MOLD 6","uom": "", "quantitative": "Yes","qualitative": "","olam_range": "0,00 - 500,00","customer_range": "0,00 - 500,00"}]';
        prodConfigMaster.Product_Configuration__c ='[ {"customer_sap_id": "cust123","customer_material_code": "6642331","olam_material_code": "100000009688","configurations":[{"mic": "-U100","varient_character_mapping": "","description": "MOLD COUNT PER GRAM","uom": "%","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,000 - 500,000","customer_range": "0,000 - 500,000"}, { "mic": "","varient_character_mapping": "MOIST","description": "Moist 6","uom": "","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,00 - 500,00","customer_range": ""}]}]';
        if(bInsert){
            insert prodConfigMaster;
        }
        return prodConfigMaster;
    }
    public static Pricebook2 createPriceBook(Boolean bInsert){
        Pricebook2 customPB = new Pricebook2(Name='Spices Pricebook', isActive=true);
        
        if(bInsert){
            insert customPB;
        }
        return customPB;
    }
    
        
}