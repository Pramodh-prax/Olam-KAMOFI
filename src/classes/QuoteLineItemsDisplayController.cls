public class QuoteLineItemsDisplayController {
    @AuraEnabled
    public static List<QuoteLineItem> fetchQuoteLineItems (String quoteId){
        System.debug('quoteId: '+quoteId);
        List<QuoteLineItem> QuoLIList = [SELECT Id,Product2.Name,Product2.External_Product_Code__c,UnitPrice,Quantity,Subtotal,Volume__c,Unit_Of_Measure__c,
                                         Approval_Required__c,Approval_Status__c,Quote.Status,Product_Configuration__c,Approver_Comment__c,Customer_Material_Code__c,Is_File_Uploaded__c
                                         FROM QuoteLineItem 
                                         WHERE QuoteID =: quoteId
                                        ];
        
        return QuoLIList;
    }
    @AuraEnabled
    public static Quote fetchQuoteDetails (String quoteId){
        System.debug('quoteId: '+quoteId);
        return [SELECT Id,Status,Opportunity.ContactId FROM Quote WHERE Id =: quoteId];
    }
    @AuraEnabled
    public static String deleteQuoteLineItems (List<QuoteLineItem> listOfQuoteLineItemsToDelete){
        User systeAdmin = [select id,email from User where  Profile.name = 'System Administrator' and IsActive=True limit 1];
        String returnResponse = 'OOOPS! Some error occurred. Please Contact System Admin. SYSTEM ADMIN EMAIL : '+systeAdmin.Email ;
        Savepoint sp = Database.setSavepoint();
        try{
            if(!listOfQuoteLineItemsToDelete.isEmpty()){
                delete listOfQuoteLineItemsToDelete;
                returnResponse = 'SUCCESS';
            }
        }
        catch(Exception e){
            returnresponse = 'OOOPS! Some error occurred. Please Contact System Admin. SYSTEM ADMIN EMAIL : '+systeAdmin.Email +' . ' +e.getMessage();
            //returnresponse ='Divided by zero. Error';
            Database.rollback(sp);
        }
        return returnResponse;
    }
    @AuraEnabled
    public static void deleteFiles(List<Id> listOfContentDocIds){
        //check if the ContentDocument Ids set is not empty    	
        if(!listOfContentDocIds.isEmpty()){
            List<ContentDocument> contentDocumentToDelete = new List<ContentDocument>();
            //query to get all ContentDocument that needs to be deleted
            contentDocumentToDelete = [Select id From ContentDocument Where Id IN :listOfContentDocIds];
            if(!contentDocumentToDelete.isEmpty()){
                try{
                    delete contentDocumentToDelete;
                } 
                catch(Exception ex){
                    System.debug('Exception--'+ex.getMessage());
                }	
            }
        }        
    }   
}