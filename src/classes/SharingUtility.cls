public class SharingUtility {
    
    public static final String MANUAL_ROWCAUSE = 'Manual';
    public static final String OWNER_ROWCAUSE = 'Owner';
    public static final String ACCESS_SET_ROWCAUSE = 'Access_Set';
    public static final String EDIT_PERMISSION = 'Edit';
    public static final String VIEW_PERMISSION = 'Read';
    public static final String PARENTID = 'ParentId';
    public static final String BU_ALL = 'All';
    public static final String TEAMS_READ_ACCESS = 'Read Access';
    public static final String TEAMS_EDIT_ACCESS = 'Edit Access';
    public static final String TEAMS_GRANTACCESSSTATUS_INITIATED = 'Initiated';
    public static final String TEAMS_GRANTACCESSSTATUS_PROCESSED = 'Processed';
    public static final String TEAMS_GRANTACCESSSTATUS_FAILED = 'Failed';
    public static final String ACCOUNT_TEAM_CREATION_STATUS_INITIATED = 'Initiated';
    public static final String ACCOUNT_TEAM_CREATION_STATUS_PROCESSED = 'Processed';
    public static final String ACCOUNT_TEAM_CREATION_STATUS_FAILED = 'Failed';
    public static final String RETRYLOGTYPE_ACCOUNT_TEAM_CREATION = 'Account Team Creation';
    public static final String RETRYLOGTYPE_ACCOUNT_TEAM_GRANT_ACCESS = 'Account Team Grant Access';
    
    public static final Integer ACCOUNTTEAMGRANTACCESS_RETRY_COUNT_LIMIT = 3;
    public static final Integer ACCOUNTTEAMCREATE_RETRY_COUNT_LIMIT = 3;
    
    Public class SharingRecordCreateWrapper{
        Public string shareObjectName;
        Public string parentFieldName;
        //Public map<Id, set<Id>> mapOfRecordIdWithUsersOrGroupsIds;
        Public map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel;
        Public string accessLevelFieldName;
        //Public string accessLevel;
        Public string rowCause;
    }
    
    //constructs and returns query string with all the fields of an Object
    public static String getQueryString(String objectName){
        Map<String, Schema.SObjectType> objMap = new Map<String, Schema.SObjectType>();
        objMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = objMap.get(objectName).getDescribe().fields.getMap();
        string queryString = 'SELECT ';
        for(Schema.SObjectField field :fieldMap.values()){
            queryString = queryString + field.getDescribe().getName() + ', ';
        }
        queryString = queryString.substring(0,queryString.length() - 2);
        return queryString;
    }
    
    /*public static list<SObject> createSharingRecords(SharingRecordCreateWrapper wrapper) {
list<SObject> lstObjects = new list<SObject>();
if(wrapper != Null){
if(String.isNotBlank(wrapper.shareObjectName) && String.isNotBlank(wrapper.parentFieldName) && String.isNotBlank(wrapper.accessLevelFieldName) 
&& String.isNotBlank(wrapper.accessLevel) &&  !wrapper.mapOfRecordIdWithUsersOrGroupsIds.isEmpty()){
SObjectType objectType = Schema.getGlobalDescribe().get(wrapper.shareObjectName);
for(Id recordId : wrapper.mapOfRecordIdWithUsersOrGroupsIds.keySet()){
if(!wrapper.mapOfRecordIdWithUsersOrGroupsIds.get(recordId).isEmpty()){
for(Id userOrGroupId : wrapper.mapOfRecordIdWithUsersOrGroupsIds.get(recordId)){
SObject shareRecord = objectType.newsObject();
shareRecord.put(wrapper.parentFieldName, recordId);
shareRecord.put('UserOrGroupId', userOrGroupId);
shareRecord.put(wrapper.accessLevelFieldName, wrapper.accessLevel);
shareRecord.put('RowCause', wrapper.rowCause);
lstObjects.add(shareRecord);
}
}
}
}
}
return lstObjects;
}*/
    
    public static list<SObject> createSharingRecords(SharingRecordCreateWrapper wrapper) {
        list<SObject> lstObjects = new list<SObject>();
        if(wrapper != Null){
            if(String.isNotBlank(wrapper.shareObjectName) && String.isNotBlank(wrapper.parentFieldName) && String.isNotBlank(wrapper.accessLevelFieldName) 
               && !wrapper.mapOfRecordIdWithUserIdsNAccessLevel.isEmpty()){
                   SObjectType objectType = Schema.getGlobalDescribe().get(wrapper.shareObjectName);
                   for(Id recordId : wrapper.mapOfRecordIdWithUserIdsNAccessLevel.keySet()){
                       //For each record Id iterate
                       if(!wrapper.mapOfRecordIdWithUserIdsNAccessLevel.get(recordId).isEmpty()){
                           for(Id userOrGroupId : wrapper.mapOfRecordIdWithUserIdsNAccessLevel.get(recordId).keySet()){
                               //For each user or group Id iterate and create a share record
                               SObject shareRecord = objectType.newsObject();
                               shareRecord.put(wrapper.parentFieldName, recordId);
                               shareRecord.put('UserOrGroupId', userOrGroupId);
                               //Acccess level will be different for each share record based on the user's access level
                               shareRecord.put(wrapper.accessLevelFieldName, wrapper.mapOfRecordIdWithUserIdsNAccessLevel.get(recordId).get(userOrGroupId));
                               shareRecord.put('RowCause', wrapper.rowCause);
                               lstObjects.add(shareRecord);
                           }
                       }
                   }
               }
        }
        return lstObjects;
    }
    
    public static String getSharingObjectName(String objectAPIName) {
        String sharingObjectName;
        if(String.isNotBlank(objectAPIName)){
            if(objectAPIName.toLowerCase().contains('__c')){
                sharingObjectName = objectAPIName.replace('__c', '__Share');
            }else{
                sharingObjectName = objectAPIName+'Share';
            }
        }
        return sharingObjectName;
    }
    
    public static String getSharingRecParentFieldName(String objectAPIName) {
        String sharingObjectName;
        if(String.isNotBlank(objectAPIName)){
            if(objectAPIName.toLowerCase().contains('__c')){
                sharingObjectName = PARENTID;
            }else{
                sharingObjectName = objectAPIName+'ID';
            }
        }
        return sharingObjectName;
    }
    
    public static String getSharingRecAccessLevelFieldName(String objectAPIName) {
        String sharingObjectName;
        if(String.isNotBlank(objectAPIName)){
            if(objectAPIName.toLowerCase().contains('__c')){
                sharingObjectName = 'AccessLevel';
            }else{
                sharingObjectName = objectAPIName+'AccessLevel';
            }
        }
        return sharingObjectName;
    }
    
    Public static String getAccessLevel(Teams__c accountTeamToGrantAccess){
        //By Default READ/VIEW Access
        String accessLevel = SharingUtility.VIEW_PERMISSION;
        if(accountTeamToGrantAccess.Is_Primary__c || accountTeamToGrantAccess.Access_Level__c == SharingUtility.TEAMS_EDIT_ACCESS){
            accessLevel = SharingUtility.EDIT_PERMISSION;
        }
        return accessLevel;
    }
    
    public static Map<Id, Map<String,List<Teams__c>>> getTeamsWithAccountAndBUs(Set<Id> setOfAccountId, Set<String> setOfBUs) {
        //Map<AccId, Map<BU,List<Team Rec>>
        Map<Id, Map<String,List<Teams__c>>> mapOfAccIdWithMapOfBUAndTeamsList = new Map<Id, Map<String,List<Teams__c>>>();
        for(Teams__c team : [Select Id,Account__c,Business_Unit__c,Access_Level__c,User__c, Is_Primary__c
                             from Teams__c
                             Where Account__c =: setOfAccountId and Business_Unit__c =: setOfBUs]){
                                 if(mapOfAccIdWithMapOfBUAndTeamsList.ContainsKey(team.Account__c)){
                                     //Account already present in map
                                     if(mapOfAccIdWithMapOfBUAndTeamsList.get(team.Account__c).ContainsKey(team.Business_Unit__c)){
                                         //if BU is already present
                                         //Add the team as another list item for the same BU
                                         mapOfAccIdWithMapOfBUAndTeamsList.get(team.Account__c).get(team.Business_Unit__c).add(team);
                                     }
                                     else{
                                         //if BU is not present
                                         // Put the BU value as a new key
                                         // Value - new List with the current team record as new list item
                                         mapOfAccIdWithMapOfBUAndTeamsList.get(team.Account__c).put(team.Business_Unit__c,new List<Teams__c>{team});
                                     }
                                     
                                 }
                                 else{
                                     //Account not present in map
                                     //Put the accountId to the map as a new key.
                                     //Value-  new Map of current team's BU as Key and add the current team record as new list item in value 
                                     mapOfAccIdWithMapOfBUAndTeamsList.put(team.Account__c,new Map<String,List<Teams__c>>{team.Business_Unit__c => new List<Teams__c>{team}});
                                 }
                             }
        System.debug('mapOfAccIdWithMapOfBUAndTeamsList: '+mapOfAccIdWithMapOfBUAndTeamsList);
        return mapOfAccIdWithMapOfBUAndTeamsList;
    }  
    
    public static map<Id, Map<Id,String>> createmapOfRecordIdWithUserIdsNAccessLevel(Id recordId, ID recOwnerId ,List<Teams__C> listOfTeams, map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel) {
        //map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel = new map<Id, Map<Id,String>>();
        if(!listOfTeams.isEmpty() && recordId != null){
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            for(Teams__C team : listOfTeams){
                if( !sObjName.equalsIgnoreCase('Opportunity') || (sObjName.equalsIgnoreCase('Opportunity') && team.User__c != recOwnerId) ){
                    if(mapOfRecordIdWithUserIdsNAccessLevel.containsKey(recordId)){
                        //recordId already present in map
                        if(!mapOfRecordIdWithUserIdsNAccessLevel.get(recordId).containsKey(team.User__c)){
                            //user is not present in map then add along with the access level
                            mapOfRecordIdWithUserIdsNAccessLevel.get(recordId).put(team.User__c,SharingUtility.getAccessLevel(team));
                        }
                    }
                    else{
                        //recordId not present in map
                        //Put the record Id to the map as a new key.
                        ////Value-  new Map of user Id with the access level for the user
                        mapOfRecordIdWithUserIdsNAccessLevel.put(recordId,new map<Id,String>{team.User__c => SharingUtility.getAccessLevel(team)});
                    }
                }
            }
        }
        //System.debug('mapOfRecordIdWithUserIdsNAccessLevel: '+mapOfRecordIdWithUserIdsNAccessLevel);
        return mapOfRecordIdWithUserIdsNAccessLevel;
    }
    
    public static SharingUtility.SharingRecordCreateWrapper createSharingRecordCreateWrapper(String objectAPIName){
        SharingUtility.SharingRecordCreateWrapper wrapper = new SharingUtility.SharingRecordCreateWrapper();
        wrapper.shareObjectName = SharingUtility.getSharingObjectName(objectAPIName);
        wrapper.parentFieldName = SharingUtility.getSharingRecParentFieldName(objectAPIName);
        wrapper.accessLevelFieldName = SharingUtility.getSharingRecAccessLevelFieldName(objectAPIName);
        return wrapper;
    }
    //Pramodh Adding new method for related records restriction
    public static Map<Id,Map<Id,String>> getAccountTeamsUserBUs(set<Id> setOfNewAccountIds){
        Map<Id,Map<Id,String>> mapOfAccIdWithMapOfUserBus = new Map<Id,Map<Id,String>>();
        for(Teams__c team : [Select Id,Account__c,Business_Unit__c,Access_Level__c,User__c, Is_Primary__c
                             from Teams__c
                             Where Account__c =: setOfNewAccountIds and Access_Level__c ='Edit Access' order by Business_Unit__c]){
                                 if(mapOfAccIdWithMapOfUserBus.ContainsKey(team.Account__c)){
                                     mapOfAccIdWithMapOfUserBus.get(team.Account__c).put(team.User__c,team.Business_Unit__c);
                                 }
                                 else{
                                     mapOfAccIdWithMapOfUserBus.put(team.Account__c,new Map<Id,String>{team.User__c => team.Business_Unit__c});
                                 }
                             }
        System.debug('mapOfAccIdWithMapOfUserBus: '+mapOfAccIdWithMapOfUserBus);
        return mapOfAccIdWithMapOfUserBus;
    }
    
}