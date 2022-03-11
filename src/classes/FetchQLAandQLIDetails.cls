public class FetchQLAandQLIDetails {
    
    public Id quoteLineApprovalId {get;set;} 
    
    
    /*
    public class ProductConfigWrapper {
        @AuraEnabled public String mic {get;set;}
        @AuraEnabled public String varient_character_mapping {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String uom {get;set;}
        @AuraEnabled public String quantitative {get;set;}
        @AuraEnabled public String qualitative {get;set;}
        @AuraEnabled public String olam_range {get;set;}
        @AuraEnabled public String customer_range {get;set;}
        //@AuraEnabled public String new_range {get;set;}
        public ProductConfigWrapper(){
        }
    }*/
    public Quote_Line_Approval__c getQuoteLineApproval(){
        Quote_Line_Approval__c q= [SELECT Id,Name,Product_Name__c,Price__c,Volume__c,Inco_Terms__c,Payment_Terms__c,CurrencyIsoCode,Quote_Line_Item__r.Quote.Contract_Start_Date__c,Quote_Line_Item__r.Quote.Contract_End_Date__c,Quote_Line_Item__r.Approval_Status__c,Quote_Line_Item__r.Product_Configuration__c,Quote_Line_Item__r.Unit_Of_Measure__c,Quote_Line_Item__r.Quote.Account.Name  FROM Quote_Line_Approval__c WHERE Id=: quoteLineApprovalId];
        
        return q;
    }
    
    /*public List<ProductConfigWrapper> getProductConfig(){
        // Prod Config is available for Quote_Line_Item Id= 0QL1y000000FaBgGAK
      
        Quote_Line_Approval__c  qla= [SELECT Id,Quote_Line_Item__r.Product_Configuration__c  FROM Quote_Line_Approval__c where Id=: quoteLineApprovalId];
        List<ProductConfigWrapper> listOfProductConfigWrapper = new List<ProductConfigWrapper>();
        if((qla.Quote_Line_Item__r.Product_Configuration__c)!=null){
        listOfProductConfigWrapper = (List<ProductConfigWrapper>) JSON.deserialize(qla.Quote_Line_Item__r.Product_Configuration__c,List<ProductConfigWrapper>.class);
        }
        return listOfProductConfigWrapper;
           
        
    }*/
    
    public List<ProductConfigSAPWrapper.ProductConfigWrapper> getProductConfig(){
        // Prod Config is available for Quote_Line_Item Id= 0QL1y000000FaBgGAK
      
        Quote_Line_Approval__c  qla= [SELECT Id,Quote_Line_Item__r.Product_Configuration__c  FROM Quote_Line_Approval__c where Id=: quoteLineApprovalId];
        List<ProductConfigSAPWrapper.ProductConfigWrapper> listOfProductConfigWrapper = new List<ProductConfigSAPWrapper.ProductConfigWrapper>();
        if(String.isNotBlank(qla.Quote_Line_Item__r.Product_Configuration__c)){   
        List<ProductConfigSAPWrapper> listOfProductConfigSAPWrapper = new List<ProductConfigSAPWrapper>();
            listOfProductConfigSAPWrapper = (List<ProductConfigSAPWrapper>) JSON.deserialize(qla.Quote_Line_Item__r.Product_Configuration__c,List<ProductConfigSAPWrapper>.class);
            if(!listOfProductConfigSAPWrapper.isEmpty()){
                //Take the 1st elemet in the list as one product will have only one configuration in quote line Item
                ProductConfigSAPWrapper prodConfigSAPWrapper = listOfProductConfigSAPWrapper[0];
                //reqWrap.productConfigSAPWrapper = prodConfigSAPWrapper;
                if(!prodConfigSAPWrapper.configurations.isEmpty()){
                    listOfProductConfigWrapper = prodConfigSAPWrapper.configurations;
                }
            }
        }
        return listOfProductConfigWrapper;
    }
}