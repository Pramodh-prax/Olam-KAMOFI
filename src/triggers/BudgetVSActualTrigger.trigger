trigger BudgetVSActualTrigger on Budget_vs_Actuals__c (before insert, before update, after insert) {
Boolean vietnamUsers = FeatureManagement.checkPermission('Vietnam_Custom_Exception');
    if(vietnamUsers){
        
    }else{
        new BudgetVSActualTriggerHandler().Handle();
    }
    
}