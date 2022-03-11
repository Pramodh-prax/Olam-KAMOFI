public class KAM_AccountPlanPopupCntl {
//Method to fetch account plan for current account
    @AuraEnabled
    public static Account_Plans__c getAccountPlan(Id accountPlanId){
        Account_Plans__c accountPlanDetails = [Select Id,Name,Description__c,EndDate__c,
                                                StartDate__c,Type__c,BU_Identifier__c,Customer_Group__c,
                                                Year__c,Account__c 
                                                FROM Account_Plans__c
                                                WHERE Id=:accountPlanId];
        return accountPlanDetails;
    }
    
    
    
}