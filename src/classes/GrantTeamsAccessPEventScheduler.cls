global class GrantTeamsAccessPEventScheduler implements schedulable{
    
    global void execute(SchedulableContext SC) {
        //Check Accout Team records if Access has to be granted for any record based on checkbox field
        List<Teams__c> listOfAccountTeamsToGrantAccess = new List<Teams__c>();
        listOfAccountTeamsToGrantAccess = [Select Id,Name,Access_Level__c,Account__c,Is_Primary__c,Grant_Access_Status__c,Role_Name__c,User__c,User_Role_Name__c 
                                           from Teams__c 
                                           where Grant_Access_Status__c =: SharingUtility.TEAMS_GRANTACCESSSTATUS_INITIATED and
                                           Id NOT IN (
                                               Select Account_Team__c 
                                               from Retry_Log__c 
                                               where Type__c =: SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_GRANT_ACCESS 
                                               and Retry_Count__c >: SharingUtility.ACCOUNTTEAMGRANTACCESS_RETRY_COUNT_LIMIT
                                           )
                                           limit 1];
        if(!listOfAccountTeamsToGrantAccess.isEmpty()){
            //Fire the grant access platform event
            Grant_Account_Teams_Access__e grantAccountTeamsAccessEvent = new Grant_Account_Teams_Access__e ();
            Database.SaveResult result = Eventbus.publish(grantAccountTeamsAccessEvent);
            
            //abort the current Job (it will be rescheduled in the platform event only if there is no record left to be processed )
            System.abortJob(SC.getTriggerId());
        }
        else{
            //abort the current Job (it will be rescheduled in the platform event only if there is no record left to be processed )
            System.abortJob(SC.getTriggerId());
            
            //Schedule a Job to run after 2 mins from now
            /*String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 2); 
            String seconds = String.valueOf(Datetime.now().second());
            
            String nextJobScheduleTime = seconds + ' ' + min + ' ' + hour + ' * * ?';*/
            Datetime workTime = System.now().addMinutes(2);
            String nextJobScheduleTime = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()+ ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
            String jobId = System.schedule('Grant Access Job- ' + String.valueOf(Datetime.now()), nextJobScheduleTime, new GrantTeamsAccessPEventScheduler());
        }
    }
}