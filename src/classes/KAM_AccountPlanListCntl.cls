public with sharing class KAM_AccountPlanListCntl {
    //Method to fetch account plans for current account
    @AuraEnabled
    public static List<Account_Plans__c> getAccountPlans(Id accountId){
        try {
            if (String.isBlank(accountId)) {
                return null;
            }
            List<Account_Plans__c>listOfAccountPlans = new List<Account_Plans__c>();
            
            User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
            
            listOfAccountPlans=[Select Id,Name,Description__c,EndDate__c,Customer_Group__c,StartDate__c,Type__c,BU_Identifier__c,
                                Year__c,Account__c from Account_Plans__c where Account__c=:accountId order by Year__c desc]; 
            
            return listOfAccountPlans;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Method to fetch account plan teams for current account
    @AuraEnabled
    public static List<Teams__c> getAccountTeams(Id accountId){
        try {
            if (String.isBlank(accountId)) {
                return null;
            }
            User u=[Select Id,Name,Email,BU_Identifier__c from User where Id=:userinfo.getuserId()];
            List<Teams__c> listOfTeams = new List<Teams__c>();
            for(Teams__c acctTeams:[Select id,Name,Account__c,Is_Primary__c,User__c from Teams__c where Account__c=:accountId AND Is_Primary__c=True]){
                if(acctTeams.User__c == u.Id){
                    listOfTeams.add(acctTeams);
                }
            }
            return listOfTeams;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Method to Fetch current loggedIn user BU
    @AuraEnabled
    public static User getUserBU(){
        User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
        return u;
    }
    
     @AuraEnabled
    public static boolean getCustomPermission()
    {
       /*Boolean hasCustomPermission = FeatureManagement.checkPermission('<custom_permission_api_name>');
        system.debug('Permission'+hasCustomPermission);
        return hasCustomPermission;*/
        Boolean accessBool;  
		Set < Id > permissionSetIds = new Set < Id >();  
		List < User > userList = new List < User >();  
		for ( SetupEntityAccess access : [ SELECT ParentId FROM SetupEntityAccess   
                                   WHERE SetupEntityId IN ( SELECT Id   
                                                            FROM CustomPermission   
                                                            WHERE DeveloperName = 'CanDeleteAccountPLan' )  
											] )   
    			permissionSetIds.add(access.ParentId);  
				userList = [ SELECT Username FROM User WHERE Id IN (  
       		  SELECT AssigneeId FROM PermissionSetAssignment  
              WHERE PermissionSetId IN :permissionSetIds AND AssigneeId =:userinfo.getuserId() ) ];  
              accessBool = userList.isEmpty() ? false : true;  
        		system.debug('Permission---->'+accessBool);
              return accessBool;

        
        
    }  
    
     @AuraEnabled
    public static void deleteAccountPlan(Id AcctPlanId){
  
        Account_Plans__c AccountPlan=[Select Id,Name,Description__c,EndDate__c,Customer_Group__c,StartDate__c,Type__c,BU_Identifier__c,
                                Year__c,Account__c from Account_Plans__c where Id=:AcctPlanId]; 
        System.debug('AcctPlan-->>'+AccountPlan);
        delete AccountPlan;
    }
    
    
    
    
}