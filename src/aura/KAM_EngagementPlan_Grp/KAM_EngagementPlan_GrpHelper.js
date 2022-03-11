({
    doInit: function (component, event) {
        component.set('v.isLoading', true);

        let sectionData = component.get('v.sectionData');

        let params = {
            overViewMetadata: JSON.stringify(sectionData.compDetail),
            data: JSON.stringify({
                accountPlan: sectionData.accountPlan
            })
        }
        let self = this;
        this.invokeApex(component, 'c.getGroupDetails', params)
            .then(
                $A.getCallback(result => {

                    const allPromises = new Array();
                    result = JSON.parse(result);
                    if (result && typeof result !== 'undefined' && result !== null) {
                        console.log('engagementlines',result);
                        component.set('v.EngagementLineItems', result);
                    }
                    component.set('v.isLoading', false);
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    this.console.log('Promise was rejected: ', error);
                    let message = ':' + this.normalizeError (error) ;
                    this.showToast(component, 'Error', message, 'error', '3000');
                })
            );
    }
})