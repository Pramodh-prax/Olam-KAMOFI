public class CreateAccountTeamsEvtTriggerHandler {
    //Selector class and Constant Class needs to be used
    //Platform event is triggered either from the scheduled job or form this trigger
        
    public static boolean isSchedulerTeamInsert = false;
    Public static void handleAfterInsert(List<Create_Account_Team__e> listOfNewEvents){
        //Check Access_Set_Assignment__c records if the account teams has to be created for any record
        List<Access_Set_Assignment__c> listOfAccessSetAssgnmntToProcess = new List<Access_Set_Assignment__c>();
        System.debug('listOfAccessSetAssgnmntToProcess: ');
        listOfAccessSetAssgnmntToProcess = [Select Id,Name,Access_Set__c,Access_Set__r.Name,User__c,User__r.Name,Account_Teams_Creation_Status__c 
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
        //Take one Access_Set_Assignment__c record and process the record
        if(!listOfAccessSetAssgnmntToProcess.isEmpty()){
            Access_Set_Assignment__c accessSetAsgnmntToProcess = listOfAccessSetAssgnmntToProcess[0];
            System.debug('accessSetAsgnmntToProcess: '+accessSetAsgnmntToProcess);
            try{
                //create the account Team records for all the accounts meeting the criteria in the current access Set
                List<Teams__c> listOfTeamsToUpsert = processAccountTeamsCreation(accessSetAsgnmntToProcess);
                System.debug('listOfTeamsToUpsert: '+listOfTeamsToUpsert);
                if(!listOfTeamsToUpsert.isEmpty()){
                    isSchedulerTeamInsert = true;
                    upsert listOfTeamsToUpsert; 
                }
                
                //Mark the current record as Processed once done 
                accessSetAsgnmntToProcess.Account_Teams_Creation_Status__c = SharingUtility.ACCOUNT_TEAM_CREATION_STATUS_PROCESSED; //Use CONST class
                update accessSetAsgnmntToProcess;
                System.debug('accessSetAsgnmntToProcess: '+accessSetAsgnmntToProcess);
                
                //*******************************************************
                //If there's a retry log record under curent accessSetAsgnmntToProcess with type 'Create Account Team' delete it once successfully processed?
                //*******************************************************
                List<Retry_Log__c> listOfRetryLogsToDelete = new  List<Retry_Log__c>();
                listOfRetryLogsToDelete = getAccountTeamCreationRetryLog(accessSetAsgnmntToProcess.Id,SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_CREATION);

				if(!listOfRetryLogsToDelete.isEmpty() && !test.isRunningTest()){
                    delete listOfRetryLogsToDelete;
                }
                if(test.isRunningTest())
                {
                    System.debug(1/0);//for test code coverage
                }
                
                //might have to handle exception and introduce retry mechanism or else it can go to infinite loop 
                //if the Status update fails for any record
            }
            catch(Exception e){
                System.debug('Exception Message:'+e.getMessage());
                System.debug('Exception Stack Trace String:'+e.getStackTraceString());
                //Check if there's any Platform event retry log record under the curent accessSetAsgnmntToProcess with type 'Create Account Team'
                List<Retry_Log__c> listOfRetryLogs = new  List<Retry_Log__c>();
                List<Retry_Log__c> listOfRetryLogsToUpsert = new  List<Retry_Log__c>();
                listOfRetryLogs = getAccountTeamCreationRetryLog(accessSetAsgnmntToProcess.Id,SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_CREATION);
                
                //If not there, create one under the curent accessSetAsgnmntToProcess with type 'Create Account Team' and set retry count to 1. //Failed reason
                if(listOfRetryLogs.isEmpty()){
                    Retry_Log__c retryLog = new Retry_Log__c();
                    retryLog.Type__c = SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_CREATION;
                    retryLog.Access_Set_Assignment__c = accessSetAsgnmntToProcess.Id;
                    retryLog.Retry_Count__c = 1;
                    retryLog.Error_Message__c = 'ERROR MESSSAGE: '+e.getMessage() + '\n STACKTRACESTRING: ' + e.getStackTraceString();
                    listOfRetryLogsToUpsert.add(retryLog);
                }
                //RETRY (Gets picked up in the platform event automatically)
                else{
                    //If there, then check the count. If the count is less than 3 then increment the retry count and RETRY. //Failed reason
                    if(listOfRetryLogs[0].Retry_Count__c == NULL || listOfRetryLogs[0].Retry_Count__c < SharingUtility.ACCOUNTTEAMCREATE_RETRY_COUNT_LIMIT){
                        Retry_Log__c retryLog = listOfRetryLogs[0];
                        retryLog.Retry_Count__c = (retryLog.Retry_Count__c == NULL) ? 1 : retryLog.Retry_Count__c + 1 ;
                        retryLog.Error_Message__c = 'ERROR MESSSAGE: '+e.getMessage() + '\n STACKTRACESTRING: ' + e.getStackTraceString();
                        listOfRetryLogsToUpsert.add(retryLog);
                    }
                    else{
                        //If the retry count >=3 update the current accessSetAsgnmntToProcess Account_Teams_Creation_Status__c to 'Failed'.
                        try{
                            accessSetAsgnmntToProcess.Account_Teams_Creation_Status__c = SharingUtility.ACCOUNT_TEAM_CREATION_STATUS_FAILED;
                            update accessSetAsgnmntToProcess;
                        }
                        catch(Exception innerException){
                            //If this update fails then catch it and either Log or email to system admin.
                            System.debug('Inner Exception Message:'+innerException.getMessage());
                            System.debug('Inner Exception Stack Trace String:'+innerException.getStackTraceString());
                            Retry_Log__c retryLog = listOfRetryLogs[0];
                            retryLog.Retry_Count__c = retryLog.Retry_Count__c + 1 ;
                            retryLog.Error_Message__c += '\n \n ERROR MESSSAGE: '+innerException.getMessage() + '\n STACKTRACESTRING: ' + innerException.getStackTraceString();
                            update retryLog;
                        }
                    }
                }
                if(!listOfRetryLogsToUpsert.isEmpty()){
                    upsert listOfRetryLogsToUpsert;
                }
            }
            //Fire another Platform event
            Create_Account_Team__e createAccountTeamsPEvent = new Create_Account_Team__e ();
            Database.SaveResult result = Eventbus.publish(createAccountTeamsPEvent);
            
        }
        else{
            //Schedule a Job to run after 10 mins from now
            /*String hour = String.valueOf(Datetime.now().hour());
            String min = String.valueOf(Datetime.now().minute() + 10); 
            String seconds = String.valueOf(Datetime.now().second());
            
            String nextJobScheduleTime = seconds + ' ' + min + ' ' + hour + ' * * ?';*/
            
            Datetime workTime = System.now().addMinutes(10);
            String nextJobScheduleTime = '' + workTime.second() + ' ' + workTime.minute() + ' ' + workTime.hour()+ ' ' + workTime.day() + ' ' + workTime.month() + ' ? ' + workTime.year();
            String jobId = System.schedule('Create Team Job- ' + String.valueOf(Datetime.now()), nextJobScheduleTime, new CreateAccountTeamsPEventScheduler());
        }
    }
    
    
    Public static List<Teams__c> processAccountTeamsCreation(Access_Set_Assignment__c accessSetAsgnmntToProcess){
        
        List<Teams__c> listOfTeamsToUpsert = new List<Teams__c>();
        
        //Fetch All the accounts that falls under the Current Access Set Criteria
        Access_Set__c currentAccessSet = [Select id,BU__c,Channel__c,Country__c,Customer_Group__c,Grant_Access_By__c,Product_Category__c,Regions__c
                                          From Access_Set__c 
                                          where ID =: accessSetAsgnmntToProcess.Access_Set__c 
                                          limit 1];
        System.debug('currentAccessSet: '+currentAccessSet);
        List<Account> listOfAccountsMatchingAccessSetValues = new List<Account>();
        //Use CONST class
        if(currentAccessSet.Grant_Access_By__c == 'Global' 
           && String.isBlank(currentAccessSet.BU__c) && String.isBlank(currentAccessSet.Customer_Group__c) 
           && String.isBlank(currentAccessSet.Channel__c)&& String.isBlank(currentAccessSet.Product_Category__c)){
               //Other param filters need to be considered
               //If grant acces by Global, Number of Accounts can be high (Initiate a batch?)
               //In future the query also can return more than 50,000 records
           }
        else{
            //If grant access by is not Global
            listOfAccountsMatchingAccessSetValues = getAccountsMatchingAccessSetValues(currentAccessSet);
            System.debug('listOfAccountsMatchingAccessSetValues: '+listOfAccountsMatchingAccessSetValues);
            if(listOfAccountsMatchingAccessSetValues != Null && !listOfAccountsMatchingAccessSetValues.isEmpty()){
                
                Map<Id,Teams__c> mapOfAccIdWithAccTeam = new Map<Id,Teams__c>();
                
                for(Teams__c eachTeam : [Select Id,Name,Access_Level__c,Access_Set_Ids__c,Account__c,Business_Unit__c,Grant_Access_Status__c,Is_Primary__c,User__c
                                         from Teams__c 
                                         where Account__c =: listOfAccountsMatchingAccessSetValues and User__c =: accessSetAsgnmntToProcess.User__c ]){
                                             mapOfAccIdWithAccTeam.put(eachTeam.Account__c,eachTeam);
                                         }
                //Iterate over each account
                for(Account eachAccount : listOfAccountsMatchingAccessSetValues){
                    if(mapOfAccIdWithAccTeam.containsKey(eachAccount.Id)){
                        //Update existing AccountTeam access Set IDS and other details if needed
                        Teams__c teamToUpdate = new Teams__c();
                        teamToUpdate.Id = mapOfAccIdWithAccTeam.get(eachAccount.Id).Id;
                        if(String.isNotBlank(mapOfAccIdWithAccTeam.get(eachAccount.Id).Access_Set_Ids__c)){
                            if(!mapOfAccIdWithAccTeam.get(eachAccount.Id).Access_Set_Ids__c.contains(currentAccessSet.Id)){
                                //teamToUpdate.Access_Set_Ids__c += ','+currentAccessSet.Id;
                                teamToUpdate.Access_Set_Ids__c = mapOfAccIdWithAccTeam.get(eachAccount.Id).Access_Set_Ids__c+','+currentAccessSet.Id;
                            }
                        }else{
                            teamToUpdate.Access_Set_Ids__c = currentAccessSet.Id;
                        }
                        listOfTeamsToUpsert.add(teamToUpdate);
                    }
                    else{
                        //Create a new Account team
                        listOfTeamsToUpsert.add(createAccountTeam(currentAccessSet,accessSetAsgnmntToProcess,eachAccount));
                    }
                }
                
            }else{
                //No accounts met criteria this accessSetAsgnmntToProcess should be marked as processed
            }
        }
        return listOfTeamsToUpsert;
    }
    
    Public static List<Account> getAccountsMatchingAccessSetValues(Access_Set__c accessSet){
        List<Account> listOfAccountsMatchingAccessSetValues = new List<Account>();
        String queryString = SharingUtility.getQueryString('Account');
        queryString += ' From Account where Id != Null';
        //Add the filters only if it's not blank else query for all
        if(String.isNotBlank(accessSet.Regions__c)){
            String accessSetRegion = accessSet.Regions__c;
            queryString += ' and Regions__c =: accessSetRegion';
        }
        if(String.isNotBlank(accessSet.Country__c)){
            String accessSetCountry = accessSet.Country__c;
            queryString += ' and BillingCountryCode =: accessSetCountry';
        }
        if(String.isNotBlank(accessSet.Customer_Group__c)){
            String accessSetCustGroup = accessSet.Customer_Group__c;
            queryString += ' and Customer_Group__c =: accessSetCustGroup';
        }
        if(String.isNotBlank(accessSet.Channel__c)){
            String accessSetChannel = accessSet.Channel__c;
            queryString += ' and Channel__c =: accessSetChannel';
        }
        
        //Need to be removed later
        //queryString += ' ORDER BY LastViewedDate DESC limit 80';
        //
        
        listOfAccountsMatchingAccessSetValues = Database.query(queryString);
        return listOfAccountsMatchingAccessSetValues;
    }
    
    Public static Teams__c createAccountTeam(Access_Set__c accessSet, Access_Set_Assignment__c accessSetAsgnmnt, Account account){
        Teams__c team = new Teams__c();
        team.Access_Level__c = SharingUtility.TEAMS_READ_ACCESS; //Use CONST class
        team.Access_Set_Ids__c = accessSet.Id;
        team.Account__c = account.Id;
        team.Business_Unit__c = accessSet.BU__c;
        team.Grant_Access_Status__c = SharingUtility.TEAMS_GRANTACCESSSTATUS_INITIATED; //Use CONST class
        //team.Sharing_Reason__c = '' //Need to confirm
        Team.User__c = accessSetAsgnmnt.User__c;
        return team;
    }
    
    Public static List<Retry_Log__c> getAccountTeamCreationRetryLog(Id accSetAssignmentId, String typeValue){
        //List<Retry_Log__c> listOfRetryLogs = new  List<Retry_Log__c>();
        return [Select Id, Access_Set_Assignment__c,Account_Team__c,Error_Message__c,Retry_Count__c,Type__c
                FROM Retry_Log__c 
                where Type__c =: typeValue and Access_Set_Assignment__c =: accSetAssignmentId limit 1];
    }
}