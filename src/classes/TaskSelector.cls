public with sharing class TaskSelector {

    public static List<AggregateResult> getTaksByInteractionAndDate (Id eachInteractionId, Set<String> interactionType, Date startDate, Date endDate) {
        return [SELECT Count(Id) totalInteractions, Interaction_Type__c 
            FROM Task Where WhatId =: eachInteractionId 
            AND Status = :TaskConstants.STATUS_COMPLETED
            AND (Completed_Date__c >=: startDate AND Completed_Date__c <=: endDate)
            AND Interaction_Type__c in: interactionType
            GROUP BY Interaction_Type__c 
        ];
    }
}