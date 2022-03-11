trigger ProductMappingTrigger on Product_Mapping__c (before insert) {
	new ProductMappingTriggerHandler().Handle();
}