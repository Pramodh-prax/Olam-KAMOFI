@isTest
public class QuoteCreateNewFromOpptyCntl_Test {
    @testSetup
    public static void setupData()
    {
        //Create an Account
        Account acc = TestData_Factory.createAccount(true);
        
        //Get the pricebookId
        Id pricebookId = Test.getStandardPricebookId();
        //Product2 prod= TestData_Factory.createProduct('Dairy', 'BLEND', 'Brown', 'Dairy', true);
        Product2 prod= TestData_Factory.createProduct('12-Spices', 'Tropical', 'Pepper', 'Black Pepper', true);
        
        ProductConfigMaster__c prodConfigMaster =  new ProductConfigMaster__c(
            Product_Category__c='BLEND',
            Product__c=prod.id,
            Name='Product New',
            SAP_Product_Configuration__c='{ "TT_HEADER": { "Header":[{"FGMAT": "100000056861", "MAKTX": "ON GRAN 50#BG", "PROCODE": "", "CUSTPROD": "", "CONFIGURATION": "4", "INDEX_VAL": "0-15"}]}, "TT_ITEM": { "item":[{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_YEAST", "ZDESC": "Yeast(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_MOLD", "ZDESC": "MOLD COUNT PER GRAM(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_COLIF", "ZDESC": "COLIFORM TOTAL(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_SPC", "ZDESC": "STANDARD PLATE COUNT(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_MOIST", "ZDESC": "Moisture(VAR)", "UOM": "%", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 5,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_BI", "ZDESC": "BULK INDEX(VAR)", "UOM": "ML", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000 ml", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_SPECK", "ZDESC": "SPECK COUNT(VAR)", "UOM": "COU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 10,000 NT1", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_ECOLI", "ZDESC": "E.COLI   CFU(VAR)", "UOM": "", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "CHAR", "DECIMALS": "0", "INTERVALS": ""},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_PALLET_TYPE1", "ZDESC": "Pallet Type", "UOM": "", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "CHAR", "DECIMALS": "0", "INTERVALS": ""},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_IRRAD", "ZDESC": "IRRADIATED(VAR)", "UOM": "KG", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_EG", "ZDESC": "ENTROBACTERIACEAE G(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "ZVAR_MULTI_GI", "ZDESC": "GREEN INDEX(VAR)", "UOM": "%", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": ""},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_SLFTRCSP", "ZDESC": "Sulphite Redcuing Clostridium", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_MA", "ZDESC": "Meso Aerobe spores(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_COLDX", "ZDESC": "Coliform by Desoxylate (VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_LCTBC", "ZDESC": "LACTOBACILLUS(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"}]}}',
            Product_Configuration__c='[ {"customer_sap_id": "cust123","customer_material_code": "6642331","olam_material_code": "100000009688","configurations":[{"mic": "-U100","varient_character_mapping": "","description": "MOLD COUNT PER GRAM","uom": "%","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,000 - 500,000","customer_range": "0,000 - 500,000"}, { "mic": "","varient_character_mapping": "MOIST","description": "Moist 6","uom": "","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,00 - 500,00","customer_range": ""}]}]');
        insert prodConfigMaster;   
        //Update ProductConfigMaster 
        prod.Is_Product_Config_Required__c=true;
        update prod;
        /*PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe;*/
        
        PricebookEntry pbe = [Select id from PricebookEntry limit 1];
        //Create an Opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp for gain opp';
        opp.StageName = 'Briefing';
        opp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        opp.CloseDate = System.today();
        opp.Actual_Developing_Hours__c=2;
        opp.Business_Unit__c = 'Spice';
      
        //opp.Application__c = 'Agent/ Distributor';
        opp.Pricebook2Id = pricebookId;
        opp.CurrencyIsoCode = 'USD';
        insert opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.UnitPrice=44;
        oli.PricebookEntryId=pbe.Id;
        oli.Sampling_Status__c='7';
        insert oli;
        
        
    }
    @istest
    public static void createQuote()
    {
        Opportunity opp =[Select id from Opportunity limit 1]; 
        QuoteCreateNewFromOpptyCntl.createQuote(opp.id);
        
    }
    
}