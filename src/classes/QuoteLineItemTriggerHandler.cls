public class QuoteLineItemTriggerHandler extends TriggerHandlerBase {
   Boolean isVietnamUser = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    public override void handleAfterDelete() {} 
        
    public static void afterDelete(List<QuoteLineItem> listQLI){
        String QuoId = '';
            for(QuoteLineItem qLI : listQLI){
                if(qLI.QuoteId != null)
                {
                    QuoId = qLI.QuoteId;
                }
            }
        
        QuoteLineItemTriggerHelper.updateQuoteStatus(QuoId);
    }
    public override void handleAfterInsert()
    {
        if(isVietnamUser)
        {
        	Vietnam_QuoteLineItemTriggerHelper.updateRatioOnQLI(Trigger.new);    
        }
        
    }
  
}