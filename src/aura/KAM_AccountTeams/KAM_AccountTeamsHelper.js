({
    getAccountTeamshelper: function (component) {
        let sectionData = component.get('v.sectionData');
        let self = this;
        let params = {
            overViewMetadata: JSON.stringify(sectionData.compDetail),
            data: JSON.stringify({
                accountId: sectionData.accountId
            })
        };
        this.invokeApex(component, 'c.getDetails', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.AccountTeams', JSON.parse(result));
                    }
                    component.set('v.isLoading', false);
                    component.set('v.isTeamMembersLoaded', true);
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    console.log('Error Message: ', error);
                    component.set('v.isTeamMembersLoaded', true);
                })
            );
    }
})