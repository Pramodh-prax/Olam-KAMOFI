({
    doInit: function (component, event, helper) {
        let sectiondata = {
            compDetail: {
                Title__c: 'Budgets'
            }
        };
        component.set('v.SectionData', sectiondata);
        let params = {
            BudgetActualId: component.get('v.BudgetvsActualId')
        };

        this.invokeApex(component, 'c.getBudgetActualsById', params)
            .then(
                $A.getCallback(result => {
                    this.updateLocalVariables(component, result);
                })

            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    console.log('Error Message: ', error);
                    this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                })
            );
    },

    updateLocalVariables: function (component, result) {
        if (result && typeof result !== 'undefined' && result !== null) {
            result = JSON.parse(result);
            if (result && result.length > 0 && result[0]) {
                let budget = result[0];
                component.set('v.isAddBudgetButtonDisabled', result[0].Is_Budget_Locked__c);
                component.set('v.budget', budget);
                component.set('v.budgets', result[0].Budget_vs_Actual_Lines__r.records);

                this.invokeApex (component, 'c.isLocked', {recordId : result[0].Id})
                .then (
                    $A.getCallback (isLocked => {
                        if (isLocked || (result[0].Is_Budget_Locked__c && result[0].Approval_Status__c === 'Pending')) {
                            component.set('v.isModifyBudgetBtnDisabled', true);
                        }
                    })
                ).catch (
                    $A.getCallback (error => {
                        this.console.log('Promise was rejected: ', error);
                        this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                    })
                )

            }
        }
        //component.set('v.BudgetvsActual',result);
        component.set('v.isLoading', false);

    },


    riseRequestForBudgetEdit: function (component, event) {

        let params = {
            budgetStr: JSON.stringify({
                Id: component.get('v.budget').Id

            })
        };

        component.set('v.isLoading', true);
        this.invokeApex(component, 'c.riseRequestForBudgetEdit', params)
            .then(
                $A.getCallback(result => {
                    result = JSON.parse(result);
                    if (result.success) {
                        // let budget = Object.assign(component.get('v.budget'), {
                        //     Approval_Status__c: result.Approval_Status__c
                        // });
                        component.set('v.budget', result.budget);

                        if ((result.budget.Is_Budget_Locked__c && result.budget.Approval_Status__c === 'Pending')) {
                            component.set('v.isModifyBudgetBtnDisabled', true);
                        }

                        this.doInit(component, event);
                        //this.showToast(component, 'Success','Request Has Been Submitted for Aproval', 'Success', '200');
                    } else {
                        this.showToast(component, 'Error', result.message, 'error', '5000');
                    }
                    component.set('v.isLoading', false);
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    console.log('Error :' + error);
                    this.showToast(component, 'Error', error.toString(), 'error', '5000');
                })
            );
    },

    onBudgetUpdated: function (component, event) {
        component.set('v.isLoading', true);
        let sectionData = component.get('v.sectionData');

        let params = {
            BudgetActualId: component.get('v.budgetId')
        }
        //event.setParam("budgetId",component.get('v.BudgetvsActualId'));
        this.invokeApex(component, 'c.getBudgetActualsById', params)
            .then(
                $A.getCallback(result => {
                    this.updateLocalVariables(component, result);
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    this.console.log('Promise was rejected: ', error);
                    this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                })
            );
    },

    createBudgetModal: function (component) {
        // let sectionData = component.get ('v.sectionData');
        $A.createComponent(
            'c:KAM_BudgetCreationComp', {
                /*  'accountId': sectionData.accountId,
                  'accountPlan' : sectionData.accountPlan,*/
                'budget': component.get('v.budget'),
                'budgets': component.get('v.budgets')
            },
            (infoSubPanel, status, errorMessage) => {
                console.log('status', status);
                if (status === 'SUCCESS') {
                    component.set('v.addBudgetModal', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log(errorMessage);
                }
            }
        );
    },
})