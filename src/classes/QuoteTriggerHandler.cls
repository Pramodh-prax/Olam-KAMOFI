public class QuoteTriggerHandler {
	
    public static void afterInsert(List<Quote> quoList)
    {
        Map<Id, Id> quoteMap = new Map<Id, Id>();
        Set<Id> oppIdSet = new Set<Id>();
    	for(Quote currentQuote : quoList){
        	quoteMap.put(currentQuote.Id, currentQuote.OpportunityId);
            oppIdSet.add(currentQuote.OpportunityId);
    	} 
        Quote q = QuoteTriggerHelper.updateVersion(quoList);
        
        Map<Id, Opportunity> oppMap = QuoteTriggerHelper.getOpportunityMap(oppIdSet);
        
        if(oppMap.get(q.OpportunityId).RecordType.Name == 'Gain Opportunity')
        {
			QuoteAutoSyncUtil.syncQuote(quoteMap);
        }
    }
}