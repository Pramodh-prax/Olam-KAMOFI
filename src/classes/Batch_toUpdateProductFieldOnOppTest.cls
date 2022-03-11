@isTest
public class Batch_toUpdateProductFieldOnOppTest {
    static testmethod void test() {
        Id oppRecordTNMId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        
        Account acc = new Account();
        acc.name='Test';
        acc.BillingCountry = 'India';
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
            
           
       
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId =acc.id;
        opp.CloseDate =system.today()+30;
        opp.StageName= 'Offering';
        opp.Pricebook2Id = pricebookId;
        opp.RecordTypeId = oppRecordTNMId;
        
        insert opp;
        
        
        OpportunityLineItem opl=new OpportunityLineItem();
        opl.OpportunityId = opp.Id;
        opl.Product2Id = prod.Id;
        opl.Quantity = 12.00;
        opl.PricebookEntryId=pbEntry.Id;
        insert opl;
        
        Test.startTest();
        Batch_toUpdateProductFieldOnOpp batchInstance = new Batch_toUpdateProductFieldOnOpp();
        Id batchId = Database.executeBatch(batchInstance);
        Test.stopTest();
    }
}