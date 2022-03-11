public class Vietnam_OpportunityLineItemHelper {
	public static void ingredientRatioCheck(List<OpportunityLineItem> oppLineItems)
    {
        // decimal totalNewIngredientRatio = 0.0;
        
        Set<Id> oppIds = new Set<Id>();
        
        if(!oppLineItems.isEmpty() && oppLineItems.size() != 0)
        {
            for(OpportunityLineItem oppLI : oppLineItems)
            {
                if(oppLI.OpportunityId != null)
                {
                    oppIds.add(oppLI.OpportunityId);
                }
                //totalNewIngredientRatio += oppLI.Ratio__c;
            }
        }
        
        List<AggregateResult> IngredientAggRes = [SELECT OpportunityLineItem.OpportunityId, sum(Ratio__c)ratio 
                                                  FROM OpportunityLineItem 
                                                  WHERE OpportunityLineItem.OpportunityId in :oppIds 
                                                  group by OpportunityLineItem.OpportunityId];
        System.debug('ingredientAggRes:'+IngredientAggRes);
        
        if (oppLineItems != null || oppLineItems.size() > 0) {
            for(OpportunityLineItem oppLI : oppLineItems){
                decimal totalRatio;
                for(AggregateResult ar: IngredientAggRes)
                {
                    totalRatio = (decimal)ar.get('ratio');
                    if(totalRatio != 100.0) {
                        oppLI.addError('Total Ratio must be 100%'); 
                    }
                }    
            }
        } 
    }
    
    public static void checkIngredientRatioBeforeDelete(List<OpportunityLineItem> oppLineItems)
    {
        System.debug('checkIngredientRatioBeforeDelete');
        for(OpportunityLineItem oppLI : oppLineItems)
        {
            if(oppLI.Ratio__c != 0 && oppLI.Ratio__c != 100)
            {
                oppLI.addError('Ratio must be 0 or 100% before Delete');
            }
        }
    }
}