public class GrantTeamsAccessPEventTriggerHandler {
    
    
    Public static void handleAfterInsert(List<Grant_Account_Teams_Access__e> listOfNewEvents){
        //Check Accout Team records if Access has to be granted for any record based on checkbox field
        List<Teams__c> listOfAccountTeamsToGrantAccess = new List<Teams__c>();
        listOfAccountTeamsToGrantAccess = [Select Id,Name,Access_Level__c,Account__c,Account__r.OwnerId,Business_Unit__c,Is_Primary__c,Grant_Access_Status__c,Role_Name__c,User__c,User_Role_Name__c 
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
            //Take one Accout Team record and process the records share calculation
            Teams__c accountTeamToGrantAccess = listOfAccountTeamsToGrantAccess[0];
            try{
                
                try{
                    if(accountTeamToGrantAccess.User__c != accountTeamToGrantAccess.Account__r.OwnerId){
                        //Share current Account with the team user - OWD is Pubic read only
                        //Here it will give edit access if needed based on team access level (has Edit access)  or primary
                        AccountShare accShare = new AccountShare();
                        accShare.AccountAccessLevel = SharingUtility.getAccessLevel(accountTeamToGrantAccess);
                        accShare.OpportunityAccessLevel ='None';
                        accShare.AccountId = accountTeamToGrantAccess.Account__c;
                        accShare.RowCause = SharingUtility.MANUAL_ROWCAUSE;
                        accShare.UserOrGroupId = accountTeamToGrantAccess.User__c;
                        
                        insert accShare;
                    }
                }
                catch(Exception accShareException){
                    
                }
                //Add share calculation logics here
                List<SObject> listOfShareRecordsToInsert = processAccountTeamsAccess(accountTeamToGrantAccess);
                System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                //Insert the sharing records for all the records
                if(!listOfShareRecordsToInsert.isEmpty()){
                    insert listOfShareRecordsToInsert;
                    System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                }
                
                //Mark the current record as access provided once done 
                accountTeamToGrantAccess.Grant_Access_Status__c = SharingUtility.TEAMS_GRANTACCESSSTATUS_PROCESSED;
                update AccountTeamToGrantAccess;
                System.debug('accountTeamToGrantAccess: '+accountTeamToGrantAccess);
                
                //*******************************************************
                //If there's a retry log record under curent accountTeamToGrantAccess with type 'Account Team Grant Access' delete it once successfully processed?
                //*******************************************************
                List<Retry_Log__c> listOfRetryLogsToDelete = new  List<Retry_Log__c>();
                listOfRetryLogsToDelete = getAccountTeamGrantAccessRetryLog(accountTeamToGrantAccess.Id,SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_GRANT_ACCESS);
                
                if(!listOfRetryLogsToDelete.isEmpty()){
                    delete listOfRetryLogsToDelete;
                }
                    
                //might have to handle exception and introduce retry mechanism or else it can go to infinite loop 
                //if the Status update fails for any record
            }
            catch(Exception e){
                //Check if there's any Platform event retry log record under the curent accountTeamToGrantAccess with type 'Account Team Grant Access'
                List<Retry_Log__c> listOfRetryLogs = new  List<Retry_Log__c>();
                List<Retry_Log__c> listOfRetryLogsToUpsert = new  List<Retry_Log__c>();
                listOfRetryLogs = getAccountTeamGrantAccessRetryLog(accountTeamToGrantAccess.Id,SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_GRANT_ACCESS);
                
                //If not there, create one under the curent accountTeamToGrantAccess with type 'Account Team Grant Access' and set retry count to 1. //Failed reason
                if(listOfRetryLogs.isEmpty()){
                    Retry_Log__c retryLog = new Retry_Log__c();
                    retryLog.Type__c = SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_GRANT_ACCESS;
                    retryLog.Account_Team__c = accountTeamToGrantAccess.Id;
                    retryLog.Retry_Count__c = 1;
                    retryLog.Error_Message__c = 'ERROR MESSSAGE: '+e.getMessage() + '\n STACKTRACESTRING: ' + e.getStackTraceString();
                    listOfRetryLogsToUpsert.add(retryLog);
                }
                //RETRY (Gets picked up in the platform event automatically)
                else{
                    //If there, then check the count. If the count is less than 3 then increment the retry count and RETRY. //Failed reason
                    if(listOfRetryLogs[0].Retry_Count__c == NULL || listOfRetryLogs[0].Retry_Count__c < SharingUtility.ACCOUNTTEAMGRANTACCESS_RETRY_COUNT_LIMIT){
                        Retry_Log__c retryLog = listOfRetryLogs[0];
                        retryLog.Retry_Count__c = (retryLog.Retry_Count__c == NULL) ? 1 : retryLog.Retry_Count__c + 1 ;
                        retryLog.Error_Message__c = 'ERROR MESSSAGE: '+e.getMessage() + '\n STACKTRACESTRING: ' + e.getStackTraceString();
                        listOfRetryLogsToUpsert.add(retryLog);
                    }
                    else{
                        //If the retry count >=3 update the current accessSetAsgnmntToProcess Account_Teams_Creation_Status__c to 'Failed'.
                        try{
                            accountTeamToGrantAccess.Grant_Access_Status__c = SharingUtility.ACCOUNT_TEAM_CREATION_STATUS_FAILED;
                            update accountTeamToGrantAccess;
                        }
                        catch(Exception innerException){
                            //If this update fails then catch it and either Log or email to system admin.
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
            Grant_Account_Teams_Access__e grantAccountTeamsAccessEvent = new Grant_Account_Teams_Access__e ();
            Database.SaveResult result = Eventbus.publish(grantAccountTeamsAccessEvent);
            
        }
        else{
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
    
    
    Public static List<SObject> processAccountTeamsAccess(Teams__c accountTeamToGrantAccess){
        List<SObject> listOfShareRecordsToInsert = new List<SObject>();
        
        //Opportunity Share
        List<SObject> listOfOppShareRecords = createOppShareRecords(accountTeamToGrantAccess);
        if(!listOfOppShareRecords.isEmpty()){
            listOfShareRecordsToInsert.addAll(listOfOppShareRecords);
            System.debug('listOfOppShareRecords: '+listOfOppShareRecords);
        }
        
        //Interaction Share
        List<SObject> listOfInteractionShareRecords = createInteractionShareRecords(accountTeamToGrantAccess);
        if(!listOfInteractionShareRecords.isEmpty()){
            listOfShareRecordsToInsert.addAll(listOfInteractionShareRecords);
            System.debug('listOfInteractionShareRecords: '+listOfInteractionShareRecords);
        }
        //Consumption Share
        List<SObject> listOfConsumptionsShareRecords = createConsumptionsShareRecords(accountTeamToGrantAccess);
        if(!listOfConsumptionsShareRecords.isEmpty()){
            listOfShareRecordsToInsert.addAll(listOfConsumptionsShareRecords);
            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
        }
        //Budget Share
        List<SObject> listOfBudgetsShareRecords = createBudgetsShareRecords(accountTeamToGrantAccess);
        if(!listOfBudgetsShareRecords.isEmpty()){
            listOfShareRecordsToInsert.addAll(listOfBudgetsShareRecords);
            System.debug('listOfBudgetsShareRecords: '+listOfBudgetsShareRecords);
        }
        //Account Plan Share
        List<SObject> listOfAccountPlansShareRecords = createAccountPlansShareRecords(accountTeamToGrantAccess);
        if(!listOfAccountPlansShareRecords.isEmpty()){
            listOfShareRecordsToInsert.addAll(listOfAccountPlansShareRecords);
            System.debug('listOfAccountPlansShareRecords: '+listOfAccountPlansShareRecords);
        }
        //Engagement Plan Share
        List<SObject> listOfEngagementPlansShareRecords = createEngagementPlansShareRecords(accountTeamToGrantAccess);
        if(!listOfEngagementPlansShareRecords.isEmpty()){
            listOfShareRecordsToInsert.addAll(listOfEngagementPlansShareRecords);
            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
        }
        
        return listOfShareRecordsToInsert;
    }
    
    
    Public static List<SObject> createOppShareRecords(Teams__c accountTeamToGrantAccess){
        List<SObject> listOfOppShareRecords = new List<SObject>();
        Map<Id,Opportunity> mapOfOpportunityRecordsToShare = getOpportunitiesToShare(accountTeamToGrantAccess);
        //Remove records from sharing if the Account Team User is the owner (now handled in the records query)
        if(!mapOfOpportunityRecordsToShare.isEmpty()){
            Map<Id,String> mapOfUserIdWithAccessLevel = new Map<Id,String>{accountTeamToGrantAccess.User__c => SharingUtility.getAccessLevel(accountTeamToGrantAccess)};
            
            //Create the sharing wrapper to use for creating the sharing records later
            SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('opportunity');
            
            wrapper.rowCause = SharingUtility.MANUAL_ROWCAUSE; //'Manual' as row cause for standard object
            //wrapper.mapOfRecordIdWithUsersOrGroupsIds = createMapOfRecordIdWithUserId(mapOfOpportunityRecordsToShare.keySet(),accountTeamToGrantAccess.User__c);
            wrapper.mapOfRecordIdWithUserIdsNAccessLevel = createMapOfRecordIdWithUserIdNAccessLevel(mapOfOpportunityRecordsToShare.keySet(),mapOfUserIdWithAccessLevel);
            
            listOfOppShareRecords = SharingUtility.createSharingRecords(wrapper);
        }
        return listOfOppShareRecords;
    }
    
    Public static List<SObject> createInteractionShareRecords(Teams__c accountTeamToGrantAccess){
        List<SObject> listOfInteractionShareRecords = new List<SObject>();
        
        Map<Id,Interactions__c> mapOfInteractionRecordsToShare = getInteractionsToShare(accountTeamToGrantAccess);
        //Remove records from sharing if the Account Team User is the owner (now handled in the records query)
        
        if(!mapOfInteractionRecordsToShare.isEmpty()){
            Map<Id,String> mapOfUserIdWithAccessLevel = new Map<Id,String>{accountTeamToGrantAccess.User__c => SharingUtility.getAccessLevel(accountTeamToGrantAccess)};
            
            //Create the sharing wrapper to use for creating the sharing records later
            SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Interactions__c');
            
            wrapper.rowCause = Schema.Interactions__Share.RowCause.Access_Set__c; //'Access Set' as row cause for standard object
            wrapper.mapOfRecordIdWithUserIdsNAccessLevel = createMapOfRecordIdWithUserIdNAccessLevel(mapOfInteractionRecordsToShare.keySet(),mapOfUserIdWithAccessLevel);
            
            listOfInteractionShareRecords = SharingUtility.createSharingRecords(wrapper);
        }
        
        return listOfInteractionShareRecords;
    }
    
    Public static List<SObject> createConsumptionsShareRecords(Teams__c accountTeamToGrantAccess){
        List<SObject> listOfConsumptionsShareRecords = new List<SObject>();
        
        Map<Id,Consumption__c> mapOfConsumptionsRecordsToShare = getConsumptionsToShare(accountTeamToGrantAccess);
        //Remove records from sharing if the Account Team User is the owner (now handled in the records query)
        
        if(!mapOfConsumptionsRecordsToShare.isEmpty()){
            Map<Id,String> mapOfUserIdWithAccessLevel = new Map<Id,String>{accountTeamToGrantAccess.User__c => SharingUtility.getAccessLevel(accountTeamToGrantAccess)};
            
            //Create the sharing wrapper to use for creating the sharing records later
            SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Consumption__c');
            
            wrapper.rowCause = Schema.Consumption__Share.RowCause.Access_Set__c; //'Access Set' as row cause for standard object
            wrapper.mapOfRecordIdWithUserIdsNAccessLevel = createMapOfRecordIdWithUserIdNAccessLevel(mapOfConsumptionsRecordsToShare.keySet(),mapOfUserIdWithAccessLevel);
            
            listOfConsumptionsShareRecords = SharingUtility.createSharingRecords(wrapper);
        }
        
        return listOfConsumptionsShareRecords;
    }
    
    Public static List<SObject> createBudgetsShareRecords(Teams__c accountTeamToGrantAccess){
        List<SObject> listOfBudgetsShareRecords = new List<SObject>();
        Map<Id,Budget_vs_Actuals__c> mapOfBudgetsRecordsToShare = getBudgetsToShare(accountTeamToGrantAccess);
        //Remove records from sharing if the Account Team User is the owner (now handled in the records query)
        if(!mapOfBudgetsRecordsToShare.isEmpty()){
            Map<Id,String> mapOfUserIdWithAccessLevel = new Map<Id,String>{accountTeamToGrantAccess.User__c => SharingUtility.getAccessLevel(accountTeamToGrantAccess)};
            
            //Create the sharing wrapper to use for creating the sharing records later
            SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Budget_vs_Actuals__c');
            
            wrapper.rowCause = Schema.Budget_vs_Actuals__Share.RowCause.Access_Set__c; //'Access Set' as row cause for standard object
        	wrapper.mapOfRecordIdWithUserIdsNAccessLevel = createMapOfRecordIdWithUserIdNAccessLevel(mapOfBudgetsRecordsToShare.keySet(),mapOfUserIdWithAccessLevel);
            
            listOfBudgetsShareRecords = SharingUtility.createSharingRecords(wrapper);
        }
        return listOfBudgetsShareRecords;
    }
    
    Public static List<SObject> createAccountPlansShareRecords(Teams__c accountTeamToGrantAccess){
        List<SObject> listOfAccountPlansShareRecords = new List<SObject>();
        
        Map<Id,Account_Plans__c> mapOfAccountPlansRecordsToShare = getAccountPlansToShare(accountTeamToGrantAccess);
        //Remove records from sharing if the Account Team User is the owner (now handled in the records query)
        
        if(!mapOfAccountPlansRecordsToShare.isEmpty()){
            Map<Id,String> mapOfUserIdWithAccessLevel = new Map<Id,String>{accountTeamToGrantAccess.User__c => SharingUtility.getAccessLevel(accountTeamToGrantAccess)};
            
            //Create the sharing wrapper to use for creating the sharing records later
            SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Account_Plans__c');
            
            wrapper.rowCause = Schema.Account_Plans__Share.RowCause.Access_Set__c;//'Access Set' as row cause for standard object
            wrapper.mapOfRecordIdWithUserIdsNAccessLevel = createMapOfRecordIdWithUserIdNAccessLevel(mapOfAccountPlansRecordsToShare.keySet(),mapOfUserIdWithAccessLevel);
            
        	listOfAccountPlansShareRecords = SharingUtility.createSharingRecords(wrapper);
        }
        
        return listOfAccountPlansShareRecords;
    }
    
    Public static List<SObject> createEngagementPlansShareRecords(Teams__c accountTeamToGrantAccess){
        List<SObject> listOfEngagementPlansShareRecords = new List<SObject>();
        
        Map<Id,Engagement_Plan__c> mapOfEngagementPlansRecordsToShare = getEngagementPlansToShare(accountTeamToGrantAccess);
        //Remove records from sharing if the Account Team User is the owner (now handled in the records query)
        
        if(!mapOfEngagementPlansRecordsToShare.isEmpty()){
            Map<Id,String> mapOfUserIdWithAccessLevel = new Map<Id,String>{accountTeamToGrantAccess.User__c => SharingUtility.getAccessLevel(accountTeamToGrantAccess)};
            
            //Create the sharing wrapper to use for creating the sharing records later
            SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Engagement_Plan__c');
            wrapper.rowCause = Schema.Engagement_Plan__share.RowCause.Access_Set__c;  //'Access Set' as row cause for standard object
            
        	wrapper.mapOfRecordIdWithUserIdsNAccessLevel = createMapOfRecordIdWithUserIdNAccessLevel(mapOfEngagementPlansRecordsToShare.keySet(),mapOfUserIdWithAccessLevel);
            
        	listOfEngagementPlansShareRecords = SharingUtility.createSharingRecords(wrapper);
        }
        
        return listOfEngagementPlansShareRecords;
    }
    
    /*Public static map<Id, set<Id>> createMapOfRecordIdWithUserId(Set<Id> setOfRecordIds, ID userId){
        map<Id, set<Id>> mapOfRecordIdWithUserIds = new map<Id, set<Id>>();
        if(!setOfRecordIds.isEmpty() && userId != Null){
            Set<Id> setOfUserIds = new Set<Id>{userId};
            for(Id eachRecordID : setOfRecordIds){
           		mapOfRecordIdWithUserIds.put(eachRecordID,setOfUserIds);
            }
        }
        return mapOfRecordIdWithUserIds;
    }*/
    
    Public static map<Id, Map<Id,String>> createMapOfRecordIdWithUserIdNAccessLevel(Set<Id> setOfRecordIds, Map<Id,String> mapOfUserIdNAccessLevel){
        map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel = new map<Id, Map<Id,String>>();
        if(!setOfRecordIds.isEmpty() && !mapOfUserIdNAccessLevel.isEmpty()){
            for(Id eachRecordID : setOfRecordIds){
           		mapOfRecordIdWithUserIdsNAccessLevel.put(eachRecordID,mapOfUserIdNAccessLevel);
            }
        }
        return mapOfRecordIdWithUserIdsNAccessLevel;
    }
    
    
    /*Public static String getAccessLevel(Teams__c accountTeamToGrantAccess){
        //By Default READ/VIEW Access
        String accessLevel = SharingUtility.VIEW_PERMISSION;
        if(accountTeamToGrantAccess.Is_Primary__c || accountTeamToGrantAccess.Access_Level__c == SharingUtility.TEAMS_EDIT_ACCESS){
            accessLevel = SharingUtility.EDIT_PERMISSION;
        }
        return accessLevel;
    }*/
    
    
    Public static Map<Id,Opportunity> getOpportunitiesToShare(Teams__c accountTeamToGrantAccess){
        Set<ID> vietnamOpsIDS = new Set<ID>();
        vietnamOpsIDS.add(OpportunityConstants.PLBS_TENDERING_OPPORTUNITY_RECORD_TYPE_ID);
        vietnamOpsIDS.add(OpportunityConstants.PLBS_TENDERING_PRODUCT_RECORD_TYPE_ID);
        
        if(accountTeamToGrantAccess.Business_Unit__c == SharingUtility.BU_ALL){
            return new Map<Id,Opportunity>([Select Id,OwnerID from opportunity where AccountID =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c and recordTypeID !=: vietnamOpsIDS]);
        }
        else{
            return new Map<Id,Opportunity>([Select Id,OwnerID from opportunity where AccountID =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c and Business_Unit__c =: accountTeamToGrantAccess.Business_Unit__c and recordTypeID !=: vietnamOpsIDS]);
        }
    }

    
    Public static Map<Id,Contact> getContactsToShare(Teams__c accountTeamToGrantAccess){
        return new Map<Id,Contact>([Select Id,OwnerID from Contact where AccountID =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c]);
    }
    
    
    Public static Map<Id,Interactions__c> getInteractionsToShare(Teams__c accountTeamToGrantAccess){
        if(accountTeamToGrantAccess.Business_Unit__c == SharingUtility.BU_ALL){
            return new Map<Id,Interactions__c>([Select Id,OwnerID from Interactions__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c]);
        }
        else{
            return new Map<Id,Interactions__c>([Select Id,OwnerID from Interactions__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c and Business_Unit__c =: accountTeamToGrantAccess.Business_Unit__c]);
        }
    }
    
    
    Public static Map<Id,Consumption__c> getConsumptionsToShare(Teams__c accountTeamToGrantAccess){
        if(accountTeamToGrantAccess.Business_Unit__c == SharingUtility.BU_ALL){
            return new Map<Id,Consumption__c>([Select Id,OwnerID from Consumption__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c ]);
        }
        else{
            return new Map<Id,Consumption__c>([Select Id,OwnerID from Consumption__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c and Business_Unit__c =: accountTeamToGrantAccess.Business_Unit__c]);
        }
    }
    
    
    Public static Map<Id,Budget_vs_Actuals__c> getBudgetsToShare(Teams__c accountTeamToGrantAccess){
        if(accountTeamToGrantAccess.Business_Unit__c == SharingUtility.BU_ALL){
            return new Map<Id,Budget_vs_Actuals__c>([Select Id,OwnerID from Budget_vs_Actuals__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c]);
        }
        else{
            return new Map<Id,Budget_vs_Actuals__c>([Select Id,OwnerID from Budget_vs_Actuals__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c and Business_Unit__c =: accountTeamToGrantAccess.Business_Unit__c]);
        }
    }
    
    
    Public static Map<Id,Account_Plans__c> getAccountPlansToShare(Teams__c accountTeamToGrantAccess){
        if(accountTeamToGrantAccess.Business_Unit__c == SharingUtility.BU_ALL){
            return new Map<Id,Account_Plans__c>([Select Id,OwnerID from Account_Plans__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c]);
        }
        else{
            return new Map<Id,Account_Plans__c>([Select Id,OwnerID from Account_Plans__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c and BU_Identifier__c =: accountTeamToGrantAccess.Business_Unit__c]);
        }
    }
    
    
    Public static Map<Id,Engagement_Plan__c> getEngagementPlansToShare(Teams__c accountTeamToGrantAccess){
        if(accountTeamToGrantAccess.Business_Unit__c == SharingUtility.BU_ALL){
            return new Map<Id,Engagement_Plan__c>([Select Id,OwnerID from Engagement_Plan__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c]);
        }
        else{
            return new Map<Id,Engagement_Plan__c>([Select Id,OwnerID from Engagement_Plan__c where Account__c =:accountTeamToGrantAccess.Account__c and OwnerId != : accountTeamToGrantAccess.User__c and Business_Unit__c =: accountTeamToGrantAccess.Business_Unit__c]);
        }
    }
    
    Public static List<Retry_Log__c> getAccountTeamGrantAccessRetryLog(Id accTeamId, String typeValue){
        //List<Retry_Log__c> listOfRetryLogs = new  List<Retry_Log__c>();
        return [Select Id, Access_Set_Assignment__c,Account_Team__c,Error_Message__c,Retry_Count__c,Type__c
                FROM Retry_Log__c 
                where Type__c =: typeValue and Account_Team__c =: accTeamId limit 1];
    }
}