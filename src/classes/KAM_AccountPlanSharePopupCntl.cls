public class KAM_AccountPlanSharePopupCntl {
    //Method to Fetch picklist values
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        List<String> optionlist = new List<String>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();       
        
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }
    //Method to fetch account plan share for current account plan
    @AuraEnabled
    public static List<AccountPlanShareWrapper> getAccountPlanShare(Id accountPlanId){
        try {
            if (String.isBlank(accountPlanId)) {
                return null;
            }
        Map<Id,User>mapOfUsers = new Map<Id,User>();
        List<AccountPlanShareWrapper>listOfAps = new List<AccountPlanShareWrapper>();
        for(User u:[Select Id,Name,BU_Identifier__c from User])
        {
            mapOfUsers.put(u.Id,u);
        }
        List<Account_Plans__Share> listOfaccountPlanShare = [Select Id,AccessLevel,UserOrGroupId,ParentId,UserOrGroup.Name,RowCause  from Account_Plans__Share where ParentId=:accountPlanId];
        for(Account_Plans__Share aps:listOfaccountPlanShare){
            AccountPlanShareWrapper aws = new AccountPlanShareWrapper();
            aws.AccessLevel = aps.AccessLevel;
            aws.UserName = aps.UserOrGroup.Name;
            aws.ShareReason = aps.RowCause;
            aws.BusinessUnit = mapOfUsers.get(aps.UserOrGroupId).BU_Identifier__c;
            aws.UserOrGroupId = aps.UserOrGroupId;
            aws.Id = aps.Id;
            listOfAps.add(aws);   
        }
        System.debug('listOfaccountPlanShare'+listOfAps);
        return listOfAps;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Method to search users for sharing account plan
    @AuraEnabled
    public static List < User > fetchUser(Id accountId,String searchKeyWord,List<Account_Plans__Share>listOfAccountPlanShare) {
        Set<Id>teamUserIds = new Set<Id>();
        Set<Id>userIds = new Set<Id>();
        for(Teams__c acctTeams:[Select id,Name,Account__c,Is_Primary__c,User__c from Teams__c where Account__c=:accountId]){
            teamUserIds.add(acctTeams.User__c);
        }
        for(Account_Plans__Share aps:listOfAccountPlanShare){
            userIds.add(aps.UserOrGroupId);
        }
        String searchKey = searchKeyWord + '%';
        List < User > returnList = new List < User > ();
        List < User > listOfUser = [select id, Name from User where Name LIKE: searchKey AND Id NOT IN:userIds AND Id IN:teamUserIds];
        
        for (User us: listOfUser) {
            returnList.add(us);
        }
        return returnList;
    }
    
    //Method to create new Account plan share  
    @AuraEnabled
    public static Account_Plans__Share saveAccountPlanShare(Id AccounPlanId,Id UserId,String UserName,Id AccountId){
        Account acc = [Select Id,Name from Account where Id=:AccountId];
        Account_Plans__c AcctPlan = [Select Id,Name from Account_Plans__c where Id=:AccounPlanId];
        Account_Plans__Share app = new Account_Plans__Share();
        app.AccessLevel = 'Read';
        app.UserOrGroupId = UserId;
        app.ParentId = AccounPlanId;
        app.RowCause = Schema.Account_Plans__Share.RowCause.Manual;
        System.debug('listOfAccountPlan'+app);
        insert app;
        KAM_NotifyUserAccess.notifyUserAccess(acc, AcctPlan, app, UserName, UserId);
        return app;
    } 
    //Method to remove user from Account Plan
    @AuraEnabled
    public static void removeAccessAccountPlanShare(Id AcctPlanshareId){
        Account_Plans__Share acctPlanshare = [Select Id,ParentId from Account_Plans__Share where Id=:AcctPlanshareId];
        
        System.debug('AcctPlanshare-->>'+acctPlanshare);
        delete acctPlanshare;
    }
    
    public class AccountPlanShareWrapper{
         @AuraEnabled
        public String Id;
        @AuraEnabled
        public String UserOrGroupId;
        @AuraEnabled
        public String AccessLevel;
        @AuraEnabled
        public String UserName;
        @AuraEnabled
        public String ShareReason;
        @AuraEnabled
        public String BusinessUnit;
    }
}