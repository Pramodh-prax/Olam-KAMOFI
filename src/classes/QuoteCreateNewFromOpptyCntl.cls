public class QuoteCreateNewFromOpptyCntl {
    
	@AuraEnabled 
    public static ResponseWrapper createQuote(String oppId){
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            String message = 'SUCCESS';
            
            ResponseWrapper res = new ResponseWrapper();
            
            Opportunity opp = getOpportunity(oppId);
            
            if(opp.OpportunityLineItems != null && opp.OpportunityLineItems.size() > 0){
                
                //Newly added as part of product Config API and JSON changes
                Set<Id> setOfProdIdsforProdConfig = new Set<Id>();
                Map<Id, ProductConfigMaster__c> mapOfProductIdWithProdConfigMaster = new Map<Id, ProductConfigMaster__c>();
                
                for(OpportunityLineItem oppLine :opp.OpportunityLineItems){
                    if(oppLine.PricebookEntryId !=NULL && oppLine.PricebookEntry.Product2Id !=NULL && oppLine.PricebookEntry.Product2.Is_Product_Config_Required__c){
                        setOfProdIdsforProdConfig.add(oppLine.PricebookEntry.Product2Id);
                    }
                }
                
                if(!setOfProdIdsforProdConfig.isEmpty()){
                    for(ProductConfigMaster__c prodConfigMaster : [Select Id,Product__c,Product_Configuration__c 
                                                                     from ProductConfigMaster__c 
                                                                     where Product__c =: setOfProdIdsforProdConfig]){
                        mapOfProductIdWithProdConfigMaster.put(prodConfigMaster.Product__c,prodConfigMaster);
                    }
                }
                Quote newQuote = new Quote(
                    Name = opp.Name,
            		OpportunityId = opp.Id,
                    Ship_to_Party__c = opp.AccountId,
                    Bussiness_Unit__c = opp.Business_Unit__c,
                    CurrencyISOCode = opp.CurrencyISOCode,
                    Pricebook2Id = opp.Pricebook2Id,
                    ExpirationDate = opp.CloseDate,
                    Status = 'Not Started'
            	);
                insert newQuote;
                
                List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
                for(OpportunityLineItem oppLine :opp.OpportunityLineItems){
                    QuoteLineItem quoteLine = new QuoteLineItem(
                    	QuoteId = newQuote.Id,
                        OpportunityLineItemId  = oppLine.Id,
                        UnitPrice = oppLine.UnitPrice,
                        Volume__c = oppLine.Volume__c,
                        Quantity = oppLine.Quantity,
                        PricebookEntryId = oppLine.PricebookEntryId,
                        Unit_of_Measure__c = oppLine.Unit_of_Measure__c,
                        Approval_Required__c = 'Yes'
                    );
                    if(mapOfProductIdWithProdConfigMaster.containsKey(oppLine.PricebookEntry.Product2Id)){
                        quoteLine.Product_Configuration__c = mapOfProductIdWithProdConfigMaster.get(oppLine.PricebookEntry.Product2Id).Product_Configuration__c;
                        quoteLine.Product_Config_Source__c = AddQuoteLineItemsController.PRODCONFIGSOURCE_PRODUCT_CONFIG_MASTER;
                    }
                    quoteLineItemList.add(quoteLine);
                }
                insert quoteLineItemList;
                
                res.quoteId = newQuote.Id;
            }
            else{
                message = 'There are no accepted products to create a quote';
            }
            
            res.message = message;
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
    
    
    public static Opportunity getOpportunity(String oppId){
       	return [SELECT Id, Name, AccountId, CloseDate, Pricebook2Id, CurrencyISOCode, Business_Unit__c, 
                (SELECT Id, PricebookEntryId,PricebookEntry.Product2.Is_Product_Config_Required__c, UnitPrice, Volume__c, Unit_of_Measure__c, Quantity FROM OpportunityLineItems WHERE Sampling_Status__c = '7')
                FROM Opportunity WHERE Id =:oppId];
    }
    
 
    public class ResponseWrapper{
        @AuraEnabled public String quoteId;
        @AuraEnabled public String message;
    }    
}