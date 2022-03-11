({
    doInit : function(component, event) {
        let sectionData = component.get ('v.sectionData');
        let self = this;
        component.set ('v.isLoading', true);

        let params = {
            overViewMetadata : JSON.stringify (sectionData.compDetail), 
            data : JSON.stringify ({
                accountId : sectionData.accountId
            })
        }
        this.invokeApex (component, 'c.getDetails', params)
        .then(
            $A.getCallback(result => {
                component.set ('v.contacts', JSON.parse (result));
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