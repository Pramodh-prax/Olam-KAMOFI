/* 
* This class is an account trigger handler which validate the Account creation for different users with their respective access sets. 
* If a valid access set is there, respective team members are added to the account team.
* Author            : Joel and Sameer
* Date              : 22/12/2021
*/

//CHANGES TO BE MADE : Make it Future. Create one account at a time.

public class AccountTriggerOFIHandler {
    public static boolean isAccountTeamInsert = false;
    public static void accountCreationValidationOFI(List<Account> listOfAccounts)
    {    
        Id currentUserId = UserInfo.getUserId();
        map<String,set<String>> AccessSetUserIDMap = new map<String,set<String>>();
        list<Teams__c> listOfTeamsToInsert = new list<Teams__c>();
        map<string,set<Access_Set__c>> validAccessSetmap = new map<string,set<Access_Set__c>>();
        Map<Id, Map<id,List<Teams__c>>> mapOfAccIdWithMapOfBUAndTeamsList = new Map<Id, Map<id,List<Teams__c>>>();
        
        //Dynamic Query to fetch current user access set assignment
        List<Access_Set__c> accessList = getAccountsMatchingAccessSetValues(listOfAccounts);
        
        //Creating Map of Access Set and it's set of assigned users
        for(Access_Set__c obj:accessList){
            for(Access_Set_Assignment__c obj2: obj.Access_Set_Assignments__r){
                Access_Set_Assignment__c obj33 = new Access_Set_Assignment__c();
                if(AccessSetUserIDMap.containsKey(obj.Id)){
                    AccessSetUserIDMap.get(obj.Id).add(obj2.User__c);
                }
                else{
                    AccessSetUserIDMap.put(obj.Id,new set<string>{obj2.User__c});
                } 
            }
        }
        
        //Fetch the Valid Access set using account and access list
        if(listOfAccounts!=null && accessList!=null){
            validAccessSetmap = getValidAccessSet(listOfAccounts, accessList);
        }
        
        //Add Teams to the acccount if there is a valid access set assigned to any user
        //If multiple access set is present for any user, append the access set ID to Access_Set_Ids__c field in Account Teams
        if(!validAccessSetmap.isEmpty()){
            for(String accId : validAccessSetmap.keySet()){
                for(Access_Set__c AccSetId: validAccessSetmap.get(accId)){
                    if(AccessSetUserIDMap.containsKey(AccSetId.Id)){
                        list<Teams__c> teamObj2 =addUserToList(AccessSetUserIDMap.get(AccSetId.Id), AccSetId.Id, accId, AccSetId.BU__c, currentUserId);
                        if(teamObj2!=null){
                            for(Teams__c team : teamObj2){ 
                                if(mapOfAccIdWithMapOfBUAndTeamsList.ContainsKey(accId)){
                                    if(mapOfAccIdWithMapOfBUAndTeamsList.get(accId).ContainsKey(team.User__c)){
                                        for(Teams__c teamNewObj : mapOfAccIdWithMapOfBUAndTeamsList.get(accId).get(team.User__c)){
                                            if(team.Business_Unit__c=='All'){
                                                teamNewObj.Business_Unit__c=team.Business_Unit__c;
                                            }
                                            teamNewObj.Access_Set_Ids__c+=','+team.Access_Set_Ids__c;
                                        }
                                    }
                                    else{
                                        mapOfAccIdWithMapOfBUAndTeamsList.get(accId).put(team.User__c,new List<Teams__c>{team});
                                    }
                                }
                                else{
                                    mapOfAccIdWithMapOfBUAndTeamsList.put(accId,new Map<id,List<Teams__c>>{team.User__c => new List<Teams__c>{team}});
                                }
                            }
                        } 
                    }
                }
            }
            if(!mapOfAccIdWithMapOfBUAndTeamsList.isEmpty()){
                for(id accID:mapOfAccIdWithMapOfBUAndTeamsList.keySet()){
                    for(id userID : mapOfAccIdWithMapOfBUAndTeamsList.get(accID).keySet()){
                        for(Teams__c teamOBJ: mapOfAccIdWithMapOfBUAndTeamsList.get(accID).get(userID)){
                            listOfTeamsToInsert.add(teamOBJ);
                        }
                    }  
                }
                isAccountTeamInsert = true;
                insert listOfTeamsToInsert;
            }
        }    
    }
    
    
    //This Method appends the Team members to the Account teams List
    public static list<Teams__c> addUserToList(set<String> userSet, id AccessSetID, String accId, String BU, Id currentUserId)
    {   
        list<Teams__c> TeamsToInsertList = new list<Teams__c>();
        for(String UserId : userSet){
            Teams__c t=new Teams__c();
            t.Account__c=accId;
            t.User__c=UserId;
            t.Business_Unit__c = BU;
            t.Access_Set_Ids__c = AccessSetID;
            if(currentUserId == UserId){   
                t.Is_Primary__c=true;
                t.Access_Level__c='Edit Access';
            }
            else{
                t.Is_Primary__c=false;
                t.Access_Level__c='Read Access';
            }
            TeamsToInsertList.add(t);
        }
        return TeamsToInsertList;
    }
    
    //This method constructs, queries and returns the access set and access set assignment values which are matching with the current list of accounts
    Public static List<Access_Set__c> getAccountsMatchingAccessSetValues(List<Account> listOfAccounts){
        Set<String> AcountRegionsSet = new  Set<String> ();
        Set<String> AcountCountrySet = new  Set<String> ();
        Set<String> AcountChannelSet = new  Set<String> ();
        Set<String> AcountCustomerGrpSet = new  Set<String> ();
        
        for(Account acntObj: listOfAccounts){
            if(acntObj.Regions__c!=null){
                AcountRegionsSet.add(acntObj.Regions__c);}
            if(acntObj.BillingCountryCode!=null){
                AcountCountrySet.add(acntObj.BillingCountryCode);}
            if(acntObj.Channel__c!=null){
                AcountChannelSet.add(acntObj.Channel__c);}
            if(acntObj.Customer_Group__c!=null){
                AcountCustomerGrpSet.add(acntObj.Customer_Group__c); }
        }
        
        String queryString = 'Select Id, Name, Regions__c, Country__c, BU__c, Customer_Group__c, Channel__c,(select Access_Set__c, user__c from Access_Set_Assignments__r) from Access_Set__c where Id != Null AND (';
        if(!AcountCountrySet.isEmpty()){
            queryString += 'Country__c IN : AcountCountrySet';
        }
        if(!AcountRegionsSet.isEmpty()){
            queryString += ' OR Regions__c IN : AcountRegionsSet';
        }
        
        if(!AcountCustomerGrpSet.isEmpty()){
            queryString += ' OR Customer_Group__c IN : AcountCustomerGrpSet';
        }
        if(!AcountChannelSet.isEmpty()){
            queryString += ' OR Channel__c IN : AcountChannelSet';
        }
        queryString += ')';
        return Database.query(queryString);
    }
    
    
    //This Method checks, validate and return a valid access set from any account and access list
    public static map<string,set<Access_Set__c>> getValidAccessSet(List<Account> listOfAccounts,  List<Access_Set__c> accessList )
    {
        map<string,set<Access_Set__c>> mapOfAccIdToSetOfAcs=new map<string,set<Access_Set__c>>();
        for(Account acc:listOfAccounts)
        {
            for(Access_Set__c accSet: accessList)
            {
                if(accSet.Regions__c==acc.Regions__c && accSet.Country__c==acc.BillingCountryCode && accSet.Customer_Group__c==acc.Customer_Group__c && accSet.Channel__c==acc.Channel__c)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==acc.Regions__c && accSet.Country__c==acc.BillingCountryCode && accSet.Customer_Group__c==acc.Customer_Group__c && accSet.Channel__c==null)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==acc.Regions__c && accSet.Country__c==null && accSet.Customer_Group__c==acc.Customer_Group__c && accSet.Channel__c==acc.Channel__c)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==null && accSet.Country__c==acc.BillingCountryCode && accSet.Customer_Group__c==acc.Customer_Group__c && accSet.Channel__c==acc.Channel__c)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==acc.Regions__c && accSet.Country__c==acc.BillingCountryCode && accSet.Customer_Group__c==acc.Customer_Group__c && accSet.Channel__c==acc.Channel__c)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==acc.Regions__c && accSet.Country__c==null && accSet.Customer_Group__c==acc.Customer_Group__c && accSet.Channel__c==null)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==acc.Regions__c && accSet.Country__c==null && accSet.Customer_Group__c==null && accSet.Channel__c==acc.Channel__c)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==null && accSet.Country__c==acc.BillingCountryCode && accSet.Customer_Group__c==acc.Customer_Group__c && accSet.Channel__c==null)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                } 
                else if(accSet.Regions__c==null && accSet.Country__c==acc.BillingCountryCode && accSet.Customer_Group__c==null && accSet.Channel__c==acc.Channel__c)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==acc.Regions__c && accSet.Country__c==null && accSet.Customer_Group__c==null && accSet.Channel__c==null)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }
                else if(accSet.Regions__c==null && accSet.Country__c==acc.BillingCountryCode && accSet.Customer_Group__c==null && accSet.Channel__c==null)
                {
                    if(mapOfAccIdToSetOfAcs.containsKey(acc.Id)){
                        mapOfAccIdToSetOfAcs.get(acc.Id).add(accSet);
                    }else{
                        mapOfAccIdToSetOfAcs.put(acc.Id, new set<Access_Set__c>{accSet});
                    }
                }                             
            }   
        }
        return mapOfAccIdToSetOfAcs;    
    }
    
}