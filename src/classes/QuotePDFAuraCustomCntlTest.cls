@isTest
public class QuotePDFAuraCustomCntlTest {
    @testSetup
    public static void createData()
    {
        Account acc=new Account();
        acc.Name='Spices';
        acc.BillingCountry='India';
        acc.BillingStreet='xyz area';
        insert acc;
        
        Contact con =new Contact();
        con.AccountId=acc.Id;
        con.LastName='Ben';
        con.Email='abc@gmail.com';
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='Gain';
        opp.ContactId=con.Id;
        opp.StageName='Offering';
        opp.CloseDate=System.today()+1;
        opp.Type='New Business';
        opp.Business_Unit__c='Spice';
        //opp.CurrencyIsoCode='USD - U.S. Dollar';
        insert opp;
        
        Quote q=new Quote();
        q.OpportunityId=opp.Id;
        q.ContactId=con.Id;
        //q.AccountId=acc.Id;
        q.Name=opp.Name;
        q.Bussiness_Unit__c=opp.Business_Unit__c;
        q.ExpirationDate=opp.CloseDate;
        //q.Ship_To_Party__c=acc.Id;
        q.Status='Draft';
        insert q;
        QuoteDocument qd=new QuoteDocument();
        qd.QuoteId=q.Id;
       
        
    }
    
    public static testmethod void createDoc()
    {
        Quote quo=[Select Id,Name,Opportunity.ContactId,Status,ExpirationDate,Version__c from Quote LIMIT 1];
        System.assert(quo!=null, 'Null value found');
        QuotePDFAuraCustomCntl.createDoc(quo.Id);
    }
    
    public static testmethod void createDoc_catch()
    {
        Quote quote=new Quote();
        QuotePDFAuraCustomCntl.createDoc(quote.Id);
        
    }
    
    @isTest
    public static void innerResponseWrapClassTest()
    {
        QuotePDFAuraCustomCntl.ResponseWrap wrapCls = new QuotePDFAuraCustomCntl.ResponseWrap();
        
	}
}