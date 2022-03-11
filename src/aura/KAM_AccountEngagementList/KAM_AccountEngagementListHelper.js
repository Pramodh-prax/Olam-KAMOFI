({
    doInit: function (component, event, helper) {
        let params = {
            AccountId: component.get("v.recordId")
        };
        let sectiondata = {
            compDetail: {
                Title__c: 'Engagement Plans'
            }
        };
        component.set('v.SectionData', sectiondata);

        this.invokeApex(component, 'c.getEngagementPlansByAccountId', params)
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
                        
                    }
                    
                })
            ).catch(
                $A.getCallback(error => {
                    this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                    console.log('Error Message: ', error);
                })
            );
    },
    sortData : function (component, data, sortDir) {
        component.set('v.EngagementPlanList', this.localSort (component, data, 'Year__c',  sortDir, 'Number'));
    },
    createEngagementModal: function (component, engPlanId) {
        $A.createComponent(
            'c:KAM_AccountEngagementModal', {
                'EngagementId': engPlanId
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set('v.addEngModal', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log(errorMessage);
                }
            }
        );
    },
    createEngagementNewModal: function (component) {
        $A.createComponent(
            'c:KAM_AccountEngagementNewPopup', {
                'EngagementCompList': component.get('v.EngagementPlanList'),
                'AccountId': component.get("v.recordId")
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set('v.newEngModal', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log(errorMessage);
                }
            }
        );
    }
})