({
    doInit : function(component, event) {
        component.set ('v.isLoading', true);
        let accountPlan = component.get ('v.accountPlan');
        let params = {
            accPlan : accountPlan
        };
        this.invokeApex (component, 'c.getPresentationOpportunities', params)
        .then (
            $A.getCallback (result => {
                //console.log (JSON.stringify (result));
                component.set ('v.items', result);
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback (error => {
                component.set ('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);                    
            })
        )
    },
    getGroupOpportunities : function(component, event) {
        component.set ('v.isLoading', true);

        const allPromises = new Array();

        let accounts = component.get ('v.accounts');

        let accIds = []
        accounts.forEach (ele => {
            accIds.push (ele.Id);
        });
		let params = {
        	accPlan : Object.assign (component.get ('v.accountPlan'), {attributes : undefined}),
            accIdStr : JSON.stringify (accIds)
        };
        this.invokeApex (component, 'c.getGroupPresentationOpportunities', params)
        .then (
            $A.getCallback(results => {
                component.set ('v.items', results);
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);                    
            })
        );
    }
})