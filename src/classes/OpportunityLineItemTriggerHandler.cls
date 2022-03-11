public class OpportunityLineItemTriggerHandler extends TriggerHandlerBase{
    Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    
    public override void handleAfterInsert() 
    {
        if(!vietnamUsers)
        {
            linkToConsumptionAndBrand((List<OpportunityLineItem>)trigger.new);    
        }
        
        if(vietnamUsers)
        {
            Vietnam_OpportunityLineItemHelper.ingredientRatioCheck(Trigger.new);
        }
    }
    public override void handleBeforeInsert()
    {if(!vietnamUsers){
        for(OpportunityLineItem temp: (List<OpportunityLineItem>)trigger.new)
        {
            temp.Product_Configuration__c='N/A';
        }
    }
    } 
    public override void handleAfterUpdate()
    {
        if(vietnamUsers)
        {
            Vietnam_OpportunityLineItemHelper.ingredientRatioCheck(Trigger.new);
        }
    }
    
    public override void handleBeforeDelete()
    {
        if(vietnamUsers)
        {
            Vietnam_OpportunityLineItemHelper.checkIngredientRatioBeforeDelete(Trigger.old);
        }
    }
    
    public static void linkToConsumptionAndBrand(List<OpportunityLineItem> oppLineItems){
        Set<Id> oppLineIdSet = new Set<Id>();
        for(OpportunityLineItem oppLine :oppLineItems){
            oppLineIdSet.add(oppLine.Id);
        }
        
        if(oppLineIdSet.size() > 0){
            
            if(!System.isFuture() && !System.isBatch()){
                ConsumptionOpportunityLinkService.findAndUpdateConsumptionAndBrandAsync(oppLineIdSet);
            }
        }        
    }
}