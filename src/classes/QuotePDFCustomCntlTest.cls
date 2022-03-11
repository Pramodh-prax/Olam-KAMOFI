@isTest
public class QuotePDFCustomCntlTest {
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
             
        Product2 prod = new Product2(
            Name = 'Cocoa Beans',
            IsActive = true
        );
        insert prod;
        
        /*Product2 prod2 = new Product2(
            Name = 'Cocoa Butter',
            IsActive = true
        );
        insert prod2;*/
        
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('PBI '+pricebookId);
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='Gain';
        opp.ContactId=con.Id;
        opp.StageName='Offering';
        opp.CloseDate=System.today()+1;
        opp.Pricebook2Id=pricebookId;
        opp.Type='New Business';
        opp.Business_Unit__c='Spice';
        //opp.CurrencyIsoCode='USD - U.S. Dollar';
        insert opp;
        
        Quote q=new Quote();
        q.OpportunityId=opp.Id;
        q.ContactId=con.Id;
        q.Name=opp.Name;
        q.Bussiness_Unit__c=opp.Business_Unit__c;
        q.ExpirationDate=opp.CloseDate;
        //q.Ship_To_Party__c=acc.Id;
        q.Status='Draft';
        insert q;   
        QuoteLineItem qli=new QuoteLineItem();
        qli.QuoteId=q.Id;
        //qli.Product2Id=p.Id;
        qli.PricebookEntryId=pbe.Id;
        qli.UnitPrice = 0;
        qli.Volume__c=3;
        qli.Quantity=5;
        qli.Approval_Status__c='Accepted';
        qli.Product_Configuration__c='[{"olam_material_code":"100000039072","customer_sap_id":"1234","customer_material_code":"","configurations":[{"varient_character_mapping":"","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 500,000","mic":"-U100","indicator":"Product","description":"MOLD COUNT PER GRAM","customer_range":"0,000 - 500,000"},{"varient_character_mapping":"MOIST","uom":"","quantitative":"Yes","qualitative":"","olam_range":"0,00 - 500,00","mic":"","indicator":"Product","description":"Moist 6","customer_range":"0,00 - 700,00"}]}]'; 
        insert qli;
    }
    @isTest
    public static void QuotePDFCustomCntl()
    {
        Quote q = [SELECT Id, Name,Inco_Terms__c,ExpirationDate,Payment_Terms__c,Contract_Start_Date__c,Contract_End_Date__c,Olam_Quote_Number__c, Account.Name,Opportunity.RecordType.Name,(SELECT Id, Product2.Name,Approval_Status__c, UnitPrice, Volume__c,Olam_Total_Offer__c FROM QuoteLineItems) FROM Quote ]; 
        system.assert(q!=null, 'Null values found');
       
        PageReference testPage = Page.QuotePDFCustom; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(q.Id));
        ApexPages.StandardController sc=new ApexPages.StandardController(q);
        QuotePDFCustomCntl qcc= new QuotePDFCustomCntl(sc);
    }
}