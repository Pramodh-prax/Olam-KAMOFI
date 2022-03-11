public class OpportunityTriggerHelper {
    
    public static void checkOpportunityStatusWithLatestQuoteStatus(List<Opportunity> oppList,Map<Id, Opportunity> oldMapOfOpp)
    {
        Map<Id,String> mapOfOppAndLatestQuoteStatus = new Map<Id,String>();
        Set<Id> oppId = new Set<Id>();
        
        for(Opportunity opp : oppList)
        {
            if(opp.Id != null || opp.Id != '')
            {
                oppId.add(opp.Id);
            }
        }
        //If the opportunity stage is changed to Close Won
        for(Opportunity oppObj : oppList){
            if(oldMapOfOpp.get(oppObj.Id).stageName != oppObj.stageName &&  oppObj.stageName == 'Closing Won' && oppObj.SyncedQuoteId != null){
                mapOfOppAndLatestQuoteStatus = OpportunityTriggerHelper.fetchLatestQuoteStatus(oppId);
            }
        }
        for(Opportunity opp : oppList)
        {
            if(mapOfOppAndLatestQuoteStatus.containsKey(opp.Id))
            {
                if(opp.StageName == 'Closing Won' && mapOfOppAndLatestQuoteStatus.get(opp.Id) != 'Customer Accepted')
                {
                    System.debug('Reached iF');
                    opp.addError('Opportunity Can not Closed Won. Quote Status is not \'Customer Accepted\'');
                }    
            }
            
        }
        
    }

    public static Map<Id,String> fetchLatestQuoteStatus(Set<Id> oppId)
    {
      	Map<Id,String> mapOfOppAndLatestQuote = new Map<Id,String>();
        
        List<Opportunity> listOfOppIdAndQuote = [SELECT Id, (SELECT Id, Version__c, Status from quotes Order By version__c DESC LIMIT 1) 
            FROM Opportunity 
            WHERE Id IN : oppId];
        
        
        if(!listOfOppIdAndQuote.isEmpty() && listOfOppIdAndQuote.size() > 0)
        {
            for(Opportunity opp : listOfOppIdAndQuote)
            {
                mapOfOppAndLatestQuote.put(opp.Id,opp.quotes[0].status);
            }
            
        }
                    
            
        return mapOfOppAndLatestQuote;
    }
    
    
    public static void updateOpprtunityLineItem(List<Opportunity> oppList, Map<Id,Opportunity> oldMapOfOpp)
    {
        System.debug('Inside After Update*******************************'); 
        List<OpportunityLineItem> listOfoppLineItem=new List<OpportunityLineItem>();
        List<OpportunityLineItem> OLIToBeUpdated = new List<OpportunityLineItem>();
        Set<id> syncQuoteId=new set<id>();
        //If the opportunity stage is changed to Close Won
        for(Opportunity oppObj : oppList){
            if(oldMapOfOpp.get(oppObj.Id).stageName != oppObj.stageName &&  oppObj.stageName == 'Closing Won' && oppObj.SyncedQuoteId != null){
                syncQuoteId.add(oppObj.SyncedQuoteId);
             }
        }
        
        System.debug('syncid '+syncQuoteId);
        if(!syncQuoteId.isEmpty()){
            OLIToBeUpdated= fetchOpportunityLineItem(syncQuoteId);
              System.debug('**OLIToBeUpdated'+OLIToBeUpdated);
        }
        
        if(OLIToBeUpdated.size()>0){
            System.debug('**Execute Update Query** '+OLIToBeUpdated);
            update OLIToBeUpdated;
        }
    }
    
    public static List<OpportunityLineItem> fetchOpportunityLineItem(Set<id> syncQuoteId)
    {
        List<OpportunityLineItem> listOfOppLineItem=new  List<OpportunityLineItem>();
        List<QuoteLineItem> listQuoteLineItem=[select id,OpportunityLineItemId, Product_configuration__c from 
                                               QuoteLineItem where quoteId In:syncQuoteId ];
        for(QuoteLineItem temp:listQuoteLineItem)
        {
            if(temp.Product_Configuration__c!=null && temp.Product_Configuration__c!=''){
                listOfOppLineItem.add(new OpportunityLineItem(Id=temp.OpportunityLineItemId,
                                                              Product_configuration__c=temp.Product_configuration__c));
            }
        }
        return listOfOppLineItem;
    }
    
   
}