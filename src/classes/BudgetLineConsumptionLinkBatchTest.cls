@isTest
public class BudgetLineConsumptionLinkBatchTest {
    
    @testSetup
    public static void createData()
    {
        Account acc = new Account();
        acc.name='Test';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        insert acc;
        
        Consumption__c c=new Consumption__c();
        c.Account__c=acc.Id;
        c.Volume_MT__c = 350;
        c.Business_Unit__c='Dairy';
        c.Year__c= String.valueOf(System.today().year());
        c.Category__c='BLEND';
        c.Sub_Category__c='Brown';
        c.Sub_Category_2__c='Dairy';
        
        Consumption__c c1=new Consumption__c();
        c1.Account__c=acc.Id;
        c1.Volume_MT__c=350;
        c1.Business_Unit__c='Dairy';
        c1.Year__c= String.valueOf(System.today().year());
        c1.Category__c='BLEND';
        c1.Sub_Category__c='Brown';
        
        Consumption__c c2=new Consumption__c();
        c2.Account__c=acc.Id;
        c2.Volume_MT__c=350;
        c2.Business_Unit__c='Dairy';
        c2.Year__c= String.valueOf(System.today().year());
        c2.Category__c='BLEND';
        c2.Sub_Category__c='White';
        
        insert new List<Consumption__c> {c1, c, c2};
        
        Budget_vs_Actuals__c ba=new Budget_vs_Actuals__c();
        ba.Account__c= acc.Id;
        ba.Name='Dairy-Demo';
        ba.Year__c= String.valueOf(System.today().year());
        ba.Business_Unit__c='Dairy';
        insert ba;
        
        Budget_vs_Actual_Line__c bal=new Budget_vs_Actual_Line__c();
        bal.Budget_vs_Actuals__c=ba.Id;
        bal.Actuals__c=6000;
        bal.Volume__c=2000;
        bal.Business_Unit__c = 'Dairy';
        bal.Category__c='BLEND';
        bal.Total_Consumption__c=0;
        bal.Sub_Category__c='Brown';
        bal.Sub_Category_2__c='Dairy';
        insert bal;
    }
    
    
    
    static testMethod void testOne() {
        
        Test.startTest();
        Database.executeBatch(new BudgetLineConsumptionLinkBatch(String.valueOf(System.today().year())), 1);
        Test.stopTest();
        
        System.assertEquals([SELECT Total_Consumption__c FROM Budget_vs_Actual_Line__c LIMIT 1].Total_Consumption__c, 350);
    }
}