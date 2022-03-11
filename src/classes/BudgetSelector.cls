public inherited sharing class BudgetSelector {
    public static List<Budget_vs_Actuals__c> getBudgetByAccountId (String accountId, 
                                                                            String buIdentifier, 
                                                                            Date startDate, 
                                                                            Date endDate) {
        
        return [SELECT Id, Account__c, End_Date__c, Start_date__c, Is_Budget_Locked__c,
                    Approval_Status__c,
                    (SELECT Id, Budget_vs_Actuals__c, Category__c, Sub_Category__c, Sub_Category_2__c, 
                    Volume__c, Actuals__c, Total_Consumption__c FROM Budget_vs_Actual_Lines__r)
                FROM Budget_vs_Actuals__c 
                WHERE Account__c =: accountId
                AND Business_Unit__c =: buIdentifier
                AND Start_date__c =: startDate AND End_Date__c =:endDate
                LIMIT 1];
    }

    public static List<Budget_vs_Actuals__c> getBudgets (Id accountId, String buIdentifier, Set<Integer> years) {
        return [SELECT Id, Account__c, Account__r.Name, End_Date__c, Start_date__c, Is_Budget_Locked__c,
                Approval_Status__c,
                (SELECT Id, Budget_vs_Actuals__c, Category__c, Sub_Category__c, Sub_Category_2__c, 
                    Volume__c, Actuals__c, Total_Consumption__c FROM Budget_vs_Actual_Lines__r)
                FROM Budget_vs_Actuals__c 
                WHERE Account__c =: accountId
                AND Business_Unit__c =: buIdentifier
                AND CALENDAR_YEAR(Start_date__c) in: years];
    }
    
    public static List<Budget_vs_Actuals__c> getGroupBudgets (Set<Id> accountIds, String buIdentifier, Set<Integer> years) {
        return [SELECT Id, Account__c, Account__r.Name, End_Date__c, Start_date__c, Is_Budget_Locked__c,
                Approval_Status__c,
                (SELECT Id, Budget_vs_Actuals__c, Category__c, Sub_Category__c, Sub_Category_2__c, 
                    Volume__c, Actuals__c, Total_Consumption__c FROM Budget_vs_Actual_Lines__r)
                FROM Budget_vs_Actuals__c 
                WHERE Account__c in: accountIds
                AND Business_Unit__c =: buIdentifier
                AND CALENDAR_YEAR(Start_date__c) in: years];
    }

    public static List<Budget_vs_Actuals__c> getBudgetbyOpportunityDetails (Opportunity oppObj) {
        return [SELECT Id, Start_date__c, End_Date__c,
            (
                SELECT Id, Budget_vs_Actuals__c, Category__c, Sub_Category__c, 
                Sub_Category_2__c, Volume__c, Total_Consumption__c 
                FROM Budget_vs_Actual_Lines__r
            ) 
            FROM Budget_vs_Actuals__c 
            WHERE Account__c =: oppObj.AccountId 
            AND Business_Unit__c =: oppObj.Business_Unit__c
            AND ( Start_date__c <=: oppObj.CloseDate
                AND End_Date__c >=: oppObj.CloseDate)
            LIMIT 1
        ];
    }
     public static List<Budget_vs_Actuals__c> getBudgetById (String BudgetId) {
        
        return [SELECT Id, Account__c, End_Date__c, Start_date__c, Is_Budget_Locked__c,
                    Approval_Status__c,
                    (SELECT Id, Budget_vs_Actuals__c, Category__c, Sub_Category__c, Sub_Category_2__c, 
                    Volume__c, Actuals__c, Total_Consumption__c FROM Budget_vs_Actual_Lines__r)
                FROM Budget_vs_Actuals__c 
                WHERE Id =: BudgetId
                LIMIT 1];
    }
}