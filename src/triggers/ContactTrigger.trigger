trigger ContactTrigger on Contact (before insert,before update,after insert,after update) {
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            //ContactTriggerHandler.shareContactRecordWithAccountTeamMembers(trigger.new);
        } 
    }
    
     if(trigger.isBefore){
        if(trigger.isInsert){
            ContactTriggerHandler.onlyAccountTeamMembersCanAddContacts(trigger.new);
        }
    }

}