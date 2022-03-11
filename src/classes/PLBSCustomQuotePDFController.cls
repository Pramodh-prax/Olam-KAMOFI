public class PLBSCustomQuotePDFController {
    @AuraEnabled
    public static ResponseWrap createDoc(String quoteId)
    {	
        String message = 'SUCCESS';
        
        Savepoint sp = Database.setSavepoint();
        try{
            PageReference pageRef = new PageReference('/apex/PLBSQuotePDFCustom?Id='+quoteId);
            Blob content;
            if(!test.isrunningtest())
                content = pageRef.getContent();
            else
                content = Blob.valueOf( EncodingUtil.urlEncode('abc', 'UTF-8'));
            
            QuoteDocument doc = new QuoteDocument(Document = content, QuoteId = quoteId);
            insert doc;
            
            QuoteDocument quoteDoc = [SELECT ContentVersionDocumentId FROM QuoteDocument WHERE Id =:doc.Id];
            Quote quot = [SELECT Opportunity.ContactId FROM Quote WHERE Id = :quoteId];
            
            ResponseWrap res = new ResponseWrap();
            res.message = message;
            res.docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :quoteDoc.ContentVersionDocumentId].ContentDocumentId;
            
            if(quote.Opportunity.ContactId != null){
                List<Contact> conList = [SELECT Email FROM Contact WHERE Id = :quot.Opportunity.ContactId];
                if(conList.size() > 0)
                    res.conEmail = conList[0].Email;
            }
            
            return res;
        }
        catch(Exception e){
            Database.rollback(sp);
            ResponseWrap res = new ResponseWrap();
            res.message = e.getMessage();
            res.docId = '';
            
            return res;
        }     
    }
    
    @AuraEnabled
    public static Boolean isContactAvailable (String quoteId){
        System.debug('quoteId: '+quoteId);
        Boolean isAvail = false;
        Quote quot = [SELECT Opportunity.Parent_Opportunity__c FROM Quote WHERE Id = :quoteId];
        List<OpportunityContactRole> oppCon = [Select ContactId from OpportunityContactRole where OpportunityId=:quot.Opportunity.Parent_Opportunity__c AND isPrimary =: true];
        System.debug('oppCon'+oppCon);
        //take Opportunity.ContctID,
        //query Contact & befor this, check contactID null or not  return contact with req fields...
        System.debug('Quote: '+quot);
        if(!oppCon.isEmpty() && oppCon[0].ContactId != null)
        {
            isAvail = true;
        }
        return isAvail;
    }
    
    
    public class ResponseWrap {
        @AuraEnabled public String message;
        @AuraEnabled public String docId;
        @AuraEnabled public String conEmail;
    }
}