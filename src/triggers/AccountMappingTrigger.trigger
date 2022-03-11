trigger AccountMappingTrigger on Account_Mapping__c (before insert) {
	new AccountMappingTriggerHandler().Handle();
}