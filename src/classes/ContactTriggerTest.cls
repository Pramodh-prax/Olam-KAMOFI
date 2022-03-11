@isTest(SeeAllData=false)
public class ContactTriggerTest {
    
    @testSetup static void setupData() {
        UserRole r = [select id,name from UserRole where name LIKE '%Cocoa%' limit 1];
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
        }    
    }
    
    
    @isTest static void testOne() {
        User usr1 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com1'];
        //System.runAs(usr1){
        Test.startTest();
        //Insert contact
        Contact c = new Contact();
        c.LastName = 'test';
        c.AccountId = [SELECT Id FROM Account WHERE Name = 'Test01' LIMIT 1].id;
        c.Email = 'Test01@gmail.com.test';
        insert c;
        Test.stopTest();
        
        System.assertEquals([SELECT Id FROM ContactShare WHERE ContactId = :c.Id AND RowCause = 'Manual'].size(), 0);
        //} 
    }
    
    
    @isTest static void testTwo() {
        User usr1 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com1'];
        User usr2 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com2'];
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test01' LIMIT 1];
        
        //ADDED BY JOEL TO HANDLE ERROR THROWN FOR PRIMARY MEMBER IN LINE 66
        Teams__c team2 = new Teams__c(
                Account__c = acc.Id,
                User__c = usr1.Id,
                User_Role_Name__c = 'Cocoa Sales Manager',
                Role_Name__c = 'Cocoa Sales Manager',
                Is_Primary__c = TRUE,
            	Business_Unit__c = 'All'
            );
            insert team2;
        
        System.runAs(usr1){
            Teams__c team = new Teams__c(
                Account__c = acc.Id,
                User__c = usr2.Id,
                User_Role_Name__c = 'Cocoa Sales Manager',
                Role_Name__c = 'Cocoa Sales Manager',
                Is_Primary__c = false,
                Business_Unit__c = 'Cocoa'
            );
            insert team;
            
            Test.startTest();
            //Insert contact
            Contact c = new Contact();
            c.LastName = 'test';
            c.AccountId = acc.id;
            c.Email = 'Test01@gmail.com.test';
            insert c;
            Test.stopTest();
            
            System.assertEquals([SELECT Id FROM ContactShare WHERE ContactId = :c.Id AND RowCause = 'Manual'].size(), 0);
        } 
    }


	@isTest static void testThree() {
        User usr2 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com2'];
        
        //Test as non team member, throws exception
        System.runAs(usr2){
            Test.startTest();
            try{
                Contact c = new Contact();
                c.LastName = 'test';
                c.AccountId = [SELECT Id FROM Account WHERE Name = 'Test01' LIMIT 1].id;
                c.Email = 'Test01@gmail.com.test';
                insert c;
            }
            catch(Exception e){}
            
            Test.stopTest();
            
            System.assertEquals([SELECT Id FROM Contact].size(), 0);
        } 
    }    
}