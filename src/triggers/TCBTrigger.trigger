trigger TCBTrigger on TCB__c (before insert ,before Update,after Insert) {

    if(Trigger.IsBefore && Trigger.isInsert){
        TCBTriggerHandler.BeforeInsert(trigger.new);
    }
	if(Trigger.IsBefore && Trigger.isUpdate){
        TCBTriggerHandler.BeforeUpdate(trigger.new,trigger.oldMap);
    }
}