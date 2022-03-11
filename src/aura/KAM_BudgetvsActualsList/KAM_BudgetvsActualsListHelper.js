({
    getBudgetActuals: function (component, event, helper) {
        let params = {
            accountId: component.get("v.recordId")
        };

        this.invokeApex(component, 'c.getBudgetvsActuals', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        this.sortData (component, result, component.get ('v.sortDir'));
                    }
                    return this.invokeApex(component, 'c.getUserBU');
                })
            ).then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.UserBU', result);
                        console.log('User Bu',result);
                    }
                    return this.invokeApex(component,
                        'c.getAccountTeams', {
                            'accountId': component.get("v.recordId")
                        });
                })
            ).then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.AccountTeams', result);
                        console.log('Account Teams',result);
                        
                    }
                    
                })
            ).catch(
                $A.getCallback(error => {
                    console.log('Error Message: ', error);
                    this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                })
            );
    },
    sortData : function (component, data, sortDir) {
        component.set('v.BudgetvsActuals', this.localSort (component, data, 'Year__c',  sortDir, 'Number'));
    },
    createBudgetvsActualsModal: function (component, BudgetActualId) {
        $A.createComponent(
            'c:KAM_AccountBudgetvsActualsModal', {
                'BudgetvsActualId': BudgetActualId
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set('v.addBudgetModal', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log(errorMessage);
                }
            });
    },
    createBudgetvsActualsNewModal: function (component) {
        $A.createComponent(
            'c:KAM_AccountBudgetvsActualNewPopup', {
                'BudgetvsActualCompList': component.get('v.BudgetvsActuals'),
                'AccountId': component.get("v.recordId")
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set('v.newBudgetModal', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log(errorMessage);
                }
            }
        );
    }
})