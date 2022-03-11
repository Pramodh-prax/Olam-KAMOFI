trigger AccountTrigger on Account (before insert, before update, after insert) {
    new AccountTriggerHandler().Handle();
    
    if(Trigger.isBefore && Trigger.isInsert){
        
    } 
    //AccountTriggerHanlder.beforeInsert(Trigger.new);
    //AccountTriggerHanlder.accountTaggingCreatorbeforeInsert(Trigger.new);
    /*
if(Trigger.isBefore && Trigger.isUpdate){
//  AccountTriggerHanlder.beforeUpdate(Trigger.new, Trigger.oldMap);
}
*/
    if(Trigger.isAfter && Trigger.isInsert){
        Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
        if(!vietnamUsers){
            AccountTriggerOFIHandler.accountCreationValidationOFI(Trigger.new);
        }
        //AccountTriggerHanlder.addMembersAfterUpdate(Trigger.new);
        //Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        //if(!hasCustomPermission){
        //AccountTriggerHanlder.accountTaggingCreatorbeforeInsertTest(Trigger.new);
        ///AccountTriggerHanlder.accountTaggingCreatorbeforeInsert(Trigger.new);
        // }
        //AccountTriggerTestHandler.accountTaggingCreatorafterInsertTest(Trigger.new);
    }
}