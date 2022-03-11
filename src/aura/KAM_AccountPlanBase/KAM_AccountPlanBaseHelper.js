({

    getAccountPlansHelper: function (component) {
        let self = this;
        let params = {
            'accountId': component.get("v.recordId")
        };
        this.invokeApex(component, 'c.getAccountPlans', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.AccountPlanList', result);
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
                        var AccountTeams = component.get("v.AccountTeams");
                        var AccountPlans = component.get("v.AccountPlanList");
                        if (AccountTeams.length == 0 && AccountPlans.length == 0) {
                            component.set("v.showNeedsPermission", true);
                        } else if (AccountTeams.length == 0 && AccountPlans.length > 0) {
                            component.set("v.showAccountpls", true);
                        }
                    }
                    return this.invokeApex(component, 'c.getUserBU');
                })
            ).then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.UserBU', result);
                    }
                })
            ).catch(
                $A.getCallback(error => {
                    console.log('Error Message: ', error);
                })
            );
    },
	createPlanOverViewComp: function (component) {
        $A.createComponent(
            'c:KAM_AccountPlanPopup', {
                'showAccountplans' : true,
                'AccountId': component.get ('v.recordId'),
                'AccountPlanId' : component.get ('v.AccountPlanId')
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set ('v.planOverViewComp', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log ('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log (errorMessage);
                }
            }
        );
	},
                               
      deleteAccountPlanHelper : function(component,helper,AcctPlanId) {
      console.log('in helper delete');
		console.log('in helper delete',AcctPlanId);
        var action = component.get("c.deleteAccountPlan");
        
        action.setParams({
            'AcctPlanId':AcctPlanId
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('State of Response :'+state);
            if (state === "SUCCESS") {
              	
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Account plan is successfully removed.',
                    duration:'3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                }
        });
        $A.enqueueAction(action);
		 helper.getAccountPlansHelper(component);
				
        
     }
})