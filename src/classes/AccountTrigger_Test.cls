@isTest(SeeAllData=false)
public class AccountTrigger_Test{

    @testSetup public static void setup() {
        PostalCodeValidation__c postal1 = new PostalCodeValidation__c(Name='IN',Format__c ='\\d{6}', Error_Message__c='Postal Code for India should be in the format NNNNNN');
        PostalCodeValidation__c postal2 = new PostalCodeValidation__c(Name='BD',Format__c ='\\d{4}', Error_Message__c='Postal Code for India should be in the format NNNN');
        insert postal1;
        insert postal2; 
    }
    
    @isTest
    static void testValidScenario() {
        Account acc1 = new Account(Name = 'UNIT TEST account1', BillingCity='TestIndia', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', BillingPostalCode = '123456' , ShippingStreet = 'Test 2 street', ShippingCountry = 'India', ShippingCountryCode ='IN', ShippingPostalCode = '123456');
        Account acc2 = new Account(Name = 'UNIT TEST account2', BillingCity='TestIndia', BillingStreet = 'Test 1 street', BillingCountry = 'Bangladesh', BillingCountryCode ='BD', BillingPostalCode = '1234' , ShippingStreet = 'Test 2 street', ShippingCountry = 'India', ShippingCountryCode ='IN', ShippingPostalCode = '123456');

        List<Account> accounts = new List<Account>{acc1, acc2}; 
        
        Test.startTest();
        insert accounts;
        test.stopTest();
    }

    @isTest
    static void testValid() {
        Account acc1 = new Account(Name = 'UNIT TEST account1', BillingCity='TestIndia', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', BillingPostalCode = '1234' , ShippingStreet = 'Test 2 street', ShippingCountry = 'India', ShippingCountryCode ='IN', ShippingPostalCode = '12456');
        Account acc2 = new Account(Name = 'UNIT TEST account2', BillingCity='TestIndia', BillingStreet = 'Test 1 street', BillingCountry = 'Bangladesh', BillingCountryCode ='BD', BillingPostalCode = '122234' , ShippingStreet = 'Test 2 street', ShippingCountry = 'India', ShippingCountryCode ='IN', ShippingPostalCode = '1253456');

        List<Account> accounts = new List<Account>{acc1, acc2}; 
        
        Test.startTest();
        try{
            insert accounts;}
        catch(Exception e){}
         
        test.stopTest();
    }


}