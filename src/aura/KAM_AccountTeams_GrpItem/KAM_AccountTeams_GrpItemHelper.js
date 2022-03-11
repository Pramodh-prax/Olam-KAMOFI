({
	doInit : function(component, event) {
        let account = component.get ('v.account');
        let self = this;
        component.set ('v.isLoading', true);

        let params = {
            accountId : account.Id
        }
        this.invokeApex (component, 'c.getAccountTeams', params)
        .then(
            $A.getCallback(result => {
                component.set ('v.accountTeams', result);
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                console.log('Promise was rejected: ', error);                    
            })
        );
    }
})