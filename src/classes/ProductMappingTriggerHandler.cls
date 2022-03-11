public class ProductMappingTriggerHandler extends TriggerHandlerBase {
    
    private final String SKIPPED = 'Skipped';
    private final String APPLIED = 'Applied';
    
	public override void handleBeforeInsert() {
        // Product_Name__c
        // External_Product_Code__c 
        // Status__c (Applied, Skipped ) 
        // Note__c 
         
        Map<String, Product_Mapping__c> productMappings = new Map<String, Product_Mapping__c>();
        for(Product_Mapping__c toProcess : (List<Product_Mapping__c>)Trigger.New) {
            if(String.isBlank(toProcess.External_Product_Code__c)) {
                toProcess.Status__c = SKIPPED;
                toProcess.Note__c = 'External Product ID is null or empty';
            }
            else if(String.isBlank(toProcess.Product_Name__c)) {
                toProcess.Status__c = SKIPPED;
                toProcess.Note__c = 'Product name is null or empty';

            } 
            else if(productMappings.containsKey(toProcess.Product_Name__c)) {
                toProcess.Status__c = SKIPPED;
                toProcess.Note__c = 'Duplicate product name in the same batch';
                Product_Mapping__c dup = productMappings.get(toProcess.Product_Name__c);
                if(dup != null) {
                    dup.Status__c = SKIPPED;
                	dup.Note__c = 'Duplicate product name in the same batch';
                }
                productMappings.put(toProcess.Product_Name__c, null);
            }
            else
                productMappings.put(toProcess.Product_Name__c, toProcess);
        }
        
        Set<String> productNames = productMappings.keySet();
        Map<String, Product2> products = new Map<String, Product2>();
        Map<String, Set<Id>> dupProducts = new Map<String, Set<Id>>();
        for(Product2 prod : [Select Id, Name, External_Product_Code__c 
                           From Product2 
                           where Name in :productNames]) {
        	if(!dupProducts.containsKey(prod.Name) && !products.containsKey(prod.Name)) {
            	products.put(prod.Name, prod);
            }
            else {
            	if(!dupProducts.containsKey(prod.Name)) {
                    dupProducts.put(prod.Name, new Set<Id>());
                }
                // Clear the one that was already added into a map
                if(dupProducts.containsKey(prod.Name) && products.get(prod.Name) != NULL) {
                    Product2 dupProd = products.get(prod.Name);
                    dupProducts.get(prod.Name).add(dupProd.Id);
                    products.put(prod.Name, NULL);
                }
                // Add the new duplcate product to the list
            	dupProducts.get(prod.Name).add(prod.Id);
            }
        }
        
        List<Product2> productToUpdate = new List<Product2>();
        for(String prodName : productMappings.keySet()) {
            Product_Mapping__c prodMapping = productMappings.get(prodName);
            if(prodMapping == null) 
                continue;
            Product2 product = products.get(prodName);
            if(product == NULL && dupProducts.containsKey(prodName)) {
                Set<Id> dupIdSet = dupProducts.get(prodName);
                String dupIdString = String.join(new List<Id>(dupIdSet), ',');
                prodMapping.Status__c = SKIPPED;
                prodMapping.Note__c = 'Duplicate product name found in SF(' + dupIdString + ')';
            }
            else if(product == NULL) {
                prodMapping.Status__c = SKIPPED;
                prodMapping.Note__c = 'New product';
            }
            else if(String.isNotBlank(product.External_Product_Code__c)){
                prodMapping.Status__c = SKIPPED;
                prodMapping.Note__c = 'Id:' + product.Id + ', Already have External Product ID';
            }
            else {
                product.External_Product_Code__c = prodMapping.External_Product_Code__c;
                productToUpdate.add(product);
                
                prodMapping.Status__c = APPLIED;
                prodMapping.Note__c = 'Id:' + product.Id;
            }
        }
        
        if(!productToUpdate.isEmpty())
            update productToUpdate;
    }
}