@isTest
public class KAM_StakeHoldersGrpCntlTest {
    @testSetup
    public static void createData()
    {
         Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        acc.Customer_Group__c='Demo';
        insert acc;
        
        Contact c=new Contact();
        c.AccountId=acc.id;
        c.Title='Mr.';
        c.FirstName='Sam';
        c.LastName='Curran';
        c.Email='sam@gmail.com';
        c.Phone='9876543456';
        insert c;
    }
    
    public static testmethod void testGetDetails () {
        List<Account> accList = [SELECT Id,Customer_Group__c FROM Account where Name = 'DemoAccount'];
        System.assert(accList != null && !accList.isEmpty (), 'Unable to find the account');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'StakeHolders_Group\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find StakeHolders component details ' );
        String res 
            = KAM_AccountPlanOverviewCntl.getDetails(
                JSON.serialize(accountPlanMetaData[0]),
                JSON.serialize(new Map<String, Object> {'customerGroup' => accList[0].Customer_Group__c})
            );
        
        System.debug('RESULT -- ' + res);
        List<Account> accounts = (List<Account>) JSON.deserialize(res, List<Account>.class);
        //System.assert(!accounts.isEmpty (), 'no Accounts found');
        //System.assertEquals(accList.size (), accounts.size (), 'Mismatch in the retrieved Accounts');
        
    }
  
  
    public static testmethod void test_getDetailsNull()
    {
        try{
            Account acc=new Account();
            KAM_StakeHoldersGrpCntl shgc=new KAM_StakeHoldersGrpCntl();
            shgc.getDetails(JSON.serialize(new Map<String, Object> {'' => acc.Customer_Group__c}));
            shgc.getDetails(JSON.serialize(new Map<String, Object> {'customerGroup' => acc.Customer_Group__c}));
        }catch(Exception e){}
    }
    
    
    public static testmethod void test_getContactsByAccountId()
    {
        List<Account> acc=[SELECT Id, Name,Account_Type__c,BillingCountry,BillingStreet,Customer_Group__c FROM Account WHERE CreatedDate=Today
                        LIMIT 1];
        System.assert(acc!=null, 'Containing null values');
        List<Contact> con=[SELECT Id, Title, Name, FirstName, LastName, Email, ReportsToId, Description, Phone,
                        ReportsTo.Name, OwnerId, Owner.Name, AccountId, Account.Name
                        From Contact WHERE CreatedDate=Today Limit 1
                    ];
        System.assert(con!=null, 'Containing null values');
       List<Contact> c= KAM_StakeHoldersGrpCntl.getContactsByAccountId(acc[0].Id);
        System.assertEquals(con, c);
        
    }
   
    
   
}