public class PLBSQuotePDFCustomCntl {

    public String quoteId {get;set;}
    public Quote quote {get;set;}
    public List<PDFWrapper> pdfWrapList {get;set;}
    public Contact contact {get;set;}
    public String todaysDateStr {get;set;}
    public List<String> termsandcondition {get;set;}
    
    public PLBSQuotePDFCustomCntl(ApexPages.StandardController s){
        quoteId = ApexPages.currentPage().getParameters().get('Id');
        //ProductName,Grade,1stPM Type, Weight,OlamOfferPerUnit,1stMOQ
        //ProductName OlamOfferPerUnit - QLI
        //1stPM Type 1stMOQ  - Quote
        //Weight -Opp
        //Grade - OLI
        DateTime todaysDate = System.today();
		todaysDateStr = todaysDate.format('dd-MM-yyyy');
        
        pdfWrapList = new List<PDFWrapper>();
        quote = [SELECT Id, MOQ_Packaging_1st__c,PM_Type_1st__c,Account.Name,AccountId,Terms_Conditions__c,ExpirationDate,
                 Plbs_Inco_Term__c,Opportunity.Plbs_Weight_G__c, (Select Product2.Name,Product2.grade__c,UnitPrice from QuoteLineItems)FROM Quote 
                 WHERE Id = :quoteId];
        System.debug('qLI'+quote.QuoteLineItems);
        List<contact> conList = [select Name,Phone,MailingStreet,MailingCity, MailingState,MailingPostalCode,MailingCountry from contact where AccountId =: quote.AccountId]; 
        if(!conList.isEmpty())
        {
            contact = conList[0];
        }
        
        Integer item=0;
        for(QuoteLineItem qLI : quote.QuoteLineItems)
        {
            PDFWrapper pdfw = new PDFWrapper();
            pdfw.ItemNum = ++item;
            if(quote.PM_Type_1st__c != null)
            {
            	pdfw.packagingType = quote.PM_Type_1st__c;    
            }
            if(quote.MOQ_Packaging_1st__c != null)
            {
            	pdfw.PrimaryPackagingMOQ = quote.MOQ_Packaging_1st__c;    
            }
        	System.debug('PrdName'+qLI.Product2.Name);
            pdfw.productName = qLI.Product2.Name;
            pdfw.usdPerUnit = qLI.UnitPrice;
            pdfw.Grade = qLI.Product2.Grade__c;
            pdfw.Weight = quote.Opportunity.Plbs_Weight_G__c;
            pdfWrapList.add(pdfw);
        }
        	Date today = System.today();
	        Integer numberDaysDue = today.daysBetween(quote.ExpirationDate);
        
  		    String str1 = 'Price Quoted are valid for '+numberDaysDue+' days from date of quotation';
        	String str2 = 'Inco Term for prices quoted is '+quote.Plbs_Inco_Term__c;
        	
        if(quote.Terms_Conditions__c != null)
        {
            String str3 = quote.Terms_Conditions__c;
            List<String> str  = str3.split('\n');
            termsandcondition = new List<String>();
            termsandcondition.add(str1);
            termsandcondition.add(str2);
            
            for(String st : str)
            {
                termsandcondition.add(st);
            }
        }
        else
        {
            termsandcondition = new List<String>();
            termsandcondition.add(str1);
            termsandcondition.add(str2);
        }

        System.debug('PdfWrapList'+pdfWrapList);
        
    }
    
    public class PDFWrapper {
        public Integer ItemNum {get;set;}
        public String productName {get;set;}
        public String Grade {get;set;}
        public String packagingType {get;set;}
        public Decimal Weight {get;set;}
        public Decimal usdPerUnit {get;set;}
        public Decimal PrimaryPackagingMOQ {get;set;}
        
    }
}