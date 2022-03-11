@isTest
public class KAM_AccountPlanOverviewCntlTest {
    @isTest 
    static void testGetAccountPlanSections () {
        string res = KAM_AccountPlanOverviewCntl.getAccountPlanSections ('Individual');
        System.assert(res != null, 'Unable to find the account plan sections');
        List<Account_Plan_Overview_Component__mdt> metaDataRecords 
            = (List<Account_Plan_Overview_Component__mdt>) JSON.deserialize(res, List<Account_Plan_Overview_Component__mdt>.class);
        System.assert(metaDataRecords.size () > 0, 'metaDataRecords List is empty');
    }
    @isTest 
    static void testGetDetails () {
        string res = KAM_AccountPlanOverviewCntl.getAccountPlanSections ('Individual');
        System.assert(res != null, 'Unable to find the account plan sections');
        List<Account_Plan_Overview_Component__mdt> metaDataRecords 
            = (List<Account_Plan_Overview_Component__mdt>) JSON.deserialize(res, List<Account_Plan_Overview_Component__mdt>.class);
        System.assert(metaDataRecords.size () > 0, 'metaDataRecords List is empty');
        
        res = KAM_AccountPlanOverviewCntl.getDetails(JSON.serialize(metaDataRecords[0]), null);
    }
    
    @isTest 
    static void getDetailsException () {
        string res = KAM_AccountPlanOverviewCntl.getAccountPlanSections ('Individual');
        System.assert(res != null, 'Unable to find the account plan sections');
        List<Account_Plan_Overview_Component__mdt> metaDataRecords 
            = (List<Account_Plan_Overview_Component__mdt>) JSON.deserialize(res, List<Account_Plan_Overview_Component__mdt>.class);
        System.assert(metaDataRecords.size () > 0, 'metaDataRecords List is empty');
       
        metaDataRecords[0].ApexClass__c = null;
        Boolean exceptionThrown = false;
        try {
         	res = KAM_AccountPlanOverviewCntl.getDetails(JSON.serialize(metaDataRecords[0]), null);   
        } catch (Exception e) {
            exceptionThrown =  true;
        } finally {
         	System.assert(exceptionThrown, 'Expected an exception to be thrown, but there was no exception ');
        }
    }
}