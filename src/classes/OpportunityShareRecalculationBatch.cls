public class OpportunityShareRecalculationBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id, Business_Unit__c, AccountId, OwnerId FROM Opportunity');
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> oppList){
        //Commented as part of OFI as it is no more valid
        
        /*for(Opportunity opp :oppList){
            OpportunityShareService.recalculateSharingForOpportunities(opp.Id, opp.AccountId, opp.Business_Unit__c, opp.OwnerId);
        }*/
    }
    
    public void finish(Database.BatchableContext BC){
    }
}