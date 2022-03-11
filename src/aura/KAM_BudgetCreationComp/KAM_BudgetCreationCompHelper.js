({
    doInit : function(component) {
        component.set ('v.isLoading', false);
    },
    handleOnSave : function (component, isLocked) {
        let budgets  = component.get ('v.budgets');
        
        let budget = component.get ('v.budget');
        
        if (!budget || typeof budget === 'undefined' || budget === null) {
            budget = {};
            const accountPlan = component.get ('v.accountPlan');
            budget.Account__c = accountPlan.Account__c;
            budget.Business_Unit__c = accountPlan.BU_Identifier__c;
            budget.End_Date__c = accountPlan.EndDate__c;
            budget.Start_date__c = accountPlan.StartDate__c;
            budget.Year__c = accountPlan.Year__c;
            budget.Is_Budget_Locked__c = isLocked;
            budget.Name = accountPlan.BU_Identifier__c + '-' + accountPlan.Year__c;
        } else {
            budget = Object.assign (budget, {Is_Budget_Locked__c : isLocked, attributes : undefined, Budget_vs_Actual_Lines__r : undefined});
        }
        
        let params = { 
            budgetLineStr : JSON.stringify (budgets),
            budgetStr : JSON.stringify (budget)
        }
        component.set ('v.isLoading', true);
        this.invokeApex (component, 'c.createBudget', params)
        .then (
            $A.getCallback (result => {
                result = JSON.parse (result);
                if (result.success) {
                    component.set ('v.budgets', result.budgetLines);
                    
                    component.set ('v.budget', result.budget);
                    const budgetUpdated = component.getEvent("budgetUpdated");
                    if (budgetUpdated) {
                        budgetUpdated.setParam ('budgetId', result.budget.Id);
                        budgetUpdated.fire();
                    }
                    component.destroy ();
                } else {
                    this.showToast(component, 'Error', result.message, 'error', '5000');
                }
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback (error => {
                component.set ('v.isLoading', false);
                console.log ('Error :' + error);
                this.showToast(component, 'Error', error.toString (), 'error', '5000');
            })
        )
    },
    createCategoryCombination : function (record) {
        let catSubCatStr = '';
        this.catSubCatCombFields.forEach(eachField => {
            if (record.hasOwnProperty (eachField) 
                && record[eachField] 
                && record[eachField] !== 'null' 
                && record[eachField] !== '') {
                catSubCatStr += '_' + record[eachField]
            }
        });
        return catSubCatStr.trim ();
    },
    resetFormValues : function (component) {
        //reset values
        // component.find('budgetField').forEach(function(f) {
        //     f.reset();
        // });
        this.budgetLineFields.forEach (field => {
            component.find(field.auraId).reset ();
        });
    },
    hasMandatoryFieldValues : function (component, fields) {
        let errStr = '';

        this.budgetLineFields.forEach (field => {
            if (field.required && (!fields[field.apiName] || fields[field.apiName] === '' || fields[field.apiName] === null)) {
                errStr = field.label;
                return;
            }
        });

        if (errStr) {
            const errMsg = this.string.format ($A.get('$Label.c.KAM_Budget_Mandatory_Field_Error_Message'), errStr);
            component.set ('v.errorMessage', errMsg);
            window.setTimeout (
                $A.getCallback (() => {
                    component.set ('v.errorMessage', '');
                }),
                5000
            )
            return false;
        }
        return true;
    },
    isValidCatSubCatCombination : function (component, fields, mode, recordIndex) {
        let errStr = '';

        let currentRecordComb = this.createCategoryCombination (fields);

        let budgets = component.get ('v.budgets');
        if (!budgets) {
            budgets = [];
        }

        errStr = '';
        budgets.forEach ( (ele, index) => {
            if (mode === 'new' || (mode === 'edit' && recordIndex !== index)){
                let tempCombi = this.createCategoryCombination (ele);
                if (currentRecordComb.toLowerCase() === tempCombi.toLowerCase()) {
                    errStr = $A.get ('$Label.c.KAM_Budget_Product_Cat_SubCat_already_Choosen');
                    return;
                }
            }
        });  

        if (errStr) {
            component.set ('v.errorMessage', errStr);
            window.setTimeout (
                $A.getCallback (() => {
                    component.set ('v.errorMessage', '');
                }),
                5000
            );
            return false;
        } 

        return true;
    },
    budgetLineFields : [
        {
            auraId : 'Category__c', apiName : 'Category__c', label : 'Category', required: true
        },
        {
            auraId : 'Volume__c', apiName : 'Volume__c', label : 'Volume', required: true
        },
        {
            auraId : 'Sub_Category__c', apiName : 'Sub_Category__c', label : 'Sub Category'
        },
        {
            auraId : 'Sub_Category_2__c', apiName : 'Sub_Category_2__c', label : 'Sub Category 2'
        }
    ],
    catSubCatCombFields : [
        'Category__c','Sub_Category__c','Sub_Category_2__c'
    ]
})