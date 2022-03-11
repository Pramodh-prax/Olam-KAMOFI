public class ProductConfigMasterTriggerHelper {
    public static void updateCounttoProduct(List<ProductConfigMaster__c > listOfProductConfigMaster){
        system.debug('Val '+listOfProductConfigMaster);
        /*list<RollUpSummaryUtility.fieldDefinition> fieldDefinitionsForCount = 
            new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('COUNT', 'ID','Product_Config_Count__c')
                    };
         	RollUpSummaryUtility.rollUpTrigger(fieldDefinitionsForCount, listOfProductConfigMaster, 'ProductConfigMaster__c', 'Product__c', 'Product2','');
		*/
        set<Id> ProductIds = new set<Id>();
        list<Product2> listOfProducts = new list<Product2>();
        for(ProductConfigMaster__c tempProductConfig : listOfProductConfigMaster){
            ProductIds.add(tempProductConfig.Product__c);
        }
        Map<Id,Product2> mapOfProducts = new Map<Id,Product2>([select Id,Is_Product_Config_Required__c,(select Id from ProductConfigMaster__r) from Product2 where Id IN: ProductIds]);
        system.debug('Data '+mapOfProducts.size() );
        for(ProductConfigMaster__c tempProductConfig : listOfProductConfigMaster){
            if(tempProductConfig.Product__c != null)
            If(mapOfProducts.get(tempProductConfig.Product__c).ProductConfigMaster__r.size()>1){
                system.debug('valid '+mapOfProducts.get(tempProductConfig.Product__c).ProductConfigMaster__r.size());
                tempProductConfig.addError('You can\'t have more than 1 config for an product');
            }
            else If(mapOfProducts.get(tempProductConfig.Product__c).Is_Product_Config_Required__c
              && mapOfProducts.get(tempProductConfig.Product__c).ProductConfigMaster__r.size() < 1){
                tempProductConfig.addError('You should have atleast 1 config for an product, else make product config required to false');
            }
            
        //listOfProducts.add(new Product2(Id = tempProductConfig.Product__c, Product_Config_Count__c = mapOfProducts.get(tempProductConfig.Product__c).ProductConfigMaster__r.size()));
        }
       
        for(ProductConfigMaster__c tempProductConfig : listOfProductConfigMaster){
            if(tempProductConfig.Product__c != null){
             system.debug('Before Update');
            System.debug('******'+mapOfProducts.get(tempProductConfig.Product__c).ProductConfigMaster__r.size());
            listOfProducts.add(new Product2(Id = tempProductConfig.Product__c, Product_Config_Count__c = mapOfProducts.get(tempProductConfig.Product__c).ProductConfigMaster__r.size()));
        
            }
        }
        try{
            update listOfProducts;   
        }Catch(Exception e){}
    }
    
    public static void validateProductConfigJSON(List<ProductConfigMaster__c> ProductConfigMasterList)
    {
        List<ProductConfigSAPWrapper> listOfProductConfigSAPWrapper = new List<ProductConfigSAPWrapper>();
        for(ProductConfigMaster__c pc : ProductConfigMasterList)
        {
            if(String.isEmpty(pc.Product_Configuration__c) || pc.Product_Configuration__c == null)
            {
                pc.addError('Product Configuration Field can not be null');
                System.debug('Error');
            }
            else
            {
                try{
                    listOfProductConfigSAPWrapper = (List<ProductConfigSAPWrapper>) JSON.deserialize(pc.Product_Configuration__c,List<ProductConfigSAPWrapper>.class);
                    System.debug('listOfProductConfigWrapper '+listOfProductConfigSAPWrapper);
                    if(!listOfProductConfigSAPWrapper.isEmpty())
                    {
                        ProductConfigSAPWrapper pCSW = listOfProductConfigSAPWrapper[0];
                        if(pCSW.configurations.isEmpty())
                        {
                            pc.addError('Product Configuration Array is Empty');
                        }                   
                    }
                    else
                    {
                        pc.addError('JSON is Invalid');
                    }
                }
                catch(Exception e){ 
                    System.debug('Error: '+e.getMessage());
                    pc.addError('Error Parsing Product Configuration Json');
                }
            }
        }
    }
}