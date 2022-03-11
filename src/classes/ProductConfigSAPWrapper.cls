public class ProductConfigSAPWrapper {
    
    public String customer_sap_id {get;set;}
    public String customer_material_code {get;set;}
    public String olam_material_code {get;set;}
    //public String material_description {get;set;}
    public List<ProductConfigWrapper> configurations {get;set;}
    
    public class ProductConfigWrapper {
        @AuraEnabled public String mic {get;set;}
        @AuraEnabled public String varient_character_mapping {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String uom {get;set;}
        @AuraEnabled public String quantitative {get;set;}
        @AuraEnabled public String qualitative {get;set;}
        @AuraEnabled public String olam_range {get;set;}
        @AuraEnabled public String customer_range {get;set;}
        @AuraEnabled public String indicator {get;set;}
        //@AuraEnabled public String category {get;set;}
        
        
        public ProductConfigWrapper(){
        }
    }
    
    /*public TT_HEADER  TT_HEADER {get;set;}
    public TT_INPUT  TT_INPUT {get;set;}
    public TT_ITEM  TT_ITEM {get;set;}
    
    public class TT_HEADER {
        public List<TT_HEADER_Item> item {get;set;}
    }
    public class TT_INPUT {
        public List<TT_INPUT_Item> item {get;set;}
    }
    public class TT_ITEM {
        public List<TT_ITEM_Item> item {get;set;}
    }
    public class TT_HEADER_Item {
        public String FGMAT {get;set;}
        public String MAKTX {get;set;}
        public String PROCODE {get;set;}
        public String CUSTPROD {get;set;}
        public String CONFIGURATION {get;set;}
    }
    public class TT_INPUT_Item {
        public String KUNWE {get;set;}
        public String MATNR_OLAM {get;set;}
        public String CUST_MAT {get;set;}
    }
    public class TT_ITEM_Item {
        public String CONFIGURATION {get;set;}
        public String CONTRACT {get;set;}
        public String CATEGORY {get;set;}
        public String MIC {get;set;}
        public String ZVARCHAR {get;set;}
        public String ZDESC {get;set;}
        public String UOM {get;set;}
        public String QUANT {get;set;}
        public String QUALI {get;set;}
        public String RANGE {get;set;}
        public String PROD_SPEC {get;set;}
    }*/
}