({
	getCustomPermission : function(component) {
        
         let params = {
            
        }
        this.invokeApex(component, 'c.getCustomPermission', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        console.log('Permission',result);
                        component.set('v.hasCustomPermission', result);

                         }
                })
            ).catch(
                $A.getCallback(error => {
                    console.log('Error Message: ', error);
                    component.set('v.isLoading', false);
                    this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                })
            );
		
	},
    
   
     deleteAccountPlanPopup: function (component,AcctPlan) {
        $A.createComponent(
            'c:KAM_AccountPlanDeletePopup', {
                'AcctPlan':AcctPlan
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set('v.newDeletePopup', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log(errorMessage);
                }
            }
        );
    }
                    
})