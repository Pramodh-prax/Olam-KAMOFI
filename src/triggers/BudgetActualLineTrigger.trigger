trigger BudgetActualLineTrigger on Budget_vs_Actual_Line__c	 (after insert, after update) {
    new BudgetActualLineTriggerHandler ().handle();
}