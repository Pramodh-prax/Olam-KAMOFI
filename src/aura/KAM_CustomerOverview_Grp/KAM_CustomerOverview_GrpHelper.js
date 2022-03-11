({
	doInit : function(component, event) {
        let sectionData = component.get ('v.sectionData');
        let params = {
            overViewMetadata : JSON.stringify (sectionData.compDetail), 
            data : JSON.stringify ({
                accountPlan : sectionData.accountPlan
            })
        }
        let self = this;
        this.invokeApex (component, 'c.getDetails', params)
        .then(
            $A.getCallback(result => {
                result = JSON.parse (result);
                if (result && typeof result !== 'undefined' && result !== null) {
                    component.set ('v.Accountlist', result);
                }
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                console.log (JSON.stringify (error));
                let message = ':' + this.normalizeError (error) ;
                this.showToast(component, 'Error', message, 'error', '3000');

                this.console.log('Promise was rejected: ', error);                    
            })
        );
    }
})