public class OpportunityActions {
	
	public class ClosedWonNewApprovedSKURequest {
        @InvocableVariable(required=true)
        public ID oppId;
        
        @InvocableVariable(required=true)
        public ID accId;
	}
    
    public class ClosedWonNewApprovedSKUResponse {
        @InvocableVariable
        public ID oppId;
        
        @InvocableVariable
        public ID accId;
        
        @InvocableVariable
        public List<OpportunityLineItem> newApprovedSKUList;
	}
    
    @InvocableMethod(label='Get New Approved SKU List' description='For closed won opportunity, get new approved sku list from a current opportunity id and a related account id' category= 'Opportunity')
    public static List<ClosedWonNewApprovedSKUResponse> GetNewApprovedSKUList(List<ClosedWonNewApprovedSKURequest> requests) {
        List<ClosedWonNewApprovedSKUResponse> ret = new List<ClosedWonNewApprovedSKUResponse>();
        
        // Prepare data for query
        Set<Id> accountIdList = new Set<Id>();
        Set<Id> oppIdList = new Set<Id>();
        Map<Id, Id> oppAccountMap = new Map<Id, Id>();
        for(ClosedWonNewApprovedSKURequest request: requests) {
            accountIdList.add(request.accId);
            oppIdList.add(request.oppId);
            oppAccountMap.put(request.oppId, request.accId);
		}
        
        // Get Assets information(Existing approved SKU which is Produc2Id) which are linked to accounts
        Map<Id, Map<Id, Boolean>> accountProduct2IdMap = new Map<Id, Map<Id, Boolean>>();
        for(Asset asset: [Select Id, AccountId, Product2Id 
                                from Asset 
                                where AccountId in :accountIdList]) {
            Id accId = asset.AccountId;
            if(!accountProduct2IdMap.containsKey(accId)) {
                accountProduct2IdMap.put(accId, new Map<Id, Boolean>());
            }
            accountProduct2IdMap.get(accId).put(asset.Product2Id, true);
		}
        
        // Get new opportunity line items (Will be added as approved SKU if not already exists under the related account)
        Map<Id, List<OpportunityLineItem>> oppAndoppLineItemMap = new Map<Id, List<OpportunityLineItem>>();
        for(OpportunityLineItem oppLineItem: [Select Id, Name, OpportunityId, Product2Id, ProductCode, Volume__c, Sampling_Status__c,
                                               Product_Configuration__c 
                                              from OpportunityLineItem  
                                              where OpportunityId in :oppIdList 
                                                          and (Sampling_Status__c = :OpportunityConstants.sampleStatus_Sample_Accepted or Volume__c > 0)
                                              Order by Id]) {
            Id oppId = oppLineItem.OpportunityId;
            if(!oppAndoppLineItemMap.containsKey(oppId)) {
                oppAndoppLineItemMap.put(oppId, new List<OpportunityLineItem>());
            }
            oppAndoppLineItemMap.get(oppId).add(oppLineItem);
		}
        
        // OlamLogger.logPretty('oppAndoppLineItemMap', oppAndoppLineItemMap);
        // OlamLogger.logPretty('accountProduct2IdMap', accountProduct2IdMap);
        
        // Remove new opportunity line items which already appeared under a related account and add to the response list
        for(Id oppId: oppAndoppLineItemMap.keySet()) {
            Id accId = oppAccountMap.get(oppId);
            List<OpportunityLineItem> newOppLineItemList = oppAndoppLineItemMap.get(oppId);
            Map<Id, Boolean> existingProduct2IdList = accountProduct2IdMap.get(accId);
            // OlamLogger.logPretty('newOppLineItemList', newOppLineItemList);
            // OlamLogger.logPretty('existingProduct2IdList', existingProduct2IdList);
            newOppLineItemList = removeDuplicateProduct2Id(newOppLineItemList);
            List<OpportunityLineItem> newApprovedSKUList = removeExistingProduct2Id(newOppLineItemList, existingProduct2IdList);
            
            ClosedWonNewApprovedSKUResponse response = new ClosedWonNewApprovedSKUResponse();
            response.oppId = oppId;
            response.accId = accId;
            response.newApprovedSKUList = newApprovedSKUList;
            ret.add(response);
        }
        
        return ret;
	}
    
    private static List<OpportunityLineItem> removeDuplicateProduct2Id(List<OpportunityLineItem> sourceList) {
        if(sourceList.size() == 1)
            return sourceList;
        
        //OlamLogger.logPretty('removeDuplicateProduct2Id input', sourceList);
        List<OpportunityLineItem> filteredList = new List<OpportunityLineItem>();
        Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>();
		for(OpportunityLineItem source : sourceList) {
            if(!oppLineItemMap.containsKey(source.Product2Id)) {
                //OlamLogger.logPretty('removeDuplicateProduct2Id first insert', source.Product2Id);
                oppLineItemMap.put(source.Product2Id, source);
            }
            else if((source.Volume__c != null && source.Volume__c > 0) || source.Sampling_Status__c == OpportunityConstants.sampleStatus_Sample_Accepted){
                //OlamLogger.logPretty('removeDuplicateProduct2Id update', source.Product2Id);
                oppLineItemMap.put(source.Product2Id, source);
            }
        }
        
        //OlamLogger.logPretty('removeDuplicateProduct2Id process', oppLineItemMap);
        
        for(Id product2Id : oppLineItemMap.keySet()) {
            filteredList.add(oppLineItemMap.get(product2Id));
        }
		//OlamLogger.logPretty('removeDuplicateProduct2Id output', filteredList);
		return filteredList;        
    }
    
    private static List<OpportunityLineItem> removeExistingProduct2Id(List<OpportunityLineItem> sourceList, Map<Id, Boolean> product2IdFilterMap) {
        if(product2IdFilterMap == null)
            return sourceList;
        
        List<OpportunityLineItem> filteredList = new List<OpportunityLineItem>();
        for(OpportunityLineItem source : sourceList) {
            if(!product2IdFilterMap.containsKey(source.Product2Id)) {
                filteredList.add(source);
            }
        }
        
        return filteredList;
    }
}