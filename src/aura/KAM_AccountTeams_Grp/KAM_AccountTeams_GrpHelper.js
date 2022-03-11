({
    doInit: function (component, event) {
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
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set ('v.accounts', JSON.parse(result));
                        JSON.parse(result).forEach(ele => {
                            allPromises.push(this.invokeApex(component, 'c.getAccountTeamsForGroup', {
                                accountId: ele.Id
                            }));
                        });
                    }
                    return Promise.all(allPromises);
                })
            ).then(
                $A.getCallback(teamMembers => {
                    let allTeamMembers = [];
                    if (teamMembers) {
                        teamMembers.forEach (ele => {
                            if (ele && ele.length > 0) {
                                allTeamMembers = allTeamMembers.concat (ele);
                            }
                        })
                    }
                    component.set ('v.allTeamMembers', allTeamMembers);
                    component.set ('v.isLoading', false);
                    component.set ('v.isTeamMembersLoaded', true);
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    this.console.log('Promise was rejected: ', error);
                    component.set ('v.isTeamMembersLoaded', true);
                    this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                })
            );
    }
})