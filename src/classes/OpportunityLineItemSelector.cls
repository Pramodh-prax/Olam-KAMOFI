public with sharing class OpportunityLineItemSelector {
    
    public static List<OpportunityLineItem> getOpportunityLines (Id accountId, Date startDate, Date endDate, String bu) {
        return [
            SELECT Id, Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Converted_Volume_in_MT__c, Product2Id
            FROM OpportunityLineItem
            WHERE Product2Id != null
            AND Opportunity.AccountId =: accountId AND Opportunity.Business_Unit__c =: bu
            AND (Opportunity.CloseDate >=: startDate AND Opportunity.CloseDate <=: endDate)
            AND Opportunity.StageName =: OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON
            LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
        ];
    }
}