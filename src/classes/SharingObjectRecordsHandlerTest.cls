@isTest
public class SharingObjectRecordsHandlerTest {
@testSetup
    public static void createData()
{
    Account acc = OFI_TestDataFactory.createAccount(true);
    Pricebook2 pb = new Pricebook2(Name = 'All Price Book', IsActive = true);
    Opportunity opp = OFI_TestDataFactory.createOpportunity(acc, pb.Id, true);
    //Interactions__c inter = OFI_TestDataFactory.createInteraction(acc.Id, 'Cocoa', true);
    Consumption__c consume = OFI_TestDataFactory.createConsumption(acc.Id, 'Cocoa', 12, true);
    Budget_vs_Actuals__c budget = OFI_TestDataFactory.createBudget(acc.Id, 'Cocoa', true);
    Engagement_Plan__c engPlan = OFI_TestDataFactory.createEngagementPlan(acc.Id, 'Cocoa', true);
    Account_Plans__c accPlan = OFI_TestDataFactory.createAccountPlan(acc.Id, 'Cocoa', true);
    Access_Set__c access = OFI_TestDataFactory.createAccessSet('Country', null, 'IN', 'All', null, 'Nestle', null, true);
    Access_Set_Assignment__c assign = OFI_TestDataFactory.createAccessSetAssignment(access.Id, userInfo.getUserId(),//'PDI' ,
                                                                                    true);
    Teams__c team = OFI_TestDataFactory.createAccountTeam(acc.Id, userInfo.getUserId(), 'All', 'Edit Access',//'PDI',
                                                          true, true);
}
    public static testmethod void shareOpportunitiesWithAccountTeams_Test()
    {
        Map<Id,Opportunity> mapOfNewRecords = new Map<Id,Opportunity>();
        List<Opportunity> opp = [Select Id, Name, AccountId, Business_Unit__c,OwnerId From Opportunity];
        if(!opp.isEmpty()){
        for(Opportunity opportunity : opp)
        {
         mapOfNewRecords.put(opportunity.AccountId,opportunity);
        }
        SharingObjectRecordsHandler.shareOpportunitiesWithAccountTeams(mapOfNewRecords);
        }
    }
    public static testmethod void shareInteractionsWithAccountTeams_Test()
    {
        Map<Id,Interactions__c> mapOfNewRecords = new Map<Id,Interactions__c>();
        List<Interactions__c> inter = [Select Id, Name, Account__c, Business_Unit__c, OwnerId From Interactions__c];
        //System.debug('account====>'+inter[0].Account__c);
        if(!inter.isEmpty()){
        for(Interactions__c inter1 : inter)
        {
         mapOfNewRecords.put(inter1.Account__c,inter1);
        }
        SharingObjectRecordsHandler.shareInteractionsWithAccountTeams(mapOfNewRecords);
        }
    }
    public static testmethod void shareConsumptionsWithAccountTeams_Test()
    {
        Map<Id,Consumption__c> mapOfNewRecords = new Map<Id,Consumption__c>();
        List<Consumption__c> consume = [Select Id, Name, Account__c, Business_Unit__c, OwnerId, Volume_MT__c From Consumption__c];
        if(!consume.isEmpty()){
        for(Consumption__c con : consume)
        {
         mapOfNewRecords.put(con.Account__c,con);
        }
        SharingObjectRecordsHandler.shareConsumptionsWithAccountTeams(mapOfNewRecords);
        }
    }
    public static testmethod void shareBudgetsWithAccountTeams_Test()
    {
        Map<Id,Budget_vs_Actuals__c> mapOfNewRecords = new Map<Id,Budget_vs_Actuals__c>();
        List<Budget_vs_Actuals__c> budget = [Select Id, Name, Account__c, Business_Unit__c, OwnerId From Budget_vs_Actuals__c];
        if(!budget.isEmpty()){
        for(Budget_vs_Actuals__c bud : budget)
        {
         mapOfNewRecords.put(bud.Account__c,bud);
        }
        SharingObjectRecordsHandler.shareBudgetsWithAccountTeams(mapOfNewRecords);
        }
    }
    public static testmethod void shareEngPlansWithAccountTeams_Test()
    {
        Map<Id,Engagement_Plan__c> mapOfNewRecords = new Map<Id,Engagement_Plan__c>();
        List<Engagement_Plan__c> engPlan = [Select Id, Name, Account__c, Business_Unit__c, OwnerId From Engagement_Plan__c];
        if(!engPlan.isEmpty()){
        for(Engagement_Plan__c ep : engPlan)
        {
         mapOfNewRecords.put(ep.Account__c,ep);
        }
        SharingObjectRecordsHandler.shareEngPlansWithAccountTeams(mapOfNewRecords);
        }
    }
    public static testmethod void shareAccountPlansWithAccountTeams_Test()
    {
        Map<Id,Account_Plans__c> mapOfNewRecords = new Map<Id,Account_Plans__c>();
        List<Account_Plans__c> accPlan = [Select Id, Name, Account__c, OwnerId, BU_Identifier__c From Account_Plans__c];
        if(!accPlan.isEmpty()){
        for(Account_Plans__c ap : accPlan)
        {
         mapOfNewRecords.put(ap.Account__c,ap);
        }
        SharingObjectRecordsHandler.shareAccountPlansWithAccountTeams(mapOfNewRecords);
        }
    }
}