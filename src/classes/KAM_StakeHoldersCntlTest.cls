@isTest
public class KAM_StakeHoldersCntlTest {
    
    @testSetUp
    static void createData () 
    {
        Account acc=new Account();
        acc.Name='NewAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Surat-Mumbai road';
        insert acc;
        
        Contact con=new Contact();
        con.AccountId=acc.Id;
        con.Title='Technical Specialist';
        con.FirstName='Tim';
        con.LastName='Cook';
        con.Email='abc@gmail.com';
        con.Description='This is a test data';
        con.Phone='9876543658';
        insert con;
    }
    
    @isTest 
    static void testGetDetails () {
        List<Account> accList = [SELECT Id, (SELECT Id, Name From Contacts) FROM Account where Name = 'NewAccount'];
        System.assert(accList != null && !accList.isEmpty (), 'Unable to find the account');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'StakeHolders\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find StakeHolders component details ' );
        String res 
            = KAM_AccountPlanOverviewCntl.getDetails(
                JSON.serialize(accountPlanMetaData[0]),
                JSON.serialize(new Map<String, Object> {'accountId' => accList[0].Id})
            );
        
        List<Contact> contacts = (List<Contact>) JSON.deserialize(res, List<Contact>.class);
        System.assert(!contacts.isEmpty (), 'no contacts found');
        System.assertEquals(accList[0].Contacts.size (), contacts.size (), 'Mismatch in the retrieved contacts');
        
    }
    
    @isTest
    static void testGetDetailsNullParam () {
        List<Account> accList = [SELECT Id, (SELECT Id, Name From Contacts) FROM Account where Name = 'NewAccount'];
        System.assert(accList != null && !accList.isEmpty (), 'Unable to find the account');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'StakeHolders\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find StakeHolders component details ' );
        String res 
            = KAM_AccountPlanOverviewCntl.getDetails(
                JSON.serialize(accountPlanMetaData[0]),
                JSON.serialize(new Map<String, Object> {'acountId' => accList[0].Id})
            );
        System.assert(res == null, 'Expected an null value, but actual contacts string returned');

        List<Contact> contacts = KAM_StakeHoldersCntl.getContactsByAccountId (null);
        System.assert(contacts == null, 'Expected an null value, but actual contacts string returned');
    }
    @isTest 
    static void testGetDetailsException () {
        
        List<Account> accList = [SELECT Id, (SELECT Id, Name From Contacts) FROM Account where Name = 'NewAccount'];
        System.assert(accList != null && !accList.isEmpty (), 'Unable to find the account');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'StakeHolders\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find StakeHolders component details ' );
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


/*
* public static testmethod void test_getContactsByAccountId()
{
Account acc=[select Account_ID__c,id,name from Account where CreatedDate = TODAY limit 1];
Account acc2=new Account();
List<Contact> con=[SELECT Id, Title, Name, FirstName, LastName, Email, ReportsToId, Description, Phone,
ReportsTo.Name, OwnerId, Owner.Name
From Contact WHERE AccountId =: acc.Id and CreatedDate = today
limit 1
];
System.debug('AccountID=========>'+acc);
List<Contact> result= KAM_StakeHoldersCntl.getContactsByAccountId(acc.Id);
System.assertEquals(con, result);
system.assertEquals(result.size(), 1);
System.assertEquals(con[0].LastName, result[0].LastName);

//System.debug('Expected========>'+con);

KAM_StakeHoldersCntl.getContactsByAccountId(null);
//KAM_StakeHoldersCntl.getContactsByAccountId('123');


String data ='{"accountId":"0011s00000tVOajAAG","PlanType":"Individual","BusinessUnit":"Dairy"}';


KAM_StakeHoldersCntl stake=new KAM_StakeHoldersCntl();
String res=stake.getDetails(data);
//System.debug(res);
//System.assert(resultMap.containskey('id'), 'Invalid id');
stake.getDetails(JSON.serialize(acc2));



}*/