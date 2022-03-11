public class QuoteLineApprovalTriggerHandler {
    public static void onAfterInsert(List<Quote_Line_Approval__c> quoteLineApprovals){
        QuoteLineApprovalTriggerHelper.addPLMsToOpportunityTeams(quoteLineApprovals);
    }
    
    public static void onAfterUpdate(List<Quote_Line_Approval__c> quoteLineApprovals,Map<id,Quote_Line_Approval__c> quoteLineApprovalOldMap)
    {
        //QuoteLineItemId
        //Check if status change from InProgress to Accepted/Rejected
        // Map of Changed Status on QLA with Quote Line Item Id
        
        Map<ID,Quote_Line_Approval__c> mapOfIdWithQuoteLineApproval = new Map<ID,Quote_Line_Approval__c>();
        for(Quote_Line_Approval__c qLA : quoteLineApprovals){
            if(quoteLineApprovalOldMap.containsKey(qLA.Id))
            {   
                if(quoteLineApprovalOldMap.get(qLA.Id).Approval_Status__c == 'In Progress' && (qLA.Approval_Status__c == 'Approved'
                  || qLA.Approval_Status__c == 'Rejected'))
                {
                    
					mapOfIdWithQuoteLineApproval.put(qLA.Id,qLA);                    
                }
            }
        }
        
        QuoteLineApprovalTriggerHelper.addApproversComments(mapOfIdWithQuoteLineApproval);
        //Map of QuoteLineItemId with QuoteLineApproval
        
    }
}