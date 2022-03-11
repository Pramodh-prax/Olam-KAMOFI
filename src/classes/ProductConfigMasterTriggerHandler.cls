public class ProductConfigMasterTriggerHandler extends TriggerHandlerBase {
    
    public override void handleBeforeInsert()
    {
        
        
        for(ProductConfigMaster__c tempConfig : (List<ProductConfigMaster__c >)Trigger.new){
            if(tempConfig.SAP_Product_Configuration__c != null &&  tempConfig.SAP_Product_Configuration__c != ''){
                tempConfig.Product_Configuration__c = productConfigIntermediateConvertor.sapJSONParse(tempConfig.SAP_Product_Configuration__c);
            }
        }
        ProductConfigMasterTriggerHelper.validateProductConfigJSON(Trigger.new);
    }
   
    public override void handleAfterInsert() {
        ProductConfigMasterTriggerHelper.updateCounttoProduct((List<ProductConfigMaster__c >)Trigger.new);
    }
    
    public override void handleBeforeUpdate()
    {
        List<ProductConfigMaster__c> listOfConfigs = New List<ProductConfigMaster__c>();
        for( ProductConfigMaster__c  tempConfig : (List<ProductConfigMaster__c >)Trigger.new)
        {
            Map<Id,ProductConfigMaster__c> mapOfConfigs = (Map<Id,ProductConfigMaster__c >)Trigger.OldMap;
            if(mapOfConfigs.containsKey(tempConfig.Id)){
                if(mapOfConfigs.get(tempConfig.Id).Product_Configuration__c != tempConfig.Product_Configuration__c)
                {
                    listOfConfigs.add(tempConfig);
                }
            }
        }
        
        ProductConfigMasterTriggerHelper.validateProductConfigJSON(listOfConfigs);
    }
    
    public override void handleAfterUpdate() {
        List<ProductConfigMaster__c> listOfConfigs = New List<ProductConfigMaster__c>();
        for( ProductConfigMaster__c  tempConfig : (List<ProductConfigMaster__c >)Trigger.new){
            Map<Id,ProductConfigMaster__c> mapOfConfigs = (Map<Id,ProductConfigMaster__c >)Trigger.OldMap;
            if(tempConfig.Product__c != mapOfConfigs.get(tempConfig.Id).Product__c ){
                tempConfig.addError('Product change is not allowed , Please create new record');
                //Commented By Ashwini Godase 2/7/2022
                // listOfConfigs.add(tempConfig);
                // listOfConfigs.add(mapOfConfigs.get(tempConfig.Id));
            }
        }
        //Commented By Ashwini Godase 2/7/2022
        // ProductConfigMasterTriggerHelper.updateCounttoProduct(listOfConfigs);
       
    }
    
    
    public override void handleAfterDelete() {
        system.debug('Inside');
        ProductConfigMasterTriggerHelper.updateCounttoProduct((List<ProductConfigMaster__c >)Trigger.old);
    }
    
    
}