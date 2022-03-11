public class BudgetLineConsumptionLinkBatch implements Database.Batchable<sObject>{
    
    public String year;
    
    
    public BudgetLineConsumptionLinkBatch(String year){
        this.year = year;
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM Budget_vs_Actual_Line__c WHERE Budget_vs_Actuals__r.Year__c = :year');
    }
    
    
    public void execute(Database.BatchableContext BC, List<Budget_vs_Actual_Line__c> records){
        BudgetActualLineTriggerHandler budgetTriggerHanlder = new BudgetActualLineTriggerHandler();
        budgetTriggerHanlder.updateConsumptions(records);
    }
    
    
    public void finish(Database.BatchableContext BC){
    }
}