({
	doInit : function(component, event, helper) {
        let labels = {
            budgetDraftText : $A.get ('$Label.c.KAM_Budget_Plan_Draft_Message'),
            budgetApprovalWaitingText : $A.get ('$Label.c.KAM_Budget_Plan_Approval_Waiting_Message'),
            btnAddOrEdit : $A.get ('$Label.c.KAM_Btn_Label_Add_Edit_Budget'),
            btnRequesForEdit : $A.get ('$Label.c.KAM_Btn_Label_Reques_Approval_For_Edit_Budget'),
             modalHeading : $A.get ('$Label.c.KAM_Budget_Creation_Modal_Header'),
            noData: $A.get ('$Label.c.KAM_No_Data_available_in_table'),
            category : $A.get ('$Label.c.KAM_Budget_Table_Header_Category'),
            subcategory : $A.get ('$Label.c.KAM_Budget_Table_Header_Sub_Category'),
            subcategory2 : $A.get ('$Label.c.KAM_Budget_Table_Header_Sub_Category_2'),
            volume : $A.get ('$Label.c.KAM_Budget_Table_Header_Volume'),
            edit : $A.get ('$Label.c.KAM_Budget_Table_Header_Edit'),
            actuals:$A.get ('$Label.c.KAM_Budget_Table_Header_Actuals'),
			total_consumption : $A.get ('$Label.c.KAM_Budget_Table_Header_Total_Consumption'),
        }
        component.set ('v.labels', labels);
		helper.doInit(component, event, helper);
	},
     handleOnAddBudget : function (component, event, helper) {
        helper.createBudgetModal (component);
    },
    handleOnRequestEditBudget : function (component, event, helper) {
        
        helper.riseRequestForBudgetEdit (component, event);
    },
    closeModel: function(component, event, helper) {  
        //component.get ('v.engComp').destroy ();
        component.destroy ();
    },
    onBudgetUpdated : function (component, event, helper) {
        helper.onBudgetUpdated (component, event);
    }
})