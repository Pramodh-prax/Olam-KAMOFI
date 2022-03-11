public class QuotePDFAuraCustomCntl {
	@AuraEnabled
    public static ResponseWrap createDoc(String quoteId)
    {	
        String message = 'SUCCESS';
        
        Savepoint sp = Database.setSavepoint();
        try{
            PageReference pageRef = new PageReference('/apex/QuotePDFCustom?Id='+quoteId);
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
    
    
    public class ResponseWrap {
        @AuraEnabled public String message;
        @AuraEnabled public String docId;
        @AuraEnabled public String conEmail;
        
        public ResponseWrap(){
            this.message = '';
            this.docId = '';
            this.conEmail = '';
        }
    }
}