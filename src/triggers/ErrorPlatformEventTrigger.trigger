trigger ErrorPlatformEventTrigger on Error_Event_Capture__e (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        List<KAM_Queuable_Error_Log__c> errorLogs = new List <KAM_Queuable_Error_Log__c> ();
        for (Error_Event_Capture__e  eachEvent : Trigger.new) {
            errorLogs.add (new KAM_Queuable_Error_Log__c (
                Apex_Class__c = eachEvent.Apex_Class__c,
                Exception__c = eachEvent.Error_Details__c,
                RequestId__c = eachEvent.RequestId__c,
                Result__c = eachEvent.Result__c,
                Record_Detail__c = eachEvent.Record_Detail__c
            ));
        }
        if (!errorLogs.isEmpty ()) {
            Database.SaveResult [] results = Database.insert(errorLogs, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    System.debug('Error in creating KAM_Queuable_Error_Log__c record :' + String.valueOf(result.getErrors()));
                }
            }
        }
    }
}