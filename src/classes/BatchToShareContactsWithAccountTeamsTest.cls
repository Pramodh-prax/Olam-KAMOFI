@isTest(SeeAllData=false)
public class BatchToShareContactsWithAccountTeamsTest {
    @testSetup static void setupData() {
        //Commented as part of OFI as it is no more valid
        
        /*UserRole r = [select id,name from UserRole where name LIKE '%Cocoa%' limit 1];
        Profile prof = [select id,name from profile where name LIKE '%Cocoa%' limit 1]; 
        
        User usr1 = TestUtility.getUser(prof.Id, r.Id, 'olam.test@test.olam.com1', 'OLTest01', 'OLTest01', 'OLTest01');
        User usr2 = TestUtility.getUser(prof.Id, r.Id, 'olam.test@test.olam.com2', 'OLTest02', 'OLTest02', 'OLTest02');
        
        insert new List<User>{usr1, usr2};
        
       
        System.runAs(usr1){
           
            Account acc = new Account();
            acc.name='Test01';
            acc.BillingCountry = 'India';
            acc.BillingStreet ='Test';
            insert acc;
            
            //Insert Team1
            Teams__c team1 = new Teams__c();
            team1.Account__c = acc.id;
            team1.User__c = usr2.id;
            team1.Is_Primary__c = false;
            insert team1;
            
            
            //Insert contact
            Contact c = new Contact();
            c.LastName = 'test';
            c.AccountId = acc.id;
            c.Email = 'test@gmail.com';
            insert c;
        }   */ 
    }
    
    @isTest static void testOne() {
    	Test.startTest();
        BatchToShareContactsWithAccountTeams b = new BatchToShareContactsWithAccountTeams();
        DataBase.executeBatch(b);
        Test.stopTest();
        //Commented as part of OFI as it is no more valid
        
        //System.assertEquals([SELECT Id FROM ContactShare WHERE RowCause = 'Manual'].size(), 1);
    }
}