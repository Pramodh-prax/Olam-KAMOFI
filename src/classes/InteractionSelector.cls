public with sharing class InteractionSelector {
    
    public static List<Interactions__c> getInteractionsByAccountIds (Set<Id> accountIds, Set<String> bUs) {
        if (accountIds.contains(null)) {
            accountIds.remove(null);
        }
        return [SELECT Id, Business_Unit__c, Account__c 
                FROM Interactions__c 
                WHERE Account__c in: accountIds
                AND Business_Unit__c in: bUs];
    }
    
    public static List<Interactions__c> getInteractionsByIds (Set<Id> interactionIds) {
        if (interactionIds.contains(null)) {
            interactionIds.remove(null);
        }
        return [SELECT Id, Account__c, Business_Unit__c 
                FROM Interactions__c WHERE Id in : interactionIds];
    }
}