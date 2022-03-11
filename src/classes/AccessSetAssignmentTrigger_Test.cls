@isTest
public class AccessSetAssignmentTrigger_Test {
@testSetup
    public static void createData()
{
    Access_Set__c access1 = new Access_Set__c(Grant_Access_By__c = 'Region',BU__c = 'All' , Region__c = 'APAC' , Customer_Group__c = 'TH' , Channel__c = 'Trade House');
        insert access1;
    Access_Set_Assignment__c assign = OFI_TestDataFactory.createAccessSetAssignment(access1.Id, UserInfo.getUserId(),//'Sales',
                                                                                    true);
}
public static testmethod void data()
{
    Access_Set_Assignment__c assign = [Select Id, Name, User__c, Access_Set__c From Access_Set_Assignment__c];
    try{
        delete assign;
    }Catch(Exception e){}
}
}