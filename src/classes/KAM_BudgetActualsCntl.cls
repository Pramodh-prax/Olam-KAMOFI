public without sharing class KAM_BudgetActualsCntl implements KAM_AccountPlan{
    public String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getCurrentBudgetByPlan ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class) ));
        }
        return null;
    }

    @AuraEnabled
    public static List<Budget_vs_Actuals__c> getCurrentBudgetByPlan(Account_Plans__c accountPlan){
        try {
            
            return BudgetSelector.getBudgetByAccountId (accountPlan.Account__c, 
                                                accountPlan.BU_Identifier__c,
                                                accountPlan.StartDate__c,
                                                accountPlan.EndDate__c);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String refreshBudgetPlan(String accountPlanStr){
        try {
            Account_Plans__c accountPlan = (Account_Plans__c) JSON.deserialize(accountPlanStr, Account_Plans__c.class);
            return JSON.serialize (getCurrentBudgetByPlan (accountPlan));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Budget_vs_Actuals__c> refreshOverAllBudget (String accountPlanStr, String yearsStr){
        try {            
            return getOverAllBudgets (accountPlanStr, yearsStr);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean isLocked(String recordId){
        return Approval.isLocked(recordId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Budget_vs_Actuals__c> getOverAllBudgets(String accountPlanStr, String yearsStr){
        try {
            Account_Plans__c accountPlan = (Account_Plans__c)JSON.deserialize (accountPlanStr, Account_Plans__c.class);
            List<Integer> years = (List<Integer>) JSON.deserialize(yearsStr, List<Integer>.class);
            return BudgetSelector.getBudgets (accountPlan.Account__c, accountPlan.BU_Identifier__c, new Set<Integer> (years));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String riseRequestForBudgetEdit (String budgetStr) {
        Map<String, Object> resultMap = new Map<String, Object> ();

        Budget_vs_Actuals__c budget = (Budget_vs_Actuals__c) JSON.deserialize (budgetStr, Budget_vs_Actuals__c.class);
        budget.Approval_Status__c = BudgetActualsConstants.APPROVAL_STATUS_REQUEST_FOR_EDIT;

        if (isLocked (budget.Id)) {
            resultMap.put('success', false);
            resultMap.put('message', Label.KAM_Plan_Approval_Waiting_Message);

            return JSON.serialize(resultMap);
        }

        Savepoint sp = Database.setSavepoint ();
        try {
            update budget;
            resultMap.put('budget', BudgetSelector.getBudgetById(budget.Id)[0]); 
            //resultMap.put('budget', budget);

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
    public static String createBudget (String budgetStr, String budgetLineStr)
    {
        List<Budget_vs_Actual_Line__c> budgetLines = (List<Budget_vs_Actual_Line__c>) JSON.deserialize (budgetLineStr, List<Budget_vs_Actual_Line__c>.class);
        Budget_vs_Actuals__c budget = (Budget_vs_Actuals__c) JSON.deserialize (budgetStr, Budget_vs_Actuals__c.class);
        Map<String, Object> resultMap = new Map<String, Object> ();

        Savepoint sp = Database.setSavepoint ();
        try {
            if (budget.Id == null) {
                insert budget;
            } else {
                update budget;
            }
            
            for (Budget_vs_Actual_Line__c line : budgetLines) {
                if (String.isBlank(line.Budget_vs_Actuals__c)) {
                    line.Budget_vs_Actuals__c = budget.Id;
                }
            }

            upsert budgetLines;

            resultMap.put('budgetLines', budgetLines);
            resultMap.put('budget', budget);

            resultMap.put('success', true);
        } catch (Exception ex) {
            Database.rollback(sp);
            resultMap.put('success', false);
            resultMap.put('message', ex.getMessage());
        }
        return JSON.serialize(resultMap);
    }   
    @AuraEnabled
    public static List<Budget_vs_Actuals__c> getBudgetvsActuals(Id accountId){
        
        User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
        Teams__c currentUserTeam = KAM_EngagementPlanCntl.getcurrentUserAccountTeam(AccountId);
        //String BU=u.BU_Identifier__c;
        string BU = currentUserTeam.Business_Unit__c;
        if(BU==Null)
        {
            return Null;
        } 
        else
        {    
        List<Budget_vs_Actuals__c> budactualList = [Select Id,Name,Account__r.Name,Year__C,Business_Unit__c from Budget_vs_Actuals__c where Account__c=:accountId AND Business_Unit__c=:BU];
        
        return budactualList;
        }
    }
    @AuraEnabled
    public static String getBudgetActualsById(String BudgetActualId) {
        
      return json.serialize(BudgetSelector.getBudgetById(BudgetActualId));       
        
    }
   
    @AuraEnabled (cacheable=true)
    public static List<KAM_Util.PicklistEntry> getBudgetPickListValuesByField (String objectName, String fieldName, Boolean discardInactive, Boolean shouldIncludeNone){
        try {
            //Eg: return KAM_Util.getPickListValues('Engagement_Plan__c', 'Type_of_engagement__c', true, false);
            return KAM_Util.getPickListValues(objectName, fieldName, discardInactive, shouldIncludeNone);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Budget_vs_Actuals__c createBudgetvsActuals(String selYear,String accountId, String businessUnit) {
       System.debug('year'+selYear);
        //User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
        Budget_vs_Actuals__c budvAct = new Budget_vs_Actuals__c();
       
        //budvAct.Name=u.BU_Identifier__c+'-'+selYear;
        budvAct.Name = businessUnit+'-'+selYear;
        budvAct.Account__c = accountId;
        //budvAct.Business_Unit__c = u.BU_Identifier__c;
        budvAct.Business_Unit__c = businessUnit;
        budvAct.Year__c=selYear;
        budvAct.Start_date__c = date.parse('01/01/'+selYear);
        budvAct.End_Date__c = date.parse('31/12/'+selYear);
        try{   
              System.debug('BusinessVsActual'+budvAct);
              insert budvAct;
              return budvAct;
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
                    System.debug('Account teams'+acctTeams);
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

// @AuraEnabled (cacheable=true)
// public static String getDependentPickList (sObject objDetail, 
//                                             string contrfieldApiName,
//                                             string depfieldApiName,
//                                             Boolean discardInactiveValue) {
//     return JSON.serialize(DependentPickListUtil.getDependentMap(objDetail, 
//                                                                 contrfieldApiName, 
//                                                                 depfieldApiName, 
//                                                                 discardInactiveValue));

// }