public class SubmitForApprovalController {
	
    @AuraEnabled
    public static List<QuoteLineApprovalWrapper> getQuoteLineApprovals(Id QuoteId)
    {
        List<QuoteLineItem> quoteLineList = [SELECT Id,Product2.Name,Quote.AccountId,Product2.External_Product_Code__c,Product2.Brand__c,Product2.Product_Category__c,
                                                           Product2.Product_Sub_Category__c,Product2.Product_Sub_Category_2__c,UnitPrice,Quantity,Subtotal,Volume__c,
                                                           Unit_Of_Measure__c,Approval_Required__c,Approval_Status__c, Quote.Account.Regions__c, Quote.Bussiness_Unit__c,
                                             				QuoteId
                                          		FROM QuoteLineItem 
                                         		WHERE 
                                             		QuoteID =: QuoteId AND 
                                             		Approval_Required__c =: 'Yes' AND 
                                             		Approval_Status__c = 'Not Started'];
        
        List<QuoteLineApprovalWrapper> quoteLineApprovals = new List<QuoteLineApprovalWrapper>();
        
        String businessUnit = '';
        String region = '';
        
        if(quoteLineList.size() > 0){
            businessUnit = quoteLineList[0].Quote.Bussiness_Unit__c;
            region = quoteLineList[0].Quote.Account.Regions__c;
        }
        
        QuoteLineApprovalServiceInterface quoteLineApprovalService = getServiceInstance(businessUnit);
        quoteLineApprovals = quoteLineApprovalService.getQuoteLineApprovers(businessUnit, region, quoteLineList);
        
        return quoteLineApprovals;
    }
    
    
    public Static QuoteLineApprovalServiceInterface getServiceInstance(String businessUnit){
        if(businessUnit == 'Cocoa'){
            return new QuoteLineApprovalServiceCocoa();
        }
        else{
            return new QuoteLineApprovalService();
        }
    }
    
    
    @AuraEnabled
    public static String createQuoteLineApprovals(List<Quote_Line_Approval__c> quoteLineApprovals){
        String returnResponse = 'OOOPS! Some error occurred. Please Contact System Admin.';
        
        System.debug('Approval Lines---'+quoteLineApprovals[0].Account__c);
        
        Savepoint sp = Database.setSavepoint();
        try{
            if(!quoteLineApprovals.isEmpty()){
                insert quoteLineApprovals;
                return returnResponse = 'SUCCESS';
            }
        } catch(Exception e){
            System.debug('Exception Message: '+e.getMessage());
            System.debug('Exception StacktraceSTring: '+e.getStackTraceString());
            if(e.getMessage().containsIgnoreCase('')){
                
            }
            returnresponse = 'OOOPS! Some error occurred. Please Contact System Admin. ' +e.getMessage();
            //returnresponse ='Divided by zero. Error';
            Database.rollback(sp);
        }
        System.debug('returnResponse: '+returnResponse);
        return returnResponse; 
    }
}