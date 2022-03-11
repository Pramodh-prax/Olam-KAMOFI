public class KAM_AccountTeamsCntl implements KAM_AccountPlan{
    public static String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountId')) {
            return JSON.serialize(getAccountTeams (String.valueOf(requestMap.get('accountId'))));
        }
        return null;
    }
    @AuraEnabled
    public static String getGroupDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getAccounts ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class)));
        }
        return null;
    }
    @AuraEnabled
    public static List<AccountTeamsWrapper> getAccountTeams(Id accountId){
        try {
            if (String.isBlank(accountId)) {
                return null;
            }
            List<AccountTeamsWrapper>listOfAccountTeams = new List<AccountTeamsWrapper>();
            for(Teams__c ts: [Select id,Name,Account__c, Account__r.Name, Is_Primary__c,User__c,User__r.BU_Identifier__c,User__r.Name,User_Role_Name__c from Teams__c where Account__c=:accountId ]){
                AccountTeamsWrapper atw = new AccountTeamsWrapper();
                atw.UserName = ts.User__r.Name;
                atw.Role = ts.User_Role_Name__c;
                atw.Primary = ts.Is_Primary__c;
                atw.BusinessUnit = ts.User__r.BU_Identifier__c;
                atw.Id = ts.Id;
                atw.accountId = ts.Account__c;
                atw.accountName = ts.Account__r.Name;

                listOfAccountTeams.add(atw);
            }
            return listOfAccountTeams;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }  
    }
    @AuraEnabled
    public static List<AccountTeamsWrapper> getAccountTeamsForGroup(Id accountId){
        try {
            if (String.isBlank(accountId)) {
                return null;
            }
            List<AccountTeamsWrapper>listOfAccountTeams = new List<AccountTeamsWrapper>();
            for(Teams__c ts: [Select id,Name,Account__c, Account__r.Name, Is_Primary__c,User__c,User__r.BU_Identifier__c,User__r.Name,User_Role_Name__c from Teams__c where Account__c=:accountId AND Is_Primary__c=true]){
                AccountTeamsWrapper atw = new AccountTeamsWrapper();
                atw.UserName = ts.User__r.Name;
                atw.Role = ts.User_Role_Name__c;
                atw.Primary = ts.Is_Primary__c;
                atw.BusinessUnit = ts.User__r.BU_Identifier__c;
                atw.Id = ts.Id;
                atw.accountId = ts.Account__c;
                atw.accountName = ts.Account__r.Name;

                listOfAccountTeams.add(atw);
            }
            return listOfAccountTeams;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }  
    }
    public static List<Account> getAccounts(Account_Plans__c accountPlan){
        if (accountPlan == null || String.isBlank(accountPlan.Customer_Group__c)) {
            NullPointerException e = new NullPointerException ();
            e.setMessage(Label.KAM_Invalid_Account_Plan_Detail_Error_Message);
            throw e;
        }
        return AccountSelector.getAccountsByCustomerGroupforoverview(accountPlan.Customer_Group__c,accountPlan.BU_Identifier__c);
    }
    
    
    public class AccountTeamsWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String UserName;
        @AuraEnabled
        public String Role;
        @AuraEnabled
        public Boolean Primary;
        @AuraEnabled
        public String BusinessUnit;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String accountName;
    }
}