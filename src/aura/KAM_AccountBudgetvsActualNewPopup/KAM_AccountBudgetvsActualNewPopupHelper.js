({
    fetchYearPicklist: function (component) {
        let sectiondata = {
            compDetail: {
                Title__c: 'Budgets'
            }
        };
        component.set('v.SectionData', sectiondata);

        let params = {
            objectName: 'Budget_vs_Actuals__c',
            fieldName: 'Year__c',
            discardInactive: true,
            shouldIncludeNone: false
        }
        this.invokeApex(component, 'c.getBudgetPickListValuesByField', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {

                        component.set('v.yearPicklist', result);

                        component.set('v.isLoading', false);
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

    SaveBudgetvsActuals: function (component, selectedYear) {

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
        this.invokeApex(component, 'c.createBudgetvsActuals', params)
            .then(
                $A.getCallback(result => {
                    component.set('v.isLoading', false);
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.BudgetvsActuals', result);
                        component.set('v.showBudgetvsActuals', true);
                        component.set('v.showModal', false);
                    }
                    $A.get('e.force:refreshView').fire();
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    console.log('Error Message: ', error);
                    this.showToast(component, 'Error', this.normalizeError (error), 'error', '5000');
                    this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                })
            );
    }

})