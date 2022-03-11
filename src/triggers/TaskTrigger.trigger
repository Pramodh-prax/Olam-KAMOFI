trigger TaskTrigger on Task (after insert, after update, before insert, before update) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TaskTriggerHandler.getInstance().handleOnAfterInsert(Trigger.new, Trigger.newMap);
        } else if (Trigger.isUpdate) {
            TaskTriggerHandler.getInstance().handleOnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }
    } else if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            TaskTriggerHandler.getInstance().handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            TaskTriggerHandler.getInstance().handleBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }
    }
}