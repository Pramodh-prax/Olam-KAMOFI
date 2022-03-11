public without sharing class KAM_EngagementPlanGrpCntl implements KAM_AccountPlan{
    public String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getAccountsAndPlansByCustomerGroup ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class) ));
        }
        return null;
    }
    @AuraEnabled
    public static String getGroupDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getGroupEngagementPlanLineItems ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class)));
        }
        return null;
    }
    
    public List<Account> getAccountsAndPlansByCustomerGroup (Account_Plans__c accountPlan) {
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
    @AuraEnabled
    public static List<Engagement_Plan__c>  getEngagementPlans (String accountPlanStr) {
        Account_Plans__c accountPlan = (Account_Plans__c) JSON.deserialize (accountPlanStr, Account_Plans__c.class);
        return EngagementPlanSelector.getEngangementPlansByAccountId (
            accountPlan.Account__c, 
            accountPlan.BU_Identifier__c,
            accountPlan.StartDate__c,
            accountPlan.EndDate__c
        );
    }
    @AuraEnabled
    public static List<AggregateResult>  getGroupEngagementPlanLineItems (Account_Plans__c accountPlan) {
        try {
            if (accountPlan == null || String.isBlank(accountPlan.Customer_Group__c)) {
                NullPointerException e = new NullPointerException ();
                e.setMessage(Label.KAM_Invalid_Account_Plan_Detail_Error_Message);
                throw e;
            }
            Set<Id>engPlanIds = new Set<Id>();
            for(Engagement_Plan__c eng:[SELECT Id, Account__c,Account__r.Customer_Group__c from Engagement_Plan__c where Account__r.Customer_Group__c=:accountPlan.Customer_Group__c
                                        AND Business_Unit__c=:accountPlan.BU_Identifier__c AND Start_date__c=:accountPlan.StartDate__c AND End_Date__c=:accountPlan.EndDate__c]){
                                            engPlanIds.add(eng.Id);
                                            
                                        }
            if(engPlanIds.size()>0){
                AggregateResult[] groupedResults=[Select SUM(Actuals__c)actuals,SUM(Planned__c)planned,Type_of_Engagement__c from Engagement_Plan_Line__c where Engagement_Plan__c IN:engPlanIds  GROUP BY Type_of_Engagement__c];
                return groupedResults;
            }else{
                return null;
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}