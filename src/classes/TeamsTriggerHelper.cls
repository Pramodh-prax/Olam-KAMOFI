public class TeamsTriggerHelper {
    //Commented by Bharatesh Shetty - handled in updateTeamMemberAccessDetails method below
    /*Public Static void makeAccessLevelChangeToPrimary(List<Teams__c> listOfNewTeams){
//Pramodh Added to give Edit Access for primary user
for(Teams__c tempTeamMember : listOfNewTeams){
If(tempTeamMember.Is_Primary__c){
tempTeamMember.Access_Level__c = 'Edit Access';
}
}
}*/
    //This method checks -only one primary team member assigned for each BU in a account and duplicate user should not be added
    //Only a  primary user for a BU can add or Edit the  team members of Same BU  (this validation Skipped for Admin and Automated user) 
    //User will not have permission to uncheck the primary checkbox(only admin can uncheck)
    //Added by Ashwini Godase
    //Date : 5/1/2022
    public static void checkForValidations(List<Teams__c> listOfNewTeams,Map<Id,Teams__c> MapOfOldTeams, boolean isInsert){
        
        
        Set<Id> accountIdSet = new Set<Id>();
        //Fetch current User
        Id userID=userInfo.getUserId(); 
        for(Teams__c team :listOfNewTeams){
            //Fetch Account Id
            if(team.Account__c != null){
                accountIdSet.add(team.Account__c);     
            } 
        }
        //Fecth Existing team List from DB
        List<Teams__c> existingTeamsList = new List<Teams__c>();
        existingTeamsList = getTeamsList(accountIdSet);
        Map<Id, Map<String, Set<Id>>> existingAccountTeamsMap = new Map<Id, Map<String, Set<Id>>>();
        Map<Id, Map<String, Teams__c>> existingAccountPrimaryTeamsMap = new Map<Id, Map<String, Teams__c>>();
        Map<Id, Set<id>> existingAccountTeamsMapNew = new Map<Id, Set<id>>();
        
        if(existingTeamsList.size() > 0){
            //Existing Team List to MAp
            existingAccountTeamsMap = getAccountTeamsMap(existingTeamsList); 
            //Add All Account Team to Map
            existingAccountTeamsMapNew=getAccountTeamsMapNew(existingTeamsList);
            //Fetch All Primary Account Teams
            existingAccountPrimaryTeamsMap = getPrimaryAccountTeamsMap(existingTeamsList);  
            for(Teams__c team: listOfNewTeams){
                //Checking whether the Primary BU Exists for a Specific BU 
                if(!existingAccountPrimaryTeamsMap.isEmpty() && !existingAccountTeamsMap.isEmpty()){
                    if(existingAccountPrimaryTeamsMap.get(team.Account__c) !=null){
                        if(existingAccountTeamsMap.containsKey(team.Account__c) &&
                           existingAccountPrimaryTeamsMap.get(team.Account__c).containsKey(team.Business_Unit__c) 
                           && team.Is_Primary__c == true  && (isInsert || 
                                                              !isInsert && (team.Is_Primary__c != MapOfOldTeams.get(team.Id).Is_Primary__c ||
                                                                            team.Business_Unit__c != MapOfOldTeams.get(team.Id).Business_Unit__c)))
                        {
                            team.addError(Label.AccountTeamOnlyOnePrimaryAllowed);
                        }
                    }
                }
                //Check Whether the User Already Exists
                If(!existingAccountTeamsMapNew.isEmpty()){
                    if((existingAccountTeamsMapNew.containsKey(team.Account__c) &&
                        existingAccountTeamsMapNew.get(team.Account__c).contains(team.User__c) && 
                        (isInsert || !isInsert && (team.User__c != MapOfOldTeams.get(team.Id).User__c)))
                      )  
                    {
                        team.addError(Label.AccountTeamUserAlreadyExists);
                    }
                }
                
            }
            
        }
        //Custom Permission for admin
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        //Skip for Admin and Automated process
        if(hasCustomPermission || userInfo.getName() == System.Label.Automated_Process)  
        {
            
        }
        else{
            Map<Id, Map<String, Teams__c>> existingAccountPrimaryTeamsMapNew = new Map<Id, Map<String, Teams__c>>();
            if(existingTeamsList.size() >0)
            {
                //Fetch existing Primary team list with current user
                existingAccountPrimaryTeamsMapNew = getPrimaryAccountTeamsMapNew(existingTeamsList);  
            } 
            if(isInsert){
                for(Teams__c listTeam : listOfNewTeams)   
                {   
                    if(!existingAccountPrimaryTeamsMapNew.isEmpty() && !AccountTriggerOFIHandler.isAccountTeamInsert){
                        //Check Primary Member of a BU adding the Member of same BU
                        if(existingAccountPrimaryTeamsMapNew.get(listTeam.Account__c).containsKey(listTeam.Business_Unit__c)
                           || existingAccountPrimaryTeamsMapNew.get(listTeam.Account__c).containsKey('All'))
                        {     
                        }
                        else
                        {
                            listTeam.addError('Primary Member Of Particular BU can Add/Edit Team Member of same BU');
                        }
                    }
                    else{
                        //Check Whether current user is part of Account Team
                        if(listTeam.User__c != userID && !AccountTriggerOFIHandler.isAccountTeamInsert){
                            listTeam.addError('You are not Primary team Member to Add other users');
                        }
                    }    
                }
            }
            
            if(!isInsert){
                if(existingTeamsList.size() >0)
                {
                    existingAccountPrimaryTeamsMapNew = getPrimaryAccountTeamsMapNew(existingTeamsList);  
                    for(Teams__c listTeam : listOfNewTeams)   
                    {  
                        //Check Whether Present user  In Account Team 
                        //if( existingAccountPrimaryTeamsMapNew.isEmpty() && (listTeam.User__c!=userID ))
                        if( existingAccountPrimaryTeamsMapNew.isEmpty() && (listTeam.User__c!=userID ))
                        {
                            listTeam.addError('You are not a Primary Member to Edit Team Members');
                        } 
                        
                        if(listTeam.User__c==userID && listTeam.Is_Primary__c == false){
                            //if(!((MapOfOldTeams.get(listTeam.id).Access_Level__c).equals(listTeam.Access_Level__c))
                            //  || !((MapOfOldTeams.get(listTeam.id).Access_Set_Role__c).equals(listTeam.Access_Set_Role__c))
                            // )
                            listTeam.addError('You are not a Primary Member to Edit');
                        }
                        
                        if(!existingAccountPrimaryTeamsMapNew.isEmpty()){
                            //Skip the validation if user has a BU as All
                            if(existingAccountPrimaryTeamsMapNew.get(listTeam.Account__c).containsKey('All'))
                            {   
                            }
                            //Only a Primary team member of a BU can edit the  team member Of Same BU
                            else if((!existingAccountPrimaryTeamsMapNew.get(listTeam.Account__c).containsKey(listTeam.Business_Unit__c)) 
                                    && !(listTeam.User__c==userID)
                                    && (listTeam.Id == MapOfOldTeams.get(listTeam.id).id))
                            {
                                
                                listTeam.addError('Primary Team Member Of Particular BU can only Add/Edit Team Member of same BU');
                                
                            }
                            //Primary team member of a BU as ALL can edit the Primary team members
                            if((!existingAccountPrimaryTeamsMapNew.get(listTeam.Account__c).containsKey('All') && (MapOfOldTeams.get(listTeam.id).Is_Primary__c)==true )
                               && (listTeam.Id == MapOfOldTeams.get(listTeam.id).id) && !(MapOfOldTeams.get(listTeam.id).User__c==userID))
                            {
                                listTeam.addError('Primary Member Of Particular Business Unit can not edit another Primary Member');
                            }  
                            if(!MapOfOldTeams.isEmpty()){
                                //Restrict user to change the BU type
                                if(!((MapOfOldTeams.get(listTeam.id).Business_Unit__c).equals(listTeam.Business_Unit__c)))
                                {
                                    listTeam.addError('You Dont have permission to Change BU');
                                }
                                
                            }
                        }
                        //Dont Allow user to uncheck the Primary Check Box
                        if ((MapOfOldTeams.get(listTeam.id).Is_Primary__c)==true && listTeam.Is_Primary__c==false ) {     //Only For Uncheck
                            
                            listTeam.addError('Only admin can uncheck the Primary check box');
                        }
                    }
                }
            }
        }
    }
    
    
    //Get Account Team in a Map
    public static Map<Id, Set<id>> getAccountTeamsMapNew(List<Teams__c> teamsList){
        Map<Id, Set<id>> primaryTeamsMap = new Map<Id,Set<id>>();
        for(Teams__c team :teamsList){
            if(primaryTeamsMap.containsKey(team.Account__c)){
                primaryTeamsMap.get(team.Account__c).add(team.User__c);
            }
            else{
                primaryTeamsMap.put(team.Account__c, new Set<Id>{team.User__c});
            }
        }
        return primaryTeamsMap;
    }
    
    //Fetch Primary Account Team Member With Current User
    public static Map<Id, Map<String, Teams__c>> getPrimaryAccountTeamsMapNew(List<Teams__c> teamsList){
        Map<Id, Map<String, Teams__c>> primaryTeamsMap = new Map<Id, Map<String, Teams__c>>();
        for(Teams__c team :teamsList){
            if(team.Is_Primary__c == true && team.User__c==userinfo.getUserId()){
                if(primaryTeamsMap.containsKey(team.Account__c)){
                    primaryTeamsMap.get(team.Account__c).put(team.Business_Unit__c, team);
                }
                else{
                    primaryTeamsMap.put(team.Account__c, new Map<String, Teams__c>{team.Business_Unit__c => team});
                }
            }
        }
        return primaryTeamsMap;
    }
    
    //Fetch Primary Account Team Member
    public static Map<Id, Map<String, Teams__c>> getPrimaryAccountTeamsMap(List<Teams__c> teamsList){
        Map<Id, Map<String, Teams__c>> primaryTeamsMap = new Map<Id, Map<String, Teams__c>>();
        
        for(Teams__c team :teamsList){
            if(team.Is_Primary__c == true){
                if(primaryTeamsMap.containsKey(team.Account__c)){
                    primaryTeamsMap.get(team.Account__c).put(team.Business_Unit__c, team);
                }
                else{
                    primaryTeamsMap.put(team.Account__c, new Map<String, Teams__c>{team.Business_Unit__c => team});
                }
            }
        }
        return primaryTeamsMap;
    }
    
    //Fetch Existing Team Members 
    public static List<Teams__c> getTeamsList(Set<Id> accountIdSet){
        List<Teams__c> teamList = new List<Teams__c>();
        teamList = [SELECT Id, Account__c, Business_Unit__c, Is_Primary__c, User__c FROM Teams__c WHERE Account__c IN :accountIdSet];
        return teamList;
    }
    
    //Add Exisitng team members to the Map
    public static Map<Id, Map<String, Set<Id>>> getAccountTeamsMap(List<Teams__c> teamsList){
        Map<Id, Map<String, Set<Id>>> accountTeamsMap = new Map<Id, Map<String, Set<Id>>>();
        for(Teams__c team :teamsList){
            if(accountTeamsMap.containsKey(team.Account__c)){
                if(accountTeamsMap.get(team.Account__c).containsKey(team.Business_Unit__c)){
                    accountTeamsMap.get(team.Account__c).get(team.Business_Unit__c).add(team.User__c);
                }
                else{
                    accountTeamsMap.get(team.Account__c).put(team.Business_Unit__c, new Set<Id>{team.User__c});
                }
            }
            else{
                accountTeamsMap.put(team.Account__c, new Map<String, Set<Id>>{team.Business_Unit__c => new Set<Id>{team.User__c}});
            }
        }
        return accountTeamsMap;
    }
    //Added by Bharatesh Shetty
    Public Static void updateTeamMemberAccessDetails(List<Teams__c> listOfNewTeams, Map<Id,Teams__c> mapOfOldTeams){
        
        //For insert scenario - pass mapOfOldTeams as NULL
        if(!listOfNewTeams.isEmpty() && mapOfOldTeams == NULL){
            for(Teams__c team : listOfNewTeams){
                //set grant access status as "Initiated" 
                team.Grant_Access_Status__c = SharingUtility.TEAMS_GRANTACCESSSTATUS_INITIATED;
                if(team.Is_Primary__c ){
                    // if the user is primary then set access Level as "Edit Access" by default
                    team.Access_Level__c = SharingUtility.TEAMS_EDIT_ACCESS;
                }
            }
        }
        
        //For update scenario - pass mapOfOldTeams
        else if(!listOfNewTeams.isEmpty() && mapOfOldTeams != NULL &&  !mapOfOldTeams.isEmpty()){
            Set<Id> setOfTeamIds = new Set<Id>();
            for(Teams__c team : listOfNewTeams){
                if(mapOfOldTeams.containsKey(team.Id)){
                    
                    //If the user is updated from non primary to primary and access level was not "Edit Access" consider them for sharing the records
                    if(team.Is_Primary__c && team.Is_Primary__c != mapOfOldTeams.get(team.Id).Is_Primary__c && team.Access_Level__c != SharingUtility.TEAMS_EDIT_ACCESS){
                        team.Access_Level__c = SharingUtility.TEAMS_EDIT_ACCESS;
                        team.Grant_Access_Status__c = SharingUtility.TEAMS_GRANTACCESSSTATUS_INITIATED;
                        setOfTeamIds.add(team.Id);
                    }
                    
                    //If the user's access Level has changed or BU has changed consider them for sharing the records
                    //Access for the new BU will be handled with this but Revoking the access for the other BU records shared previously need to be handled later.
                    //Commented by JOEL BU handled in OFI_RevokeAccountAccessTriggerHandler.apxc
                    if((team.Access_Level__c != mapOfOldTeams.get(team.Id).Access_Level__c) /*|| (team.Business_Unit__c != mapOfOldTeams.get(team.Id).Business_Unit__c)*/){
                        team.Grant_Access_Status__c = SharingUtility.TEAMS_GRANTACCESSSTATUS_INITIATED;
                        setOfTeamIds.add(team.Id);
                    }
                }
            }
            if(!setOfTeamIds.isEmpty()){
                //If there are any child retryLog records under these account Team records delete them so that it will get picked up in the platform evet for sharing
                List<Retry_Log__c> listOfRetryLogsToDelete = [Select Id, Access_Set_Assignment__c,Account_Team__c,Error_Message__c,Retry_Count__c,Type__c
                                                              FROM Retry_Log__c 
                                                              where Type__c =: SharingUtility.RETRYLOGTYPE_ACCOUNT_TEAM_GRANT_ACCESS 
                                                              and Account_Team__c =: setOfTeamIds];
                if(!listOfRetryLogsToDelete.isEmpty()){
                    delete listOfRetryLogsToDelete;
                }
            }
        }
    }
    
    //This Method validates the current user from adding themselves to different Accounts.
    //If a valid access set is there for that account, current user is allowed to make the changes.
    //Added by Joel tom
    //Date : 22/12/2021
    public static void currentMemberAdditionValidationOFI(List<Teams__c> TeamList)
    {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        Id currentUserId = UserInfo.getUserId();
        Map<Id,List<Teams__c>> AccIDToTeamMap = new map<Id,List<Teams__c>>();
        Map<string,set<Access_Set__c>> isValidCurrentUserMap = new map<string,set<Access_Set__c>>();
        
        //Creating a Map of Account Id and team entry with respect to current logged in user
        for(Teams__c TeamEntry : TeamList){   
            if(AccIDToTeamMap.containsKey(TeamEntry.Account__c)){
                AccIDToTeamMap.get(TeamEntry.Account__c).add(TeamEntry);
            }else{
                AccIDToTeamMap.put(TeamEntry.Account__c,new List<Teams__c>{TeamEntry});
            }
        }
        
        //Database SOQL Queries to fetch all the required records
        List<Account> AccountList =[select Id,Regions__c,BillingCountryCode,Customer_Group__c,Channel__c from Account where Id in :AccIDToTeamMap.KeySet()];   
        List<Access_Set__c> currentUserAccessList = [Select Id,Name,Regions__c,Country__c,BU__c,Customer_Group__c,Channel__c from Access_Set__c where Id IN 
                                                     (Select Access_Set__c from Access_Set_Assignment__c where User__c=:currentUserId)];
        
        //Calling the method in AccountTriggerOFIHandler to validate the account and current user access list w.r.t account and access set
        if(AccountList!=null && currentUserAccessList!=null){
            isValidCurrentUserMap = AccountTriggerOFIHandler.getValidAccessSet(AccountList,currentUserAccessList);
        }       
        
        //Checking and validating all if the current user has a valid access set to be added into account teams
        if(!isValidCurrentUserMap.isEmpty() && !hasCustomPermission && userInfo.getName() != System.Label.Automated_Process){
            Boolean validCheck = false;
            for(String accId : isValidCurrentUserMap.keySet()){
                List<Teams__c> TeamObjList= AccIDToTeamMap.get(accId);
                for(Teams__c TeamObj : TeamObjList){
                    if(Teamobj.User__c==currentUserId){
                        validCheck = validateBUwithCurrentUser(isValidCurrentUserMap.get(accId), TeamObj);
                        if(!validCheck){
                            TeamObj.addError('Your assigned BU in access set does not match with selected BU');
                        }
                    }
                }   
            }
        }
        else{ 
            for(Teams__c TeamEntry : TeamList){
                if(TeamEntry.User__c==currentUserId && !hasCustomPermission  && userInfo.getName() != System.Label.Automated_Process){
                    TeamEntry.addError('This user cannot be added due to access set restriction');
                }
            }      
        }  
    }
    
    //This method returns a boolean value if the current user has a valid access set with the BU as well
    //Added by Joel Tom
    public static boolean validateBUwithCurrentUser(Set<Access_Set__c> validAccessList, Teams__c TeamObj)
    {    
        Boolean isValid = false;
        for(Access_Set__c AccessObj:validAccessList)
        {
            if(AccessObj.BU__c!=null && TeamObj.Business_Unit__c!=null){
                if(AccessObj.BU__c == 'All')
                {
                    isValid = true;
                    break;
                }
                else if(AccessObj.BU__c == TeamObj.Business_Unit__c)
                {
                    isValid = true;
                    break;
                }
            }
            else{
                isValid = true;
                break;
            }
        }
        return isValid;
    }
    
    //Code Added by Ashwini For Delete Team(When user try to delete team member thorw error) skip for automated  user
    public static void deleteTeamOnlyForAutomatedUser(List<Teams__c> listOldValues)
    {
        System.debug('****inside'+userInfo.getName()+'---'+System.Label.Automated_Process);
        for(Teams__c tempTeam : listOldValues){
            if(userInfo.getName() != System.Label.Automated_Process)
            {
                tempTeam.addError('User dont have permission to delete Team Members');
            }
        }
    }
}