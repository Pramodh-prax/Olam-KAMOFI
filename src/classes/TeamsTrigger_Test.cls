@isTest
public class TeamsTrigger_Test {
    
    @testSetUp
    static void createData () {
        Profile p = [select id from profile where name='System Administrator'];
        Profile profOfi = [select id from profile where name='OFI'];
        User user1 = new User(alias = 'aksh', email='aksh@noemail.com',
                              emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = p.Id,
                              timezonesidkey='America/Los_Angeles',//Access_Set_Role__c='Sales',
                              username='aksh@noemail.com');
        insert user1; 
        User u = new User(alias = 'jacksp', email='jacksp@noemail.com',
                          emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles',//Access_Set_Role__c='Sales',
                          username='jacksp@noemail.com');
        insert u; 
        
        User ofiuser = new User(alias = 'jack12', email='jack12@noemail.com',
                                emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = profOfi.Id,
                                timezonesidkey='America/Los_Angeles',// Access_Set_Role__c='Sales',
                                username='jack12@noemail.com');
        insert ofiuser;  
        Access_Set__c accset= OFI_TestDataFactory.createAccessSet('country', null, 'In','Spice', null, null, null, true);
        Account acc1 =OFI_TestDataFactory.createMultipleAccount('TEST account1', 'India','In', null, null, null, true);
        Account acc2 =OFI_TestDataFactory.createMultipleAccount('TEST123', 'India','In', null, null, null, true);
        Account acc3 =OFI_TestDataFactory.createMultipleAccount('TEST For BU ALL', 'India','In', null, null, null, true);
        Access_Set_Assignment__c accsetass=OFI_TestDataFactory.createAccessSetAssignment(accset.Id, user1.id,//'Sales',
                                                                                         true);
        Access_Set_Assignment__c accsetass1=OFI_TestDataFactory.createAccessSetAssignment(accset.Id, ofiuser.id,//'Sales',
                                                                                          true);
        Access_Set_Assignment__c accsetass2=OFI_TestDataFactory.createAccessSetAssignment(accset.Id, u.id,//'Sales',
                                                                                          true);
        Id accid= acc1.id;
        Teams__C team=OFI_TestDataFactory.createAccountTeam(accid, user1.id, 'Spice', 'Edit Access',//'Sales',
                                                            True, True);
        Teams__C team1=OFI_TestDataFactory.createAccountTeam(accid, u.id, 'Dairy', 'Read Access',//'Sales',
                                                             false, True);
        team1.Is_Primary__c=true;
        update team1;
         try{  
            delete  team1;
            }Catch(Exception e){}
    }
    
    @isTest
    static void AccountTeamMemberValidation() {
        test.startTest();
        User u1 = [select id from user where username='aksh@noemail.com'];
        User u = [select id from user where  username='jacksp@noemail.com'];
        User user1 = [select id from user where  username='jack12@noemail.com'];
        List<Account> acc=[select id from account];
        System.runAs(user1){  
            
            Id accid= acc[1].id;
            List<Teams__c> teamem=[select id from teams__c];
           
            try{
                teamem[0].User__c=u.id;
                update teamem[0];  
            }
            catch(DmlException e){}
            //Without Primary user trying to add team member
            try{
                Teams__C team=OFI_TestDataFactory.createAccountTeam(accid, u.id, 'Spice', 'Read Access',//'Sales', 
                                                                    False, True);
            }
            catch(DmlException e){}
            
            Teams__C teamInsertPrimary=OFI_TestDataFactory.createAccountTeam(accid, user1.id, 'Spice', 'Edit Access',//'Sales',
                                                                             True, True);
            
            //Insert Different team member 
            try{
                Teams__C team=OFI_TestDataFactory.createAccountTeam(accid, u.id, 'Spice', 'Read Access',//'Sales',
                                                                    False, True);   
                team.Business_Unit__c='Dairy';
                update team;
                
            } catch(DmlException e) {}
            //Primary Member Of Particular BU can Add/Edit Team Member of same BU
            try{
                Teams__C team=OFI_TestDataFactory.createAccountTeam(accid, u1.id, 'Cocoa', 'Read Access',//'Sales',
                                                                    True, True);   
            }
            catch(DmlException e){}
            //Only admin can uncheck the primary checkbox
            try{
                teamInsertPrimary.Is_Primary__c=false;
                update teamInsertPrimary;
                
            } catch(DmlException e) {}
        }
        test.stopTest();
    }
    
}