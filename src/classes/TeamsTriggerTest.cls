@isTest(SeeAllData=false)
public class TeamsTriggerTest {
	
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
    
    
    //Trying to add another primary user
    @isTest static void testOne() {
    	User usr1 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com1'];
        User usr2 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com2'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test01' LIMIT 1];
        
        System.runAs(usr1){
            try{
                Teams__c team = new Teams__c(
                    Account__c = acc.Id,
                    User__c = usr2.Id,
                    User_Role_Name__c = 'Cocoa Sales Manager',
                    Role_Name__c = 'Cocoa Sales Manager',
                    Is_Primary__c = true
                );
                insert team;
            }
            catch(Exception e){}
        }
    }
    
    
    //Trying to add another non primary user
    @isTest static void testTwo() {
    	User usr1 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com1'];
        User usr2 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com2'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test01' LIMIT 1];

        //JOEL - Added the below assignment since line 74 is giving error as the user trying to insert is not primary
         Teams__c team1 = new Teams__c(
                Account__c = acc.Id,
                User__c = usr1.Id,
                User_Role_Name__c = 'Cocoa Sales Manager',
                Role_Name__c = 'Cocoa Sales Manager',
                Is_Primary__c = true,
             	Business_Unit__c  = 'All'
            );
            insert team1;
        
        
        System.runAs(usr1){
            Test.startTest();
            Teams__c team = new Teams__c(
                Account__c = acc.Id,
                User__c = usr2.Id,
                User_Role_Name__c = 'Cocoa Sales Manager',
                Role_Name__c = 'Cocoa Sales Manager',
                Is_Primary__c = false,
             	Business_Unit__c  = 'Cocoa'
            );
            insert team;
            Test.stopTest();
            System.assertEquals([SELECT Id FROM Teams__c].size(), 2);
        }
    }
    
    
    //Trying to add another primary user as admin
    @isTest static void testThree() {
    	User usr1 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com1'];
        User usr2 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com2'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test01' LIMIT 1];
        
        try{
            Teams__c team = new Teams__c(
                Account__c = acc.Id,
                User__c = usr2.Id,
                User_Role_Name__c = 'Cocoa Sales Manager',
                Role_Name__c = 'Cocoa Sales Manager',
                Is_Primary__c = true
            );
            insert team;
        }catch(Exception e){}
    }
    
    
    //Trying to add another non primary user as admin
    @isTest static void testFour() {
    	User usr1 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com1'];
        User usr2 = [SELECT Id FROM User WHERE UserName = 'olam.test@test.olam.com2'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test01' LIMIT 1];
        
        Test.startTest();
        try{
            Teams__c team = new Teams__c(
                Account__c = acc.Id,
                User__c = usr2.Id,
                User_Role_Name__c = 'Cocoa Sales Manager',
                Role_Name__c = 'Cocoa Sales Manager',
                Is_Primary__c = false
            );
            insert team;
        }
        catch(Exception e){}
        
        Test.stopTest();
    }
}