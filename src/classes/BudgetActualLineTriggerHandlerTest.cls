@isTest
public class BudgetActualLineTriggerHandlerTest {
    
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
        c.Volume_MT__c=350;
        c.Business_Unit__c='Dairy';
        //c.Budget_vs_Actual_Line__c=bal.Id;
        c.Year__c= String.valueOf(System.today().year ());
        c.Category__c='BLEND';
        c.Sub_Category__c='Brown';
        c.Sub_Category_2__c='Dairy';
        
        Consumption__c c1=new Consumption__c();
        c1.Account__c=acc.Id;
        c1.Volume_MT__c=350;
        c1.Business_Unit__c='Dairy';
        //c.Budget_vs_Actual_Line__c=bal.Id;
        c1.Year__c= String.valueOf(System.today().year ());
        c1.Category__c='BLEND';
        c1.Sub_Category__c='Brown';
        
        Consumption__c c2=new Consumption__c();
        c2.Account__c=acc.Id;
        c2.Volume_MT__c=350;
        c2.Business_Unit__c='Dairy';
        //c.Budget_vs_Actual_Line__c=bal.Id;
        c2.Year__c= String.valueOf(System.today().year ());
        c2.Category__c='BLEND';
        c2.Sub_Category__c='White';
        
        insert new List<Consumption__c> {c1, c, c2};
    }
    static testMethod void test_handleAfterUpdate() {
        
        List<Account> accList = [SELECT Id, (SELECT Id, Name From Contacts) FROM Account where Name = 'Test'];
        System.assert(accList != null && !accList.isEmpty (), 'Unable to find the account');
        
        Test.startTest();
        Budget_vs_Actuals__c ba=new Budget_vs_Actuals__c();
        ba.Account__c=accList[0].Id;
        ba.Name='Dairy-Demo';
        ba.Year__c= String.valueOf(System.today().year ());
        ba.Business_Unit__c='Dairy';
        insert ba;
        
        Budget_vs_Actual_Line__c bal=new Budget_vs_Actual_Line__c();
        bal.Budget_vs_Actuals__c=ba.Id;
        bal.Actuals__c=6000;
        bal.Volume__c=2000;
        bal.Business_Unit__c = 'Dairy';
        bal.Category__c='BLEND';
        bal.Total_Consumption__c=1000;
        bal.Sub_Category__c='Brown';
        bal.Sub_Category_2__c='Dairy';
        insert bal;
        
        bal.Category__c='CHEESE';
        bal.Sub_Category__c='Blends';
        bal.Sub_Category_2__c='OTHER';
        update bal;
        
        Test.stopTest();
    }
    
    @isTest
    static void test_updateOlderConsumptions() {
        
        List<Account> accList = [SELECT Id, (SELECT Id, Name From Contacts) FROM Account where Name = 'Test'];
        System.assert(accList != null && !accList.isEmpty (), 'Unable to find the account');
        
        Test.startTest();
        Budget_vs_Actuals__c ba=new Budget_vs_Actuals__c();
        ba.Account__c=accList[0].Id;
        ba.Name='Dairy-Demo';
        ba.Year__c= String.valueOf(System.today().year ());
        ba.Business_Unit__c='Dairy';
        insert ba;
        
        Budget_vs_Actual_Line__c bal=new Budget_vs_Actual_Line__c();
        bal.Budget_vs_Actuals__c=ba.Id;
        bal.Actuals__c=6000;
        bal.Volume__c=2000;
        bal.Business_Unit__c='Dairy';
        bal.Category__c='BLEND';
        bal.Total_Consumption__c=1000;
        bal.Sub_Category__c='Brown';
        bal.Sub_Category_2__c='Non Dairy';
        
        Budget_vs_Actual_Line__c bal1=new Budget_vs_Actual_Line__c();
        bal1.Budget_vs_Actuals__c=ba.Id;
        bal1.Actuals__c=6000;
        bal1.Volume__c=2000;
        bal1.Business_Unit__c='Dairy';
        bal1.Category__c='BLEND';
        bal1.Total_Consumption__c=1000;
        bal1.Sub_Category__c='Brown';
        
        insert new List<Budget_vs_Actual_Line__c> {bal, bal1};
        
        List<Consumption__c> consumptionList = [SELECT Id FROM Consumption__c where Budget_vs_Actual_Line__c =: bal.Id];
        System.assert(consumptionList.size() == 0, 'Failed : Child Consumption are attached');
        
        consumptionList = [SELECT Id FROM Consumption__c where Budget_vs_Actual_Line__c =: bal1.Id];
        System.assert(consumptionList.size() > 0, 'Failed : Unable to find Child Consumption records');
        
        bal.Category__c='BLEND';
        bal.Sub_Category__c='White';
        bal.Sub_Category_2__c= null;
        
        bal1.Category__c='BLEND';
        bal1.Sub_Category__c=null;
        
        update new List<Budget_vs_Actual_Line__c> {bal, bal1};
            
        consumptionList = [SELECT Id FROM Consumption__c where Budget_vs_Actual_Line__c =: bal.Id];
        System.assert(consumptionList.size() > 0, 'Failed : Unable to find Child Consumption records');
        
        Test.stopTest();
    }
   
    

}