public class ConsumptionOpportunityLinkService {
    
    @future
    public static void findAndUpdateConsumptionAndBrandAsync(Set<Id> oppLineIdSet){
    	findAndUpdateConsumptionAndBrand(oppLineIdSet);
    }
    
    
    public static void findAndUpdateConsumptionAndBrand(Set<Id> oppLineIdSet){
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        oppLines = getOppLines(oppLineIdSet);
        
        Set<String> combinationKeySet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        
        for(OpportunityLineItem oppLine :oppLines){
        	combinationKeySet.add(oppLine.Combination_Key__c);
			accountIdSet.add(oppLine.Opportunity.AccountId);            
        }
        
        Map<String, List<OpportunityLineItem>> oppLineMap = new Map<String, List<OpportunityLineItem>>();
        oppLineMap = getOppLineMap(oppLines);
        
        Map<String, List<Consumption__c>> consumptionMap = new Map<String, List<Consumption__c>>();
        consumptionMap = getConsumptionMap(accountIdSet, combinationKeySet);
        
        
        List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
        for(OpportunityLineItem oppLine :oppLines){
            if(consumptionMap.containsKey(oppLine.Opportunity.AccountId)){
                for(Consumption__c consumption :consumptionMap.get(oppLine.Opportunity.AccountId)){
                    if(
                        oppLine.Combination_Key__c == consumption.Combination_Key__c && 
                        (
                            oppLine.Opportunity.Application__c == consumption.Application__c ||
                            (oppLine.Opportunity.Application__c != null && oppLine.Opportunity.Application__c != '' && oppLine.Opportunity.Application__c.contains(consumption.Application__c)) 
                        )
                        
                    ){
                        oppLine.Consumption__c = consumption.Id;
                        
                        if(oppLine.Product2.Brand__c != null && consumption.Brands_n_competitors__r != null){
                            for(Brand_n_Comp__c brand :consumption.Brands_n_competitors__r){
                                if(oppLine.Product2.Brand__c.equalsIgnoreCase(brand.Brand__c)){
                                    oppLine.Consumption_Brand__c = brand.Id;
                                }
                            }
                        }
                    }
                }
                oppLinesToUpdate.add(oppLine);
            }
        }
        
        if(oppLinesToUpdate.size() > 0){
            update oppLinesToUpdate;
        }
    }
    
    
    public static Map<String, List<Consumption__c>> getConsumptionMap(Set<Id> accountIdSet, Set<String> combinationKeySet){
        Map<String, List<Consumption__c>> consumptionMap = new Map<String, List<Consumption__c>>();
        
        for(Consumption__c consumption :getConsumptionList(accountIdSet, combinationKeySet)){
            if(consumptionMap.containsKey(consumption.Account__c)){
                consumptionMap.get(consumption.Account__c).add(consumption);
            }
            else{
                consumptionMap.put(consumption.Account__c, new List<Consumption__c>{consumption});
            }
        }
        
        return consumptionMap;
    }
    
    
    public static List<Consumption__c> getConsumptionList(Set<Id> accountIdSet, Set<String> combinationKeySet){
    	List<Consumption__c> consumptionList = new List<Consumption__c>();
        
        consumptionList = [SELECT Id, Account__c, Combination_Key__c, Application__c, 
                           (SELECT Brand__c FROM Brands_n_competitors__r WHERE Brand_type__c = 'Internal') 
                          FROM Consumption__c 
                          WHERE Account__c IN :accountIdSet
                          AND Combination_Key__c IN :combinationKeySet];
        
        return consumptionList;
    }
    
    
    public static Map<String, List<OpportunityLineItem>> getOppLineMap(List<OpportunityLineItem> oppLines){
        Map<String, List<OpportunityLineItem>> oppLineMap = new Map<String, List<OpportunityLineItem>>();
        
        for(OpportunityLineItem oppLine :oppLines){
            if(oppLineMap.containsKey(oppLine.Opportunity.AccountId)){
                oppLineMap.get(oppLine.Opportunity.AccountId).add(oppLine);
            }
            else{
                oppLineMap.put(oppLine.Opportunity.AccountId, new List<OpportunityLineItem>{oppLine});
            }
        }
        
        return oppLineMap;
    }
    
    public static List<OpportunityLineItem> getOppLines(Set<Id> oppLineIdSet){
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        
        oppLines = [SELECT Id, Opportunity.AccountId, Opportunity.Application__c, Combination_Key__c, Product2.Brand__c FROM OpportunityLineItem WHERE Id IN :oppLineIdSet];
        
        return oppLines;
    }
}