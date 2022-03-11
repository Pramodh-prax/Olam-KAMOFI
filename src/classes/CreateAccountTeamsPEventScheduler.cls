global class CreateAccountTeamsPEventScheduler implements schedulable{
    
    global void execute(SchedulableContext SC) {
        //Check Access_Set_Assignment__c records if the account teams has to be created for any record
        List<Access_Set_Assignment__c> listOfAccessSetAssgnmntToProcess = new List<Access_Set_Assignment__c>();
        System.debug('listOfAccessSetAssgnmntToProcess: ');
        listOfAccessSetAssgnmntToProcess = [Select Id,Name,Access_Set__c,User__c,Account_Teams_Creation_Status__c 
                                            from Access_Set_Assignment__c 
                                            where Account_Teams_Creation_Status__c =: SharingUtility.ACCOUNT_TEAM_CREATION_STATUS_INITIATED and //"Failed" STATUS SHOULD BE HANDLED ON BASIS OF RETRY MECHANISM
                                            Id NOT IN (
                                                Select Access_Set_Assignment__c 
                                                from Retry_Log__c 
                                                where Type__c =: SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_CREATION 
                                                and Retry_Count__c >: SharingUtility.ACCOUNTTEAMCREATE_RETRY_COUNT_LIMIT
                                            )
                                            limit 1];
        System.debug('listOfAccessSetAssgnmntToProcess: '+listOfAccessSetAssgnmntToProcess);
        if(!listOfAccessSetAssgnmntToProcess.isEmpty()){
            //Fire the grant access platform event
            Create_Account_Team__e createAccountTeamsPEvent = new Create_Account_Team__e ();
            Database.SaveResult result = Eventbus.publish(createAccountTeamsPEvent);
            //abort the current Job (it will be rescheduled in the platform event only if there is no record left to be processed )
            System.abortJob(SC.getTriggerId());
        }
        else{
            //abort the current Job (it will be rescheduled in the platform event only if there is no record left to be processed )
            System.abortJob(SC.getTriggerId());
            //Schedule a Job to run after 10 mins from now
            /*String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 10); 
            String seconds = String.valueOf(Datetime.now().second());
            
            String nextJobScheduleTime = seconds + ' ' + min + ' ' + hour + ' * * ?';*/
            Datetime workTime = System.now().addMinutes(10);
            String nextJobScheduleTime = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()+ ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();

            String jobId = System.schedule('Create Team Job- ' + String.valueOf(Datetime.now()), nextJobScheduleTime, new CreateAccountTeamsPEventScheduler());
            System.debug('jobId: '+jobId);
        }
    }
}