public class Vietnam_QuoteLineItemTriggerHelper {
	
    public static void updateRatioOnQLI(List<QuoteLineItem> quoList)
    {
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Map<Id,OpportunityLineItem> mapOfProductIdWithOppLI = new Map<Id,OpportunityLineItem>();
        if(!quoList.isEmpty())
        {
            for(QuoteLineItem quo : quoList)
        	{
            	quoteIdSet.add(quo.QuoteId);
        	}
		}
        List<Quote> listOfQuote = [Select Id,OpportunityId from Quote where Id IN:quoteIdSet];
        
        for(Quote quo : listOfQuote)
        {
            oppIdSet.add(quo.OpportunityId);
        }
        
        List<OpportunityLineItem> listOfOppLI = [Select Product2Id,ratio__c from OpportunityLineItem where opportunityid IN: oppIdSet];
        System.debug('listOfOppLI'+listOfOppLI);
        List<QuoteLineItem> listOfQLI = [Select Id,Product2Id,ratio__c from QuoteLineItem where QuoteId IN: quoteIdSet ];
        System.debug('listOfQLI'+listOfQLI);
        for(OpportunityLineItem oppLI : listOfOppLI)
        {
            for(QuoteLineItem quoLI : listOfQLI)
            {
                if(quoLI.Product2Id == oppLI.Product2Id)
                {
                    quoLI.Ratio__c = oppLI.Ratio__c;
                }
            }
        }
        System.debug('listOfQLI'+listOfQLI);
        if(!listOfQLI.isEmpty())
        {
            update listOfQLI;
		}
    }
    
}