trigger GrantTeamsAccessPEventTrigger on Grant_Account_Teams_Access__e (after insert) {
    //Platform event is triggered either from the scheduled job or form this trigger
    if (Trigger.isAfter && Trigger.isInsert) {
        GrantTeamsAccessPEventTriggerHandler.handleAfterInsert(trigger.new);
    }
}