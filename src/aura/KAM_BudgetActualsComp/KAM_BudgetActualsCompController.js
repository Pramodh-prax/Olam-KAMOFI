({
    doInit : function(component, event, helper) {

        let labels = {
            budgetDraftText : $A.get ('$Label.c.KAM_Budget_Plan_Draft_Message'),
            budgetApprovalWaitingText : $A.get ('$Label.c.KAM_Budget_Plan_Approval_Waiting_Message'),
            btnAddOrEdit : $A.get ('$Label.c.KAM_Btn_Label_Add_Edit_Budget'),
            btnRequesForEdit : $A.get ('$Label.c.KAM_Btn_Label_Reques_Approval_For_Edit_Budget')

        }
        component.set ('v.labels', labels);
        component.set ('v.selectedUnitOfMeasure', helper.DEFAULT_UNIT_OF_MEASURE);
		component.set ('v.options', helper.UNIT_OF_MEASURE_OPTIONS);
        helper.doInit (component, event);
    },
    handleOnAddBudget : function (component, event, helper) {
        helper.createBudgetModal (component);
    },
    handleOnRequestEditBudget : function (component, event, helper) {
        helper.riseRequestForBudgetEdit (component, event);
    },
    onBudgetUpdated : function (component, event, helper) {
        helper.onBudgetUpdated (component, event);
        $A.get('e.force:refreshView').fire();
    },
    handleOnUnitOfMeasureChange : function(component, event, helper) {
		helper.handleOnUnitOfMeasureChange (component, event);
	}
})