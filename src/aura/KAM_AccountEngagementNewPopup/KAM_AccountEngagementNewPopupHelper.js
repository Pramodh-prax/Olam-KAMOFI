({

    fetchYearPicklist: function (component) {
        let sectiondata = {
            compDetail: {
                Title__c: 'Engagement Plans'
            }
        };
        component.set('v.SectionData', sectiondata);
        this.getEngangementYearPickList(component);
    },
    
    fetchcurrentUserAccountTeam: function (component) {
        let self = this;
        let params = {
            'accountId': component.get("v.AccountId")
        };
        this.invokeApex(component, 'c.getcurrentUserAccountTeam', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.currentUserAccountTeam', result);
                    }
                })
            ).catch(
                $A.getCallback(error => {
                    console.log('Error Message: ', error);
                })
            );
    },
                    
    getEngangementYearPickList: function (component) {
        let params = {
            objectName: 'Engagement_Plan__c',
            fieldName: 'Year__c',
            discardInactive: true,
            shouldIncludeNone: false
        }
        this.invokeApex(component, 'c.getEngangementPickListValuesByField', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.YearPicklist', result);
                        component.set('v.isLoading', false);
                    }
                })
            ).catch(
                $A.getCallback(error => {
                    console.log('Error Message: ', error);
                    component.set('v.isLoading', false);
                    this.showErrorToast(component, 'Error', JSON.stringify(error), 'error', '5000');
                })
            );
    },
    SaveEngagementPlan: function (component, selectedYear) {
        component.set('v.isLoading', true);
        
        var bu;
        var currentUserAccountTeam = component.get("v.currentUserAccountTeam");
        if(currentUserAccountTeam.Business_Unit__c == 'All'){
            bu = component.get("v.selectedBU");
        }
        else{
            bu = currentUserAccountTeam.Business_Unit__c;
        }
        
        let params = {
            selYear: selectedYear,
            accountId: component.get('v.AccountId'),
            businessUnit : bu
        };
        this.invokeApex(component, 'c.createEngagementPlan', params)
            .then(
                $A.getCallback(result => {
                    component.set('v.isLoading', false);
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.EngagementPlan', result);
                        component.set('v.showEngagementPlan', true);
                        component.set('v.showModal', false);
                    }
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    console.log('Error Message: ', error);
                    console.log(JSON.stringify(error));

                    let message = ':' + this.normalizeError(error);
                    this.showToast(component, 'Error', message, 'error', '3000');
                    this.showErrorToast(component, 'Error', JSON.stringify(error), 'error', '5000');
                })
            );
    }
})