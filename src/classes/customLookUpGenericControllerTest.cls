@isTest
public class customLookUpGenericControllerTest {
    @testsetup
    public static void getData() {
        //Id oppRecordTNMId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        
        Account acc = new Account();
        acc.name='Test Account';
        acc.BillingCountry = 'India';
        //acc.Operating_Geographics__c ='Test';
        acc.BillingStreet ='Test';
        insert acc;
    }    
    public static testmethod void fetchLookUpValues_Test()
    {
        customLookUpGenericController.fetchLookUpValues('Test Account', 'Account');
    }
}