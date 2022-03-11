public class QuotePDFCustomCntl {
    
    public String quoteId {get;set;}
    public Quote quote {get;set;}
    public Double total {get;set;}
    public Date Today { get { return Date.today(); }}
    
    public QuotePDFCustomCntl(ApexPages.StandardController s){
        quoteId = ApexPages.currentPage().getParameters().get('Id');
        
        quote = [SELECT Id, Name,Inco_Terms__c,ExpirationDate,Payment_Terms__c,Contract_Start_Date__c,Contract_End_Date__c,Olam_Quote_Number__c, Account.Name,Opportunity.RecordType.Name,Terms_Conditions__c,Account.BillingStreet,
                 Account.BillingCity,Account.BillingState,Account.BillingPostalCode, Account.BillingCountry,Opportunity.Owner.Name,
                 (SELECT Id, Product2.Name,Approval_Status__c,TotalPrice,Olam_Total_Offer__c, UnitPrice,Unit_Of_Measure__c, Volume__c,Quantity,Product2.ProductCode,Product2.External_Product_Code__c, Customer_Material_Code__c FROM QuoteLineItems WHERE ((Approval_Status__c='Accepted' OR Approval_Status__c='N/A'))) 
                 FROM Quote 
                 WHERE Id = :quoteId];
        System.debug('Quote'+quote);
        System.debug('qLI'+quote.QuoteLineItems);
        total = 0;
        for(QuoteLineItem q : quote.QuoteLineItems )
        {
            total += q.Olam_Total_Offer__c;
        }
        
    }
}