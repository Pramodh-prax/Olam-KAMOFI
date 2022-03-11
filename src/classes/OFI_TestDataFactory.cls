@isTest
public class OFI_TestDataFactory{
    
    Public static User createUser(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u;
        System.runAs (thisUser) {
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'test role');
            insert r;
            
            u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Dairy Sales'].Id,
                LastName = 'UnitTestUser1',
                Email = 'unittestuser000@unittestuser.com',
                Username = 'unittestuser000@unittestuser.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = r.Id
            );    
            insert u;
        }
        return u;
    }
    public Static Account createAccount(Boolean bInsert){
        Account acc = new Account();
        acc.name='Test01';
        acc.BillingCountry = 'India';
        acc.BillingStreet ='Test';
        //acc.Segment__c = 'Agent/ Distributor';
        acc.Regions__c ='APAC';
        acc.Customer_Group__c = 'Nestle';
        if(bInsert){
            insert acc;
        }
        return acc;
    }
    //Added by Ashwini Godase
    public Static Account createMultipleAccount(String name,String Country,String CountryCode,String Region,String Customergrp,String channel,Boolean bInsert){
        Account acc = new Account();
        acc.name=name;
        acc.BillingCountry = Country;
        acc.BillingCountryCode=CountryCode;
        acc.BillingStreet ='Test';
        //acc.Segment__c = 'Agent/ Distributor';
        acc.Regions__c =Region;
        acc.Customer_Group__c =Customergrp;
        acc.Channel__c=channel;
        if(bInsert){
            insert acc;
        }
        return acc;
    }
    public Static Opportunity createOpportunity(Account acc, Id pricebookId, Boolean bInsert ){
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Briefing';
        opp.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId();
        opp.CloseDate = System.today();
        opp.Business_Unit__c = 'Cocoa';
        //opp.Application__c = 'Agent/ Distributor';
        opp.Pricebook2Id = pricebookId;
        opp.CurrencyIsoCode = 'USD';
        if(bInsert){
            insert opp;
        }
        return opp;
    }
    //Added by Sameer
    public Static Interactions__c createInteraction(ID accountId, String BU, Boolean bInsert ){
        Interactions__c inter = new Interactions__c();
        inter.Account__c = AccountId;
        inter.Business_Unit__c = BU;
        inter.Name = 'Demo Interaction';
        if(bInsert){
            insert inter;
        }
        return inter;
    }
    //Added by Sameer
    public Static Consumption__c createConsumption(ID accountId, String BU, Double volume, Boolean bInsert ){
        Consumption__c consume = new Consumption__c();
        consume.Account__c = AccountId;
        consume.Business_Unit__c = BU;
        consume.Volume_MT__c = volume;
        if(bInsert){
            insert consume;
        }
        return consume;
    }
    //Added by Sameer
    public Static Budget_vs_Actuals__c createBudget(ID accountId, String BU, Boolean bInsert ){
        Budget_vs_Actuals__c budget = new Budget_vs_Actuals__c();
        budget.Account__c = AccountId;
        budget.Business_Unit__c = BU;
        budget.Name = 'Demo Budget';
        if(bInsert){
            insert budget;
        }
        return budget;
    }
    //Added by Sameer
    public Static Engagement_Plan__c createEngagementPlan(ID accountId, String BU, Boolean bInsert ){
        Engagement_Plan__c engPlan = new Engagement_Plan__c();
        engPlan.Account__c = AccountId;
        engPlan.Business_Unit__c = BU;
        engplan.Name = 'Demo Engagement Plan';
        if(bInsert){
            insert engPlan;
        }
        return engPlan;
    }
    //Added by Sameer
    public Static Account_Plans__c createAccountPlan(ID accountId, String BU, Boolean bInsert ){
        Account_Plans__c accPlan = new Account_Plans__c();
        accPlan.Account__c = AccountId;
        accPlan.BU_Identifier__c = BU;
        accPlan.Name = 'Demo Account Plan';
        if(bInsert){
            insert accPlan;
        }
        return accPlan;
    }
    public Static Access_Set__c createAccessSet(String grantAccessBy, String region, String Country, String BU, String productCategory, String customerGroup, String Channel, Boolean bInsert){
        Access_Set__c acSet = new Access_Set__c();
        acSet.Grant_Access_By__c = grantAccessBy; //'Region'
        acSet.Region__c = region; //'APAC'
        acSet.Country__c = country; //India;
        acSet.BU__c = BU; //'All';
        acSet.Product_Category__c = productCategory;
        acSet.Customer_Group__c = customerGroup; //'Nestle'
        acSet.Channel__c = channel;
        if(bInsert){
            insert acSet;
        }
        return acSet;
    }
   /* public Static Access_Set_Assignment__c createAccessSetAssignment(ID accessSetID, ID userID,  Boolean bInsert){
        Access_Set_Assignment__c acSetAsgnment = new Access_Set_Assignment__c();
        acSetAsgnment.Access_Set__c = accessSetID;
        acSetAsgnment.User__c = userID;
        
        if(bInsert){
            insert acSetAsgnment;
        }
        return acSetAsgnment;
    }*/
  /*  Public static Teams__c createAccountTeam(ID accountId, Id userId, String BU, String AccessLevel, Boolean bInsert){
        Teams__c team = new Teams__c();
        team.Account__c = accountId;
        Team.User__c = userId;
        team.Business_Unit__c = BU;
        team.Access_Level__c = AccessLevel; //SharingUtility.TEAMS_READ_ACCESS;
        //team.Access_Set_Ids__c = accessSet.Id;
        
        if(bInsert){
            insert team;
        }
        return team;
    }*/
//Added by ashwini
//updated by sam for no role
Public static Teams__c createAccountTeam(ID accountId, Id userId, String BU, String AccessLevel,//String Role,
                                         Boolean Primary,Boolean bInsert){
        Teams__c team = new Teams__c();
        team.Account__c = accountId;
        Team.User__c = userId;
        team.Business_Unit__c = BU;
        team.Is_Primary__c=Primary;
        team.Access_Level__c = AccessLevel; 
        //team.Access_Set_Role__c=Role;
        
        if(bInsert){
            insert team;
        }
        return team;
    }
    //updated by sam for no role
     public Static Access_Set_Assignment__c createAccessSetAssignment(ID accessSetID, ID userID,//String Role, 
                                                                      Boolean bInsert){
        Access_Set_Assignment__c acSetAsgnment = new Access_Set_Assignment__c();
        acSetAsgnment.Access_Set__c = accessSetID;
        acSetAsgnment.User__c = userID;
         //acSetAsgnment.Role__c=Role;
        
        if(bInsert){
            insert acSetAsgnment;
        }
        return acSetAsgnment;
    }

}