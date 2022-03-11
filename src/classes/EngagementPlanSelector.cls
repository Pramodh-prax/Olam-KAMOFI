public Inherited sharing class EngagementPlanSelector {
    
    public static List<Engagement_Plan__c> getEngangementPlansByAccountId (String accountId, 
                                                                            String buIdentifier, 
                                                                            Date startDate, 
                                                                            Date endDate) {
        
        return [SELECT Id, Account__c, End_Date__c, Start_date__c, Is_Engagement_Plan_Locked__c,
                    Approval_Status__c,
                    (SELECT Id, Actuals__c, Attendee__c, Engagement_Plan__c, Description__c, 
                    Frequency__c, Last_Engagement_Date__c, Planned__c, Type_of_Engagement__c 
                    FROM Engagement_Plan_Lines__r)
                FROM Engagement_Plan__c 
                WHERE Account__c =: accountId
                AND Business_Unit__c =: buIdentifier
                AND Start_date__c =: startDate AND End_Date__c =:endDate
                LIMIT 1];
    }

    public static List<Engagement_Plan__c> getEngagementPlanByInteractionDetail (Interactions__c eachInteraction, Set<String> interactionType) {
        return [SELECT Id, Account__c, Business_Unit__c, End_Date__c, Start_date__c,
                (
                    SELECT Id, Actuals__c, Last_Engagement_Date__c, Type_of_Engagement__c 
                    FROM Engagement_Plan_Lines__r
                    WHERE Type_of_Engagement__c in: interactionType
                )
                FROM Engagement_Plan__c 
                WHERE Account__c =: eachInteraction.Account__c
                AND (Start_date__c <= Today AND End_Date__c >= Today)
                AND Business_Unit__c =: eachInteraction.Business_Unit__c
                LIMIT 1
        ];
    }
      public static List<Engagement_Plan__c> getEngangementPlansBytId (String EngagementPlanId) {
        
        return [SELECT Id, Account__c, End_Date__c, Start_date__c, Is_Engagement_Plan_Locked__c,
                    Approval_Status__c,Year__c,
                    (SELECT Id, Actuals__c, Attendee__c, Engagement_Plan__c, Description__c, 
                    Frequency__c, Last_Engagement_Date__c, Planned__c, Type_of_Engagement__c 
                    FROM Engagement_Plan_Lines__r)
                FROM Engagement_Plan__c 
                WHERE Id =: EngagementPlanId
                LIMIT 1];
    }
}