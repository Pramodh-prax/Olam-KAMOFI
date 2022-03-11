public class QuoteTriggerHelper {
    
    public static Quote updateVersion(List<Quote> quoList)
    {
        
        Quote q = new Quote();
        if(!quoList.isEmpty())
        {
            
            Map<String,Quote> mapOfOppIdVsQuote = new Map<String,Quote>();
            for(Quote Quo : quoList){
                mapOfOppIdVsQuote.put(quo.OpportunityId,quo);
            }
            
            if(!mapOfOppIdVsQuote.isEmpty())
            {
                AggregateResult [] quoteList = [Select Opportunityid,MAX(version__c) version from Quote where Opportunityid IN :mapOfOppIdVsQuote.keySet() group by Opportunityid];
                Integer highestVersion = Integer.valueOf(quoteList[0].get('version'));
                Id oppId = String.valueOf(quoteList[0].get('Opportunityid'));
                Id quoId = mapOfOppIdVsQuote.get(oppId).id;
                
                
                q.Id = quoId;
                q.OpportunityId = oppId;
                q.Version__c = highestVersion + 1;
                
                update q;
                
            }
        }
        
        return q;
    }
    
    
    public Static Map<Id, Opportunity> getOpportunityMap(Set<Id> oppIdSet){
        return new Map<Id, Opportunity>([SELECT Id, RecordType.Name FROM Opportunity WHERE Id IN :oppIdSet]);
    }
}