@isTest
public class ConsumptionTriggerHandlerTest {
    @testSetup
    public static void createData()
    {
        Account acc = new Account();
        acc.name='Test';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        insert acc;
        
        Budget_vs_Actuals__c ba=new Budget_vs_Actuals__c();
        ba.Account__c=acc.Id;
        ba.Name='Dairy-Demo';
        ba.Year__c= String.valueOf(System.today().year ());
        ba.Business_Unit__c='Dairy';
        insert ba;
        
        Budget_vs_Actual_Line__c bal=new Budget_vs_Actual_Line__c();
        bal.Business_Unit__c = 'Dairy';
        bal.Budget_vs_Actuals__c=ba.Id;
        bal.Actuals__c=6000;
        bal.Volume__c=2000;
        bal.Category__c='BLEND';
        bal.Total_Consumption__c=1000;
        bal.Sub_Category__c='Brown';
        bal.Sub_Category_2__c='Dairy';
        
        Budget_vs_Actual_Line__c bal2=new Budget_vs_Actual_Line__c();
        bal2.Business_Unit__c = 'Dairy';
        bal2.Budget_vs_Actuals__c=ba.Id;
        bal2.Actuals__c=6000;
        bal2.Volume__c=2000;
        bal2.Category__c='BLEND';
        bal2.Total_Consumption__c=1000;
        bal2.Sub_Category__c='Brown';
        bal2.Sub_Category_2__c='Non Dairy';
        
        Budget_vs_Actual_Line__c bal1=new Budget_vs_Actual_Line__c();
        bal1.Business_Unit__c = 'Dairy';
        bal1.Budget_vs_Actuals__c=ba.Id;
        bal1.Actuals__c=6000;
        bal1.Volume__c=2000;
        bal1.Category__c='BLEND';
        bal1.Total_Consumption__c=1000;
        bal1.Sub_Category__c='Brown';
        
        insert new List<Budget_vs_Actual_Line__c> {bal, bal1, bal2};
    }
    @isTest
    static void testHandleBeforeInsert () {
        List<Account> accList = [SELECT Id, (SELECT Id, Name From Contacts) FROM Account where Name = 'Test'];
        System.assert(accList != null && !accList.isEmpty (), 'Unable to find the account');
        
        Test.startTest();
        Consumption__c c=new Consumption__c();
        c.Account__c=accList[0].Id;
        c.Volume_MT__c=350;
        c.Business_Unit__c='Dairy';
        //c.Budget_vs_Actual_Line__c=bal.Id;
        c.Year__c= String.valueOf(System.today().year ());
        c.Category__c='BLEND';
        c.Sub_Category__c='Brown';
        
        Consumption__c c1=new Consumption__c();
        c1.Account__c=accList[0].Id;
        c1.Volume_MT__c=350;
        c1.Business_Unit__c='Dairy';
        //c.Budget_vs_Actual_Line__c=bal.Id;
        c1.Year__c= String.valueOf(System.today().year ());
        c1.Category__c='BLEND';
        c1.Sub_Category__c='White';
        
        Consumption__c c2=new Consumption__c();
        c2.Account__c=accList[0].Id;
        c2.Volume_MT__c=350;
        c2.Business_Unit__c='Dairy';
        //c.Budget_vs_Actual_Line__c=bal.Id;
        c2.Year__c= String.valueOf(System.today().year ());
        c2.Category__c='BLEND';
        c2.Sub_Category__c='Brown';
        c2.Sub_Category_2__c='Dairy';
        
        insert new List<Consumption__c> {c1, c, c2};

        System.assertEquals(
            [SELECT Id, Category__c, Sub_Category__c, Sub_Category_2__c FROM Budget_vs_Actual_Line__c WHERE 
                 Budget_vs_Actuals__r.Year__c =: c.Year__c 
                 AND Budget_vs_Actuals__r.Account__c =: c.Account__c
                 AND Category__c =: c.Category__c
                 AND Sub_Category__c =: c.Sub_Category__c
                 AND Sub_Category_2__c =: c.Sub_Category_2__c
                ].Id, 
            [SELECT Id,Budget_vs_Actual_Line__c FROM Consumption__c WHERE Id=:c.Id].Budget_vs_Actual_Line__c,
            'Mismatch in the line items attached'
        );
        
        System.assertEquals(
            [SELECT Id, Category__c, Sub_Category__c, Sub_Category_2__c FROM Budget_vs_Actual_Line__c WHERE 
                 Budget_vs_Actuals__r.Year__c =: c2.Year__c 
                 AND Budget_vs_Actuals__r.Account__c =: c2.Account__c
                 AND Category__c =: c2.Category__c
                 AND Sub_Category__c =: c2.Sub_Category__c
                 AND Sub_Category_2__c =: c2.Sub_Category_2__c
                ].Id, 
            [SELECT Id,Budget_vs_Actual_Line__c FROM Consumption__c WHERE Id=:c2.Id].Budget_vs_Actual_Line__c,
            'Mismatch in the line items attached'
        );
       
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testHandleBeforeUpdate () {
        List<Account> accList = [SELECT Id, (SELECT Id, Name From Contacts) FROM Account where Name = 'Test'];
        System.assert(accList != null && !accList.isEmpty (), 'Unable to find the account');
        
        Test.startTest();
        Consumption__c c=new Consumption__c();
        c.Account__c=accList[0].Id;
        c.Volume_MT__c=350;
        c.Business_Unit__c='Dairy';
        c.Year__c= String.valueOf(System.today().year ());
        c.Category__c='BLEND';
        c.Sub_Category__c='Brown';
        c.Sub_Category_2__c='Dairy';
        
        Consumption__c c1=new Consumption__c();
        c1.Account__c=accList[0].Id;
        c1.Volume_MT__c=350;
        c1.Business_Unit__c='Dairy';
        c1.Year__c= String.valueOf(System.today().year ());
        c1.Category__c='BLEND';
        c1.Sub_Category__c='White';
        
        Consumption__c c3=new Consumption__c();
        c3.Account__c=accList[0].Id;
        c3.Volume_MT__c=350;
        c3.Business_Unit__c='Dairy';
        c3.Year__c= String.valueOf(System.today().year ());
        c3.Category__c='BLEND';
        c3.Sub_Category__c='White';
        
        Consumption__c c2=new Consumption__c();
        c2.Account__c=accList[0].Id;
        c2.Volume_MT__c=350;
        c2.Business_Unit__c='Dairy';
        c2.Year__c= String.valueOf(System.today().year ());
        c2.Category__c='BLEND';
        c2.Sub_Category__c='Brown';
        
        insert new List<Consumption__c> {c1, c, c2, c3};

        Id blineId = [SELECT Id, Category__c, Sub_Category__c, Sub_Category_2__c FROM Budget_vs_Actual_Line__c WHERE 
                 Budget_vs_Actuals__r.Year__c =: c.Year__c 
                 AND Budget_vs_Actuals__r.Account__c =: c.Account__c
                 AND Category__c =: c.Category__c
                 AND Sub_Category__c =: c.Sub_Category__c
                 AND Sub_Category_2__c =: c.Sub_Category_2__c
                ].Id;
        System.assertEquals(
            blineId, 
            [SELECT Id,Budget_vs_Actual_Line__c FROM Consumption__c WHERE Id=:c.Id].Budget_vs_Actual_Line__c,
            'Mismatch in the line items attached'
        );            
        
        c.Category__c='BLEND';
        c.Sub_Category__c='Brown';
        c.Sub_Category_2__c='Non Dairy';
        update c;
        
        System.assertEquals(
            [SELECT Id, Category__c, Sub_Category__c, Sub_Category_2__c FROM Budget_vs_Actual_Line__c WHERE 
                 Budget_vs_Actuals__r.Year__c =: c.Year__c 
                 AND Budget_vs_Actuals__r.Account__c =: c.Account__c
                 AND Category__c =: c.Category__c
                 AND Sub_Category__c =: c.Sub_Category__c
                 AND Sub_Category_2__c =: c.Sub_Category_2__c
                ].Id, 
            [SELECT Id,Budget_vs_Actual_Line__c FROM Consumption__c WHERE Id=:c.Id].Budget_vs_Actual_Line__c,
            'Mismatch in the line items attached'
        );
        
        List<Consumption__c> consumptionList = [SELECT Id FROM Consumption__c where Budget_vs_Actual_Line__c =: blineId];
        System.assert(consumptionList.size() ==0, 'Mismatch in the child size');
        Test.stopTest();
        
        
    }
}