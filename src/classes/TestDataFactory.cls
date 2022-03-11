@isTest
public class TestDataFactory {
    
    @testSetup public static void setup() {
        Id oppRecordTNMId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        Id devRecTypId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Develop Opportunity').getRecordTypeId();
        
        Account acc = new Account();
        acc.name='Test Acct';
        acc.BillingCountry = 'India';
        acc.billingpostalcode = '123456';
        acc.BillingStreet ='Test';
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Family = '03-Cocoa and Speciality',
            Name ='Test',
            QuantityUnitOfMeasure ='KG',
            Development_Code__c = 'Test1234'
        );
        insert prod;   
        
        PricebookEntry pbEntry = [Select id from PricebookEntry where Pricebook2Id =: pricebookId and
                                  Product2Id =: prod.Id and isActive = true AND CurrencyISOCode = 'USD'];
        
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;  
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp3';
        opp.AccountId =acc.id;
        opp.CloseDate =system.today()+30;
        opp.StageName= 'Offering';
        opp.Pricebook2Id = pricebookId;
        opp.RecordTypeId = devRecTypId;    
        insert opp;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=opp.id;
        contentlink.ShareType= 'V'; 
        contentlink.Visibility = 'AllUsers'; 
        contentlink.ContentDocumentId = documents[0].Id;
        insert contentlink;
        
        OpportunityTeamMember optm1 = new OpportunityTeamMember();
        optm1.UserId = userinfo.getUserId();
        optm1.OpportunityId = opp.id;
        optm1.TeamMemberRole = 'PD&I Member';
        insert optm1;
        
        OpportunityLineItem opl=new OpportunityLineItem();
        opl.OpportunityId = opp.Id;
        opl.Product2Id = prod.Id;
        opl.Quantity_of_Sample_Grams__c = 12.00;
        opl.Sample_with_Billing__c = false;
        opl.Sample_Feedback__c = 'sdasdadasd';
        opl.Sampling_Status__c = '1';
        opl.UoM__c = 'G';
        opl.PricebookEntryId=pbEntry.Id;
        opl.Integration_Status__c = 'amendment';
        opl.Quantity_Dispatched__c = 12;
        insert opl;
    }
    
    
    /*@isTest
    public static List<OpportunityLineItem> sendListOfOpptyLineItems(){
        
        List<OpportunityLineItem> oppLinListToUpdate = new List<OpportunityLineItem>();
        
        
        Account acc = [select id ,name from Account where name='Test Acct'];
        
        Product2 prod = [select id ,name from Product2 where name='Test'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbEntry = [Select id from PricebookEntry where Pricebook2Id =: pricebookId and
                                  Product2Id =: prod.Id and isActive = true AND CurrencyIsoCode = 'USD'];
        
        Opportunity opp = [select id ,name,First_Sample_Due_Date__c,CloseDate from Opportunity where name='Test Opp2'];
        Sample_Request__c sr = [select id,Account__c,PD_I__c,name,Sample_Due_Date__c 
                                from Sample_Request__c 
                                where Account__c=: acc.id and Opportunity__c=:opp.id and PD_I__c =: userinfo.getUserId() and Sample_Due_Date__c =:opp.First_Sample_Due_Date__c ];
        
        
        List<OpportunityLineItem> oppLinList = [select id,OpportunityId,Product2Id 
                                                from OpportunityLineItem 
                                                where OpportunityId=:opp.Id and Product2Id=:prod.id and
                                                PricebookEntryId =: pbEntry.Id
                                               ];
        
        return oppLinList;
        
    }
    
    
    @isTest
    public static List<Sample_Request_Line_Item__c> sendListOfSampleRequestLineItems(){
        
        Account acc = [select id ,name from Account where name='Test Acct'];
        
        Product2 prod = [select id ,name from Product2 where name='Test'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbEntry = [Select id from PricebookEntry where Pricebook2Id =: pricebookId and
                                  Product2Id =: prod.Id and isActive = true];
        
        Opportunity opp = [select id ,name,First_Sample_Due_Date__c,CloseDate from Opportunity where name='Test Opp2'];
        
        OpportunityLineItem oppLinObj = [select id,OpportunityId,Product2Id 
                                         from OpportunityLineItem 
                                         where OpportunityId=:opp.Id and Product2Id=:prod.id and
                                         PricebookEntryId =: pbEntry.Id limit 1
                                        ];
        
        Sample_Request__c sr = [select id,Account__c,PD_I__c,name,Sample_Due_Date__c 
                                from Sample_Request__c 
                                where Account__c=: acc.id and Opportunity__c=:opp.id and PD_I__c =: userinfo.getUserId() and Sample_Due_Date__c =:opp.First_Sample_Due_Date__c ];
        
        
        return [SELECT ID,Opportunity_Product__c,Product__c,Sampling_Status__c,Tracking_Number__c,Development_Code__c,Sample_Request__c,Integration_Status__c,Quantity_Dispatched__c 
                FROM Sample_Request_Line_Item__c 
                WHERE Opportunity_Product__c =:oppLinObj.Id AND Product__c =:prod.Id AND Sample_Request__c =:sr.id limit 1
               ];
        
    }
    
    @isTest
    public static Sample_Request__c sendSampleReuestRecord(){
        
        Account acc = [select id ,name from Account where name='Test Acct'];
        
        Product2 prod = [select id ,name from Product2 where name='Test'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbEntry = [Select id from PricebookEntry where Pricebook2Id =: pricebookId and
                                  Product2Id =: prod.Id and isActive = true];
        
        Opportunity opp = [select id ,name,First_Sample_Due_Date__c,CloseDate from Opportunity where name='Test Opp2'];
        
        OpportunityLineItem oppLinObj = [select id,OpportunityId,Product2Id 
                                         from OpportunityLineItem 
                                         where OpportunityId=:opp.Id and Product2Id=:prod.id and
                                         PricebookEntryId =: pbEntry.Id limit 1
                                        ];
        
        
        return [select id,Account__c,PD_I__c,name,Sample_Due_Date__c 
                from Sample_Request__c 
                where Account__c=: acc.id and Opportunity__c=:opp.id and PD_I__c =: userinfo.getUserId() and Sample_Due_Date__c =:opp.First_Sample_Due_Date__c limit 1];
    }
    
    public static void autoApprovedOpportunityRecord(id opportunityId){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Approved.');
        req1.setNextApproverIds(new Id[]{UserInfo.getUserId()});
        req1.setObjectId(opportunityId);
        req1.setSubmitterId(UserInfo.getUserId());
        req1.setProcessDefinitionNameOrId('Manually_Select_Approver');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        Approval.ProcessWorkitemRequest req2 =  new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(result.getNewWorkitemIds().get(0));
        Approval.ProcessResult result2 =  Approval.process(req2);
        string s = SamplingRequestToOSSMController.createSampleRequest(opportunityId);
    }    */
    
}