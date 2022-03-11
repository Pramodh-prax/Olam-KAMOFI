public class QuoteLineProductConfigCntl {
	@AuraEnabled
    public static String getConfigurations(String recordId){
        ConfigWrapper reqWrap = new ConfigWrapper();
        reqWrap.message = 'SUCCESS';
        
        /*ProductConfigWrapper prodConfig = new ProductConfigWrapper();
        reqWrap.productConfigList = new List<ProductConfigSAPWrapper.ProductConfigWrapper>();*/
        
        QuoteLineItem quoteLine = [SELECT Id, Product_Configuration__c FROM QuoteLineItem WHERE Id = :recordId];
        if(quoteLine.Product_Configuration__c != null && quoteLine.Product_Configuration__c != ''){
            
            //reqWrap.productConfigList = (List<ProductConfigWrapper>) JSON.deserialize(quoteLine.Product_Configuration__c, List<ProductConfigWrapper>.class);
            List<ProductConfigSAPWrapper> listOfProductConfigSAPWrapper = new List<ProductConfigSAPWrapper>();
            listOfProductConfigSAPWrapper = (List<ProductConfigSAPWrapper>) JSON.deserialize(quoteLine.Product_Configuration__c,List<ProductConfigSAPWrapper>.class);
            if(!listOfProductConfigSAPWrapper.isEmpty()){
                //Take the 1st elemet in the list as one product will have only one configuration in quote line Item
                ProductConfigSAPWrapper prodConfigSAPWrapper = listOfProductConfigSAPWrapper[0];
                //reqWrap.productConfigSAPWrapper = prodConfigSAPWrapper;
                if(!prodConfigSAPWrapper.configurations.isEmpty()){
                    reqWrap.productConfigSAP = prodConfigSAPWrapper;
                    //If the configurations (List of ProductConfigWrapper inner class) variabe of ProductConfigSAPWrapper is not empty assign  it
                    //reqWrap.productConfigList = prodConfigSAPWrapper.configurations;
                }
            }
        }
        System.debug('reqWrap: '+reqWrap);
        
        return Json.serialize(reqWrap);
    }
    
    
    @AuraEnabled
    public static String saveConfigurtions(String recordId, String tempProdConfig){
        system.debug('Input '+tempProdConfig);
        ProductConfigSAPWrapper prodConfig = (ProductConfigSAPWrapper) System.JSON.deserialize(tempProdConfig, ProductConfigSAPWrapper.class);
        String message = 'SUCCESS';
        try{
            System.debug('prodConfig: '+prodConfig);
            List<ProductConfigSAPWrapper> listOfprodConfig = new List<ProductConfigSAPWrapper>{prodConfig};
            System.debug('listOfprodConfig: '+listOfprodConfig);
            QuoteLineItem quoteLine = new QuoteLineItem(Id = recordId, Product_Configuration__c = JSON.serialize(listOfprodConfig));
            update quoteLine;
            return message;
        }
        catch(Exception e){
            message = e.getMessage();
            return message;
        }
    }
    
    
    public class ConfigWrapper {
        //@AuraEnabled public List<ProductConfigSAPWrapper.ProductConfigWrapper> productConfigList;
        @AuraEnabled public ProductConfigSAPWrapper productConfigSAP;
        @AuraEnabled public String message;
        
        public ConfigWrapper(){
            //productConfigList = new List<ProductConfigSAPWrapper.ProductConfigWrapper>();
            productConfigSAP = new ProductConfigSAPWrapper();
        }
    }
}