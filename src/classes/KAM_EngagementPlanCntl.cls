public without sharing class KAM_EngagementPlanCntl implements KAM_AccountPlan{
    
    public String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getEngagementPlans ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class) ));
        }
        return null;
    }
    
    public static List<Engagement_Plan__c> getEngagementPlans (Account_Plans__c accountPlan) {
        return EngagementPlanSelector.getEngangementPlansByAccountId (
            accountPlan.Account__c, 
            accountPlan.BU_Identifier__c,
            accountPlan.StartDate__c,
            accountPlan.EndDate__c
        );
    }
    
    @AuraEnabled (cacheable=true)
    public static List<KAM_Util.PicklistEntry> getEngangementPickListValuesByField (String objectName, String fieldName, Boolean discardInactive, Boolean shouldIncludeNone){
        try {
            return KAM_Util.getPickListValues(objectName, fieldName, discardInactive, shouldIncludeNone);
            // return KAM_Util.getPickListValues('Engagement_Plan__c', 'Type_of_engagement__c', true, false);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled (cacheable=true)
    public static List<Frequency_Mapping__mdt> getActiveFrequencyMapping () {
        return [SELECT Id, DeveloperName, MasterLabel, Value__c, Value_Type__c 
                FROM Frequency_Mapping__mdt
                WHERE Is_Active__c = true
                LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
    }
    
    @AuraEnabled
    public static Boolean isLocked(String recordId){
        return Approval.isLocked(recordId);
    }
    
    @AuraEnabled
    public static string refreshEngagementPlan(Account_Plans__c accountPlan){
        try {
            return JSON.serialize(getEngagementPlans (accountPlan) );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String riseRequestForEngagementPlanEdit (String engagementPlanStr) {
        Savepoint sp = Database.setSavepoint ();
        Map<String, Object> resultMap = new Map<String, Object> ();
        try {
            Engagement_Plan__c engagementPlan = (Engagement_Plan__c) JSON.deserialize (engagementPlanStr, Engagement_Plan__c.class);
            
            if (isLocked (engagementPlan.Id)) {
                resultMap.put('success', false);
                resultMap.put('message', Label.KAM_Plan_Approval_Waiting_Message);
                
                return JSON.serialize(resultMap);
            }
            
            engagementPlan.Approval_Status__c = EngagementPlanConstants.APPROVAL_STATUS_REQUEST_FOR_EDIT;
            
            update engagementPlan;
            resultMap.put('engagementPlan', EngagementPlanSelector.getEngangementPlansBytId(engagementPlan.Id)[0]);
            
            resultMap.put('success', true);
        } catch (DmlException ex) {
            Database.rollback(sp);
            resultMap.put('success', false);
            resultMap.put('message', ex.getMessage());
            if (ex.getMessage().containsIgnoreCase('This approval request requires the next approver to be determined by the Manager field')) {
                resultMap.put('message', Label.KAM_Approval_Request_Manager_Unassigned_Error_Message);
            }
        }
        catch (Exception ex) {
            Database.rollback(sp);
            resultMap.put('success', false);
            resultMap.put('message', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }
    
    @AuraEnabled
    public static String createEngagementPlans (String engagementPlanLineStr, String engagementPlanStr)
    {
        List<Engagement_Plan_Line__c> engagementLines = (List<Engagement_Plan_Line__c>) JSON.deserialize (engagementPlanLineStr, List<Engagement_Plan_Line__c>.class);
        Engagement_Plan__c engagementPlan = (Engagement_Plan__c) JSON.deserialize (engagementPlanStr, Engagement_Plan__c.class);
        Map<String, Object> resultMap = new Map<String, Object> ();
        
        Savepoint sp = Database.setSavepoint ();
        try {
            if (engagementPlan.Id == null) {
                insert engagementPlan;
            } else {
                update engagementPlan;
            }
            
            for (Engagement_Plan_Line__c line : engagementLines) {
                if (String.isBlank(line.Engagement_Plan__c)) {
                    line.Engagement_Plan__c = engagementPlan.Id;
                }
            }
            
            upsert engagementLines;
            
            resultMap.put('engagementLines', engagementLines);
            resultMap.put('engagementPlan', engagementPlan);
            
            resultMap.put('success', true);
        } catch (Exception ex) {
            Database.rollback(sp);
            resultMap.put('success', false);
            resultMap.put('message', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }
    /**
* Reference : https://github.com/pozil/sfdc-ui-lookup-lwc/
*/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed() {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'User'
            ORDER BY LastViewedDate DESC
            LIMIT :Integer.valueOf (Label.KAM_Lookup_Min_Record_Limit)
        ];
        // Convert recent records into LookupSearchResult
        for (RecentlyViewed recentRecord : recentRecords) {
            if (recentRecord.Type == 'User') {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'User',
                        'standard:user',
                        recentRecord.Name,
                        'User • ' + recentRecord.Name
                    )
                );
            }
        }
        return results;
    }
    
    /**
* Reference : https://github.com/pozil/sfdc-ui-lookup-lwc/
*/
    private final static Integer MAX_RESULTS = 5;
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';
        
        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
            User(Id, Name, Email WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];
        
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        // Extract users & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User eachUser : users) {
            String subtitle = eachUser.Email == null ? 'User' : 'User • ' + eachUser.Email;
            results.add(new LookupSearchResult(eachUser.Id, 'User', userIcon, eachUser.Name, subtitle));
        }
        
        // Optionnaly sort all results on title
        results.sort();
        
        return results;
    }
    
    
    @AuraEnabled
    public static List<Engagement_Plan__c> getEngagementPlansByAccountId(Id AccountId) {
        User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
        Teams__c currentUserTeam = KAM_EngagementPlanCntl.getcurrentUserAccountTeam(AccountId);
        //String BU=u.BU_Identifier__c;
        string BU = currentUserTeam.Business_Unit__c;
        if(BU==Null)
        {
            return NULL;
        } 
        else
        {   
        List<Engagement_Plan__c> engList=[Select Id,Name,Account__c,Business_Unit__c,
                                          Start_date__c,End_Date__c,Year__c	 From Engagement_Plan__c 
                                          where Account__c=:AccountId AND Business_Unit__c=:BU];
        
        return engList;
        
        }
    }
    @AuraEnabled
    public static String getEngagementPlansById(Id engagementId) {
        
        return json.serialize(EngagementPlanSelector.getEngangementPlansBytId(engagementId));       
        
    }
    
    @AuraEnabled
    public static Engagement_Plan__c createEngagementPlan(String selYear,String accountId,String businessUnit) {
        System.debug('year'+selYear);
        //User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
        Engagement_Plan__c engPlan = new Engagement_Plan__c();
        //engPlan.Name=u.BU_Identifier__c+'-'+selYear;
        engPlan.Name = businessUnit+'-'+selYear;
        engPlan.Account__c = accountId;
        //engPlan.Business_Unit__c = u.BU_Identifier__c;
        engPlan.Business_Unit__c = businessUnit;
        engPlan.Year__c=selYear;
        engPlan.Start_date__c = date.parse('01/01/'+selYear);
        engPlan.End_Date__c = date.parse('31/12/'+selYear);
        try{   
            System.debug('EngagementPlan'+engPlan);
            insert engPlan;
            return engPlan;
        }
        catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
    @AuraEnabled
    public static User getUserBU(){
        User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
        return u;
    }
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
    
    @AuraEnabled
    public static Teams__c getcurrentUserAccountTeam(Id accountId){
        Teams__c currentUserAccountTeam = new Teams__c();
        List<Teams__c> listOfTeams = new List<Teams__c>();
        listOfTeams = [select Id,Business_Unit__c,User__c,Account__c from Teams__c where User__c =: userinfo.getuserId() and Account__c =: accountId limit 1];
        if(!listOfTeams.isEmpty()){
            currentUserAccountTeam = listOfTeams[0];
        }
        return currentUserAccountTeam;
    }
}