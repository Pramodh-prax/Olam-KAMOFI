@isTest
public class QuoteLineApprovalTriggerTest {
	
    @testSetup
    public static void setupData()
    {
       /* Account acc = new Account();
        acc.name='Test01';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        acc.Segment__c = 'Agent/ Distributor';
        insert acc;
        
        Product2 prod = [Select Name,Product_Category__c,Product_Sub_Category__c,Product_Sub_Category_2__c from Product2 
                         Where Product_Category__c = 'Tropical' and Product_Sub_Category__c = 'Pepper' Limit 1];
        
          // Product2 prod = new Product2();
          // prod.Name = 'Cocoa Beans';
          // prod.IsActive = true;
          // prod.Product_Category__c = 'Tropical';
           //prod.Product_Category__c = 'Pepper';
          // prod.Product_Category__c = 'Black Pepper';
            
        //insert prod;
        
        Product2 prod2 = new Product2(
            Name = 'Cocoa Butter',
            IsActive = true
        );
        insert prod2;
        
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
        
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod2.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe2;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'Test Opp',
            StageName = 'Briefing',
            RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId(),
            CloseDate = System.today(),
            Business_Unit__c = 'Cocoa',
            Application__c = 'Agent/ Distributor',
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = 'USD'
        );
        insert opp;
        
        Quote q=new Quote();
        q.OpportunityId=opp.Id;
        //q.AccountId=acc.Id;
        q.Name=opp.Name;
        q.Bussiness_Unit__c=opp.Business_Unit__c;
        q.ExpirationDate=opp.CloseDate;
        //q.Ship_To_Party__c=acc.Id;
        q.Status='Draft';
        insert q;
        
        QuoteLineItem qLI = new QuoteLineItem();
        qLI.Approval_Required__c = 'Yes';
        qLI.Approval_Status__c = 'Not Started';
        qLI.PricebookEntryId = pbe.Id;
        qLI.Product2Id = prod.Id;
        
        Product2 p = [Select Product_Category__c,Product_Sub_Category__c,Product_Sub_Category_2__c from product2 where Name = 'prod' and Id =: qLI.Product2Id];
        Quote_Line_Approval__c quoteLineApproval = new Quote_Line_Approval__c();
        quoteLineApproval.Quote_Line_Item__c = qLI.Id;
        quoteLineApproval.Approval_Status__c = qLI.Approval_Status__c;
        quoteLineApproval.Product_Category__c = p.Product_Category__c;
        quoteLineApproval.Product_Sub_Category__c = p.Product_Sub_Category__c;
        quoteLineApproval.Product_Sub_Category_2__c = p.Product_Sub_Category_2__c;
        insert quoteLineApproval;
        
        User u1 = new User();
        u1.FirstName = 'Test';
        u1.Email = 'abc@gamil.com';
        u1.IsActive = true;
        
        User u2 = new User();
        u2.FirstName = 'Test1';
        u2.Email = 'xyz@gmail.com';
        u2.IsActive = true;
        
        Approval_Matrix__C appMat = new Approval_Matrix__C();
        appMat.Approver_1__c = u1.Id;
        appMat.Approver_2__c = u2.Id;
        appMat.Product_Category__c = 'Tropical';
        appMat.Product_Category__c = 'Pepper';
        appMat.Product_Sub_Category_2__c = 'Black Pepper';
        */
            
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
         /*Product2 p=new Product2();
        p.Name='BP-14';
        p.IsActive=true;
		insert p;
        Pricebook2 pb2 = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
		 PricebookEntry pbe=new PricebookEntry();
        pbe.Product2Id=p.Id;
        pbe.Pricebook2Id=pb2.Id;
        pbe.UnitPrice=54;
        insert pbe;*/
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
        /*PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod2.Id,
            CurrencyIsoCode = 'USD',
            UnitPrice = 0,
            IsActive = true
        );
        insert pbe2;*/
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name='Gain';
        //opp.ContactId=con.Id;
        opp.StageName='Offering';
        opp.CloseDate=System.today()+1;
        opp.Type='New Business';
        opp.Business_Unit__c='Spice';
        opp.Pricebook2Id=pricebookId;
        //opp.CurrencyIsoCode='USD - U.S. Dollar';
        insert opp;
        OpportunityLineItem oli=new OpportunityLineItem();
        oli.OpportunityId=opp.Id;
        oli.UnitPrice=44;
        oli.PricebookEntryId=pbe.Id;
        insert oli;
        Quote q=new Quote();
        q.OpportunityId=opp.Id;
        //q.ContactId=con.Id;
        //q.AccountId=acc.Id;
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
        qli.Approver_Comment__c = 'Test';
        qli.Product_Configuration__c='[{"varient_character_mapping":"ZVAR_MULTI_THRU","uom":"%","quantitative":"Yes","qualitative":"","olam_range":"0,000 - 50,000","mic":"-U100","description":"% THRU US #100","customer_range":"0,000 - 50,000"},{"varient_character_mapping":"ZVAR2_MULTI_THRU","uom":"%","quantitative":"No","qualitative":"","olam_range":"0,000 - 80,000","mic":"-U200","description":"% THRU UK #200","customer_range":"0,000 - 80,000"}]';
        insert qli;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        Quote_Line_Approval__c qla=new Quote_Line_Approval__c();
        qla.Account__c=acc.Id;
        qla.Quote_Line_Item__c=qli.Id;
        qla.Quote__c=q.Id;
        qla.Approval_Status__c = 'In Progress';
        qla.Approver_1__c=u.id;
        qla.Approver_2__c=u.id;
        qla.Approver_3__c=u.id;
        insert qla;
        qla.Approval_Status__c = 'Rejected';
        update qla;
    }
    
    @isTest
    public static void addApprover()
    {
        
        
        List<Quote_Line_Approval__c> quoteLineApproval = [Select Id,Quote_Line_Item__c,Product_Category__c,	Product_Sub_Category__c,Product_Sub_Category_2__c,
                                                         Approver_1__c,Approver_2__c,Approver_3__c,Quote_Line_Item__r.Approver_Comment__c from Quote_Line_Approval__c Limit 1];
        System.assert(quoteLineApproval!=null,'Null values');
        
        QuoteLineApprovalTriggerHandler.onAfterInsert(quoteLineApproval);
        
       /* Map<Id,Quote_Line_Approval__c> map1 = new Map<Id,Quote_Line_Approval__c>();
        map1.put(quoteLineApproval[0].Id,quoteLineApproval[0]);
       	QuoteLineApprovalTriggerHandler.onAfterUpdate(quoteLineApproval,map1); */
    }
    
   
}