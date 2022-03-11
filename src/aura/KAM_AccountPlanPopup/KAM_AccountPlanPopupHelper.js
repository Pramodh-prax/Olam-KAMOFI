({
	getAccountPlan : function(component) {
        component.set ('v.isLoading', true);
        let params = {accountPlanId :component.get("v.AccountPlanId")};

        this.invokeApex(component, 'c.getAccountPlan', params)
        .then(
            $A.getCallback(result => {
                component.set('v.AccountPlan', result);
                //this.createPlanOverViewComp (component);
                component.set ('v.isLoading', false);
            })
        ).catch(
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                console.log('Error Message: ', error);
            })
        );
	},
})