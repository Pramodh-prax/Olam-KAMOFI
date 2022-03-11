//Created by Ashwini Godase 2/7/2022
@isTest
public class ProductConfigMasterTrigger_Test {
    @testSetup
    public static void setupData()
    {
        //Create Product
        Product2 prod= TestData_Factory.createProduct('12-Spices', 'Tropical', 'Pepper', 'Black Pepper', true);
        Product2 prod1= new Product2(Name='Prod2',Family='12-Spices',Product_Category__c='Tropical',
                                     Product_Sub_Category__c='Pepper',Product_Sub_Category_2__c='Black Pepper'); 
        insert prod1;
        //create ProductConfigMaster
        ProductConfigMaster__c prodConfigMaster =  new ProductConfigMaster__c(
            Product_Category__c='BLEND',
            Product__c=prod.id,
            Name='Product',
            SAP_Product_Configuration__c='{ "TT_HEADER": { "Header":[{"FGMAT": "100000056861", "MAKTX": "ON GRAN 50#BG", "PROCODE": "", "CUSTPROD": "", "CONFIGURATION": "4", "INDEX_VAL": "0-15"}]}, "TT_ITEM": { "item":[{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_YEAST", "ZDESC": "Yeast(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_MOLD", "ZDESC": "MOLD COUNT PER GRAM(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_COLIF", "ZDESC": "COLIFORM TOTAL(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_SPC", "ZDESC": "STANDARD PLATE COUNT(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_MOIST", "ZDESC": "Moisture(VAR)", "UOM": "%", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 5,000", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_BI", "ZDESC": "BULK INDEX(VAR)", "UOM": "ML", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 9999999,000 ml", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_SPECK", "ZDESC": "SPECK COUNT(VAR)", "UOM": "COU", "QUANT": "", "QUALI": "", "RANGE": "0,000 - 10,000 NT1", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_ECOLI", "ZDESC": "E.COLI   CFU(VAR)", "UOM": "", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "CHAR", "DECIMALS": "0", "INTERVALS": ""},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_PALLET_TYPE1", "ZDESC": "Pallet Type", "UOM": "", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "CHAR", "DECIMALS": "0", "INTERVALS": ""},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_IRRAD", "ZDESC": "IRRADIATED(VAR)", "UOM": "KG", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_EG", "ZDESC": "ENTROBACTERIACEAE G(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "ZVAR_MULTI_GI", "ZDESC": "GREEN INDEX(VAR)", "UOM": "%", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": ""},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_SLFTRCSP", "ZDESC": "Sulphite Redcuing Clostridium", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_MA", "ZDESC": "Meso Aerobe spores(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_COLDX", "ZDESC": "Coliform by Desoxylate (VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"},{"CONFIGURATION": "4", "CONTRACT": "NA", "MIC": "", "ZVARCHAR": "OFIUS_VAR_LCTBC", "ZDESC": "LACTOBACILLUS(VAR)", "UOM": "CFU", "QUANT": "", "QUALI": "", "RANGE": "", "C_RANGE": "", "SPEC": "M", "DATA_TYPE": "NUM", "DECIMALS": "3", "INTERVALS": "X"}]}}',
            Product_Configuration__c='[ {"customer_sap_id": "cust123","customer_material_code": "6642331","olam_material_code": "100000009688","configurations":[{"mic": "-U100","varient_character_mapping": "","description": "MOLD COUNT PER GRAM","uom": "%","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,000 - 500,000","customer_range": "0,000 - 500,000"}, { "mic": "","varient_character_mapping": "MOIST","description": "Moist 6","uom": "","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,00 - 500,00","customer_range": ""}]}]');
        insert prodConfigMaster;    
        //Update ProductConfigMaster 
        prod.Is_Product_Config_Required__c=true;
        update prod;
        
    }
    
    @isTest
    public static void checkValidations()
    {
        test.startTest();
        List<Product2> prod=[select id from Product2];
        //create ProductConfigMaster -which throws error for creating one more ProductConfigMaster
        ProductConfigMaster__c prodConfigMaster =  new ProductConfigMaster__c(
            Product_Category__c='BLEND',
            Product__c=prod[0].id,
            Name='Prodct',
            Product_Configuration__c='[ {"customer_sap_id": "cust123","customer_material_code": "6642331","olam_material_code": "100000009688","configurations":[{"mic": "-U100","varient_character_mapping": "","description": "MOLD COUNT PER GRAM","uom": "%","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,000 - 500,000","customer_range": "0,000 - 500,000"}, { "mic": "","varient_character_mapping": "MOIST","description": "Moist 6","uom": "","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,00 - 500,00","customer_range": ""}]}]');
        try{insert prodConfigMaster;}Catch(Exception e){
            System.Assert(e.getMessage().contains('You can\'t have more than 1 config for an product'));
        } 
        //delete ProductConfigMaster where ProductConfigMaster is present for a product which throws error
        ProductConfigMaster__c prodConfigMasterDetails=[Select id from ProductConfigMaster__c];
        try{delete prodConfigMasterDetails;}catch(Exception e){
             System.Assert(e.getMessage().contains('You should have atleast 1 config for an product, else make product config required to false'));
        }
        
        //update ProductConfigMaster
        prodConfigMasterDetails.Product__c=prod[1].id;
        try{ update prodConfigMasterDetails;}catch(Exception e){
            System.Assert(e.getMessage().contains('Product change is not allowed , Please create new record'));
        }
        prodConfigMasterDetails.Product_Configuration__c='';
        try{ update prodConfigMasterDetails;}catch(Exception e){
            System.Assert(e.getMessage().contains('Product Configuration Field can not be null'));
        }
        prodConfigMasterDetails.Product_Configuration__c='[ {: "cust123","customer_material_code": "6642331","olam_material_code": "100000009688","configurations":[{"mic": "-U100","varient_character_mapping": "","description": "MOLD COUNT PER GRAM","uom": "%","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,000 - 500,000","customer_range": "0,000 - 500,000"}, { "mic": "","varient_character_mapping": "MOIST","description": "Moist 6","uom": "","quantitative": "Yes","qualitative": "","indicator" : "Product","olam_range": "0,00 - 500,00","customer_range": ""}]}]';
        try{ update prodConfigMasterDetails;}catch(Exception e){
            System.Assert(e.getMessage().contains('Error Parsing Product Configuration Json'));
        }
        
        test.stopTest();
    }
}