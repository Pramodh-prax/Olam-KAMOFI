public without sharing class KAM_BudgetActualsGrpCntl implements KAM_AccountPlan{
    public String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getAccountsAndPlansByCustomerGroup (
            (Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class) ));
        }
        return null;
    }

    
    public List<Account> getAccountsAndPlansByCustomerGroup (Account_Plans__c accountPlan) {
        if (accountPlan == null || String.isBlank(accountPlan.Customer_Group__c)) {
            NullPointerException e = new NullPointerException ();
            e.setMessage(Label.KAM_Invalid_Account_Plan_Detail_Error_Message);
            throw e;
        }
        
        try {
            
            
            return [
                SELECT Id, Name, 
                    (SELECT Id,Name, Description__c, EndDate__c, StartDate__c, Type__c, BU_Identifier__c,
                        Year__c,Account__c from Account_Plans__r 
                        WHERE StartDate__c =: accountPlan.StartDate__c
                        AND EndDate__c =: accountPlan.EndDate__c
                        AND BU_Identifier__c =: accountPlan.BU_Identifier__c
                    )  FROM Account
                WHERE Customer_Group__c =: accountPlan.Customer_Group__c
                LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled(cacheable=true)
    public static List<Budget_vs_Actuals__c> getOverAllBudgets(String accountPlanStr, String yearsStr){
        return KAM_BudgetActualsCntl.getOverAllBudgets (accountPlanStr, yearsStr);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Budget_vs_Actuals__c> getGroupOverAllBudgets(String accIdStr, String accountPlanStr, String yearsStr){
        try {
            Account_Plans__c accountPlan = (Account_Plans__c)JSON.deserialize (accountPlanStr, Account_Plans__c.class);
            List<Integer> years = (List<Integer>) JSON.deserialize(yearsStr, List<Integer>.class);
            return BudgetSelector.getGroupBudgets ((Set<Id>) JSON.deserialize(accIdStr, Set<Id>.class), accountPlan.BU_Identifier__c, new Set<Integer> (years));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}