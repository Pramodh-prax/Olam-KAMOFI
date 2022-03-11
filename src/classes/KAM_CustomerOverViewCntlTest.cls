@isTest
public class KAM_CustomerOverViewCntlTest {
    
    @testSetup
    static void createMetaData () {
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
    }
    
    @isTest 
    static void getDetails () {
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'CustomerOverview\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find CustomerOverview component details ' );
        String res = KAM_AccountPlanOverviewCntl.getDetails(JSON.serialize(accountPlanMetaData[0]), null);
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        System.assert(resultMap.containsKey ('fields'), 'Unable to find field set wrapper');
        
        List<FieldWrapper> fieldWrapper = (List<FieldWrapper>)JSON.deserialize(JSON.serialize(resultMap.get ('fields')), List<FieldWrapper>.class );
        System.assert(!fieldWrapper.isEmpty (), 'Field api names list is empty');
    }
    @isTest 
    static void getDetailsException () {
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'CustomerOverview\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find CustomerOverview component details ' );
        accountPlanMetaData[0].ApexClass__c = null;
        Boolean exceptionThrown = false;
        try {
         	String res = KAM_AccountPlanOverviewCntl.getDetails(JSON.serialize(accountPlanMetaData[0]), null);   
        } catch (Exception e) {
            exceptionThrown =  true;
        } finally {
         	System.assert(exceptionThrown, 'Expected an exception to be thrown, but there was no exception ');
        }
    }
}