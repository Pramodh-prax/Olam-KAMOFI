@isTest
public class AccessSetTrigger_Test {
@testSetup
    public static void createData()
{
        Profile prof = [select id from profile where name='System Administrator'];
        User user1 = new User(alias = 'aksh', email='aksh@noemail.com',
                              emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = prof.Id,
                              timezonesidkey='America/Los_Angeles',//Access_Set_Role__c='PDI', 
                              username='aksh@noemail.com');
        insert user1; 
        Access_Set__c access1 = new Access_Set__c(Grant_Access_By__c = 'Region',BU__c = 'All' , Region__c = 'APAC' , Customer_Group__c = 'TH' , Channel__c = 'Trade House');
        insert access1;
        Access_Set_Assignment__c accsetass=OFI_TestDataFactory.createAccessSetAssignment(access1.Id, user1.id,//'PDI',
                                                                                         true);
        
}
public static testmethod void data()
{
    Access_Set__c access = [Select Id, Name, BU__c, Region__c, Customer_Group__c, Channel__c From Access_Set__c];
    //updated by Ashwini Godase 1/18/22
     try{
     delete access;
    }
    catch(DMLException ex){
}

}
}