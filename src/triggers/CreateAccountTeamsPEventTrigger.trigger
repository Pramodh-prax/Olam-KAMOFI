trigger CreateAccountTeamsPEventTrigger on Create_Account_Team__e (after insert) {
    //Platform event is triggered either from the scheduled job or form this trigger
    if (Trigger.isAfter && Trigger.isInsert) {
        CreateAccountTeamsEvtTriggerHandler.handleAfterInsert(trigger.new);
    }
}