({
    doInit : function(component, event, helper) {
        const labels = {
            modalHeading : $A.get ('$Label.c.KAM_Budget_Creation_Modal_Header'),
            noData: $A.get ('$Label.c.KAM_No_Data_available_in_table'),
            category : $A.get ('$Label.c.KAM_Budget_Table_Header_Category'),
            subcategory : $A.get ('$Label.c.KAM_Budget_Table_Header_Sub_Category'),
            subcategory2 : $A.get ('$Label.c.KAM_Budget_Table_Header_Sub_Category_2'),
            volume : $A.get ('$Label.c.KAM_Budget_Table_Header_Volume'),
            edit : $A.get ('$Label.c.KAM_Budget_Table_Header_Edit'),
            btnReset : $A.get ('$Label.c.KAM_Budget_Table_Btn_Reset'),
            btnCancel : $A.get ('$Label.c.KAM_Budget_Table_Btn_Cancel'),
            btnAdd : $A.get ('$Label.c.KAM_Budget_Table_Btn_Add'),
            btnUpdate : $A.get ('$Label.c.KAM_Budget_Table_Btn_Update'),
            modalBtnCancel : $A.get ('$Label.c.KAM_Modal_Btn_Cancel'),
            modalBtnSaveAsDraft : $A.get ('$Label.c.KAM_Modal_Btn_Save_As_Draft'),
            modalBtnSaveAndLock : $A.get ('$Label.c.KAM_Modal_Btn_Save_And_Lock'),
        };
        component.set ('v.labels', labels);
        helper.doInit (component);
    },
    closeModel : function(component, event, helper) {
        component.destroy ();
    },
    handleOnSaveAsDraft : function(component, event, helper) {
        helper.handleOnSave (component, false);
    },
    handleOnSaveAndLock : function(component, event, helper) {
        helper.handleOnSave (component, true);
    },
    handleUpdateCancel : function (component, event, helper) {
        component.set ('v.mode', 'new');
        component.set ('v.recordIndex', undefined);
        helper.resetFormValues (component);
    },
    handleAddReset : function (component, event, helper) {
        helper.resetFormValues (component);
    },
    editBudgetLine : function (component, event, helper) {
        let index = event.target.dataset.index;
        if (index) {
            index = Number (index);
            let budgets = component.get ('v.budgets');
            if (budgets[index]) {
                
                component.set ('v.mode', 'edit');
                component.set ('v.recordIndex', index);

                helper.budgetLineFields.forEach (field => {
                    component.find(field.auraId).set("v.value", budgets[index][field.apiName]);
                });
            }
        }
    },
    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        let fields = event.getParam('fields');

        let mode = component.get ('v.mode');
        let recordIndex = component.get ('v.recordIndex');

        let isValid = helper.hasMandatoryFieldValues (component, fields) 
                        && helper.isValidCatSubCatCombination(component, fields, mode, recordIndex);

        if (isValid) {
            let budgets = component.get ('v.budgets');
            
            if (mode === 'new') {
                if (!budgets) {
                    budgets = [];
                }
                budgets.push (fields);
            } else if (mode === 'edit') {
                let tempFields = budgets [recordIndex];
                if (tempFields.hasOwnProperty ('Id')) {
                    fields['Id'] = tempFields['Id'];
                }
                if (tempFields.hasOwnProperty ('Budget_vs_Actuals__c')) {
                    fields['Budget_vs_Actuals__c'] = tempFields['Budget_vs_Actuals__c'];
                }
                
                budgets [recordIndex] = fields;
                
                component.set ('v.mode', 'new');
                component.set ('v.recordIndex', undefined);
            }

            helper.resetFormValues (component);
            component.set ('v.budgets', budgets);
        }
    },
    handleEditFormLoad : function (component, event, helper) {
        const accountPlan = component.get ('v.accountPlan');
        let budget = component.get ('v.budget');
        let currentUser  = component.get('v.currentUser');
        
        if (budget && typeof budget !== 'undefined' && budget !== null && budget.Business_Unit__c) {
            component.find("Business_Unit__c").set("v.value", budget.Business_Unit__c);
        } else if (accountPlan && typeof accountPlan !== 'undefined' && accountPlan !== null && accountPlan.BU_Identifier__c){
            component.find("Business_Unit__c").set("v.value", accountPlan.BU_Identifier__c);
        } else if (currentUser && typeof currentUser !== 'undefined' && currentUser !== null && currentUser.BU_Identifier__c) {
            component.find("Business_Unit__c").set("v.value", currentUser.BU_Identifier__c);
        } 
        else {
            component.set ('v.isCurrentUserBURequired', true);
        }   
    },
    handleOnRecordUpdated : function (component, event, helper) {
        let currentUser  = component.get('v.currentUser');
        if (currentUser  && typeof currentUser !== 'undefined' && currentUser !== null && currentUser.BU_Identifier__c) {
            component.find("Business_Unit__c").set("v.value", currentUser.BU_Identifier__c);
        } else {
            this.showToast(component, 'Error', $A.get ('$Label.c.KAM_User_Unassigned_BU_Error_Message'), 'error', '5000');
        }
    },
})