public class QuoteCloneWithLineItemsCntl {
    @AuraEnabled 
    public static ResponseWrapper cloneQuote(String quoteId){
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            String message = 'SUCCESS';
            
            String queryString = 'SELECT Id ';
            String innerQueryString = '(SELECT Id ';
            
            Map<String, List<QuoteFieldMapping__mdt>> metadataMap = getMetadata();
            
            for(QuoteFieldMapping__mdt quoteFields :metadataMap.get('Quote')){
                queryString += ', ' + quoteFields.Label;
            }
            
            for(QuoteFieldMapping__mdt quoteLineFields :metadataMap.get('QuoteLineItem')){
                innerQueryString += ', ' + quoteLineFields.Label;
            }
            
            innerQueryString += ' FROM QuoteLineItems)';
            
            queryString += ', ' + innerQueryString + ' FROM Quote WHERE Id =: quoteId';
            
            System.debug('Query string ' + queryString);
            
            Quote quot = Database.query(queryString);
            
            
            Quote newQuote = new Quote();
            
            for(QuoteFieldMapping__mdt quoteFields :metadataMap.get('Quote')){
                if(quoteFields.IsTextValue__c == true){
                    newQuote.put(quoteFields.Label, quoteFields.TargetValue__c);
                }
                else{
                    newQuote.put(quoteFields.Label, quot.get(quoteFields.Label));
                }
            }
            insert newQuote;
            
            List<QuoteLineItem> newQuoteLineItems = new List<QuoteLineItem>();
            
            for(QuoteLineItem quoteLine :quot.QuoteLineItems){
                QuoteLineItem newQuoteLine = new QuoteLineItem();
                newQuoteLine.QuoteId = newQuote.Id;
                
                for(QuoteFieldMapping__mdt quoteLineFields :metadataMap.get('QuoteLineItem')){
                    if(quoteLineFields.IsTextValue__c == true){
                        newQuoteLine.put(quoteLineFields.Label, quoteLineFields.TargetValue__c);
                    }
                    else{
                        newQuoteLine.put(quoteLineFields.Label, quoteLine.get(quoteLineFields.Label));
                    }
                }
                
                newQuoteLineItems.add(newQuoteLine);
            }
            
            insert newQuoteLineItems;
            
            ResponseWrapper res = new ResponseWrapper();
            res.message = message;
            res.quoteId = newQuote.Id;
            
            return res;
    	}
        catch(Exception e){
            Database.rollback(sp);
            
            ResponseWrapper res = new ResponseWrapper();
            res.message = e.getMessage();
            res.quoteId = null;
            return res;
        }
    }
    
    
    public static Map<String, List<QuoteFieldMapping__mdt>> getMetadata(){
        Map<String, List<QuoteFieldMapping__mdt>> metadataMap = new Map<String, List<QuoteFieldMapping__mdt>>();
        for(QuoteFieldMapping__mdt quoteFieldMapping :QuoteFieldMapping__mdt.getAll().values()){
            if(metadataMap.containsKey(quoteFieldMapping.ObjectName__c)){
                metadataMap.get(quoteFieldMapping.ObjectName__c).add(quoteFieldMapping);
            }
            else{
                metadataMap.put(quoteFieldMapping.ObjectName__c, new List<QuoteFieldMapping__mdt>{quoteFieldMapping});
            }
        }
        return metadataMap;
    }
    

    public class ResponseWrapper{
        @AuraEnabled public String quoteId;
        @AuraEnabled public String message;
    }

    
}