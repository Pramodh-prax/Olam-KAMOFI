public class BudgetOwnerService{
    List<Teams__c> teamsList = new List<Teams__c>();
    Map<Id, Map<String, Id>> accountBUPrimaryUserMap = new Map<Id, Map<String, Id>>();
    Map<Id, Map<String, List<Budget_vs_Actuals__c>>> accountBUBudgetMap = new Map<Id, Map<String, List<Budget_vs_Actuals__c>>>();
    List<Budget_vs_Actuals__c> bugetRecordsToUpdate = new List<Budget_vs_Actuals__c>();
    
    
    public BudgetOwnerService(List<Teams__c> teamsList){
        this.teamsList = teamsList;
    }
    
    
    public void changeBudgetRecordOwner(){
        createAccountBUPrimaryUserMap();
        if(accountBUPrimaryUserMap.size() > 0){
            getAccountBUBudgetMap();
            getBudgetRecordsToUpdateOwner();
            updateBudgetRecords();
        }
    }
    
    
    public void createAccountBUPrimaryUserMap(){
        for(Teams__c team :teamsList){
            if(team.Is_Primary__c){
                if(accountBUPrimaryUserMap.containsKey(team.Account__c)){
                    accountBUPrimaryUserMap.get(team.Account__c).put(team.BU__c, team.User__c);
                }
                else{
                    accountBUPrimaryUserMap.put(team.Account__c, new Map<String, Id>{team.BU__c => team.User__c});
                }
            }
        }
    }
    
    
    public void getAccountBUBudgetMap(){
        for(Budget_vs_Actuals__c budget :[SELECT Id, Account__c, Business_Unit__c, OwnerId FROM Budget_vs_Actuals__c WHERE Account__c IN :accountBUPrimaryUserMap.keySet()]){
            if(accountBUBudgetMap.containsKey(budget.Account__c)){
                if(accountBUBudgetMap.get(budget.Account__c).containsKey(budget.Business_Unit__c)){
                    accountBUBudgetMap.get(budget.Account__c).get(budget.Business_Unit__c).add(budget);
                }
                else{
                    accountBUBudgetMap.get(budget.Account__c).put(budget.Business_Unit__c, new List<Budget_vs_Actuals__c>{budget});
                }
                
            }
            else{
                accountBUBudgetMap.put(budget.Account__c, new Map<String, List<Budget_vs_Actuals__c>>{budget.Business_Unit__c => new List<Budget_vs_Actuals__c>{budget}});
            }
        }
    }
    
    
    public void getBudgetRecordsToUpdateOwner(){
        for(Id accId :accountBUPrimaryUserMap.keySet()){
            for(String bu :accountBUPrimaryUserMap.get(accId).keySet()){
                if(accountBUBudgetMap.containsKey(accId) && accountBUBudgetMap.get(accId).containsKey(bu)){
                    for(Budget_vs_Actuals__c budgetRecord: accountBUBudgetMap.get(accId).get(bu)){
                        budgetRecord.OwnerId = accountBUPrimaryUserMap.get(accId).get(bu);
                        bugetRecordsToUpdate.add(budgetRecord);
                    }    
                }
            }
        }
    }
    
    
    public void updateBudgetRecords(){
        if(bugetRecordsToUpdate.size() > 0){
            update bugetRecordsToUpdate;
        }
    }     
}