@isTest
public class OpportunityConstants_Test {
    @testSetup
    public static void createData()
    {
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'Custom PB';
        pb.IsActive = true;            
        insert pb;
		Product2 product1 = new  Product2(Name = 'P1',
            Description = 'Some desc',
            ProductCode =  'SFDC-123',
            isActive = true,
            Family = '03-Cocoa and Speciality',
            Product_Category__c = 'Cocoa Liquor',
            Product_Sub_Category__c = 'Natural',
            Product_Sub_Category_2__c = null,
            Development_Code__c = '1');
        insert product1;

        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pb.Id;
        standardPrice.Product2Id = product1.Id;
        standardPrice.UseStandardPrice = false;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        insert standardPrice;
        
        Account acc = OFI_TestDataFactory.createAccount(true);
        Opportunity newOpp=new Opportunity();
        newOpp.AccountId=acc.Id;
        newOpp.Name='Sample opp';
        newOpp.CloseDate=system.today().addDays(10);
        newOpp.Business_Unit__c='Cocoa';
        newOpp.StageName='Offering';
        newOpp.RecordTypeId=OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID;
        newOpp.Pricebook2Id = pb.Id;
        insert newOpp;
    }
    @isTest
    public static void testData()
    { 
        Opportunity opp = [Select Id, Name From Opportunity];
    }
}