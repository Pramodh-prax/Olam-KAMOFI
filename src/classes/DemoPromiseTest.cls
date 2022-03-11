/*
 * credits @capeterson github
 * */
@isTest
public with sharing class DemoPromiseTest {
    
    @TestSetup
    static void makeData(){
        Account account = new Account(
            name = 'TestAccount',
            ShippingStreet = '0',
            BillingCountryCode = 'IN'  
        );
        insert account;
    }
    
    @isTest
    private static void testCase0(){
        Account account = [SELECT Id FROM Account WHERE name = 'TestAccount' LIMIT 1];
        Test.startTest();
        DemoPromise dp = new DemoPromise(account.id);
        dp.passthrough = (Integer) 0;
        dp.promises = new List<Promise>{new DemoPromise(account.id), new DemoPromise(account.id)};
        System.enqueueJob(dp);
        Test.stopTest();
        
        Account checkAccount = [SELECT ShippingStreet, billingStreet FROM Account WHERE id = :account.id LIMIT 1];
        System.assertEquals(3, Integer.valueOf(checkAccount.shippingStreet), 
                            'Expected 3 instances of the queuable to have been run, each incrementing by 1');
        /*
         * this test assertion might be invalid because in test context it will run only once 
        System.assertEquals(3, Integer.valueOf(checkAccount.billingStreet), 
                            'Expected 3 instances of the queuable to have been run, each incrementing by 1');
		*/
    }
    
    @isTest
    private static void testCase1ThenTest(){
        Account account = [SELECT Id FROM Account WHERE name = 'TestAccount' LIMIT 1];
        Test.startTest();
        DemoPromise dp = new DemoPromise(account.id);
        dp.passthrough = (Integer) 0;
        dp.then(new DemoPromise(account.id))
            .then(new DemoPromise(account.id));
        System.enqueueJob(dp);
        Test.stopTest();
        
        Account checkAccount = [SELECT ShippingStreet, billingStreet FROM Account WHERE id = :account.id LIMIT 1];
        System.assertEquals(3, Integer.valueOf(checkAccount.shippingStreet), 
                            'Expected 3 instances of the queuable to have been run, each incrementing by 1');
    }
    
    @isTest
    private static void testCase2promiseListConstructorTest(){
        Account account = [SELECT Id FROM Account WHERE name = 'TestAccount' LIMIT 1];
        Test.startTest();
        DemoPromise dp = new DemoPromise(account.id, new List<Promise>{new DemoPromise(account.id), new DemoPromise(account.id)});
        System.enqueueJob(dp);
        Test.stopTest();
        
        Account checkAccount = [SELECT ShippingStreet FROM Account WHERE id = :account.id LIMIT 1];
        System.assertEquals(3, Integer.valueOf(checkAccount.shippingStreet), 
                            'Expected 3 instances of the queuable to have been run, each incrementing by 1');
    }
    
    @isTest
    private static void testCase3ExceptionTest(){
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            DemoPromise dp = new DemoPromise(null);
            System.enqueueJob(dp);
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown =  true;
        } finally {
            List<KAM_Queuable_Error_Log__c> errors = [SELECT Id, Result__c FROM KAM_Queuable_Error_Log__c LIMIT 1];
            System.assert(errors.size() > 0, 'Exception log not captured');
            System.assertEquals(String.valueOf (System.ParentJobResult.UNHANDLED_EXCEPTION), errors[0].Result__c, 'Mismatch in result');
            System.assert(exceptionThrown, 'Expected an exception to be thrown, but there was no exception ');
        }
    }
}