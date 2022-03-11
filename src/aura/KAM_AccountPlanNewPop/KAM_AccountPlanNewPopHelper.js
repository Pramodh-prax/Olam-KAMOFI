({
    fetchTypePicklist: function (component) {
        let self = this;
        let params = {
            'objectName': 'Account_Plans__c',
            'field_apiname': 'Type__c',
            'nullRequired': true
        };
        this.invokeApex(component, 'c.getPicklistvalues', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.TypePicklist', result);
                    }
                })
            ).catch(
                $A.getCallback(error => {
                    console.log('Error Message: ', error);
                })
            );
    },
    fetchYearPicklist: function (component) {
        let self = this;
        let params = {
            'objectName': 'Account_Plans__c',
            'field_apiname': 'Year__c',
            'nullRequired': true
        };
        this.invokeApex(component, 'c.getPicklistvalues', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.YearPicklist', result);
                    }
                })
            ).catch(
                $A.getCallback(error => {
                    console.log('Error Message: ', error);
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
    saveAccountPlanHelper: function (component) {
        var action = component.get("c.saveAccountPlan");;
        var startdate = component.get("v.StartDate");
        var enddate = component.get("v.EndDate");
        
        var bu;
        var currentUserAccountTeam = component.get("v.currentUserAccountTeam");
        if(currentUserAccountTeam.Business_Unit__c == 'All'){
            bu = component.get("v.selectedBU");
        }
        else{
            bu = currentUserAccountTeam.Business_Unit__c;
        }
        var dispData = {
            name: component.get('v.Name'),
            description: component.get('v.Description'),
            year: component.get('v.selectedYear'),
            AccountId: component.get("v.AccountId"),
            PlanType: component.get("v.selectedType"),
            BusinessUnit: bu
        }
        action.setParams({
            'StartDate': startdate,
            'EndDate': enddate,
            'data': JSON.stringify(dispData)
        });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            console.log('State of Response :' + state);
            if (state === "SUCCESS") {
                var appEvent = $A.get("e.c:KAM_NewAccountPlanSave");
                appEvent.setParams({
                    "isOpen": false
                });
                appEvent.fire();
                var message = 'Account Plan successfully created!!';
                this.showToast(component, 'Success', message, 'success', '3000');
            } else if (state === 'ERROR') {
                console.log (JSON.stringify (actionResult.getError ()));
                let message = ':' + this.normalizeError (actionResult.getError ()) ;
                this.showToast(component, 'Error', message, 'error', '3000');
            } else {
                console.log (JSON.stringify (actionResult.getError ()));
            }
        });
        $A.enqueueAction(action);
    },
    saveAndContinueAccountPlanHelper: function (component) {
        var action = component.get("c.saveAccountPlan");
        var startdate = component.get("v.StartDate");
        var enddate = component.get("v.EndDate");
        
        var bu;
        var currentUserAccountTeam = component.get("v.currentUserAccountTeam");
        if(currentUserAccountTeam.Business_Unit__c == 'All'){
            bu = component.get("v.selectedBU");
        }
        else{
            bu = currentUserAccountTeam.Business_Unit__c;
        }
        
        var dispData = {
            name: component.get('v.Name'),
            description: component.get('v.Description'),
            year: component.get('v.selectedYear'),
            AccountId: component.get("v.AccountId"),
            PlanType: component.get("v.selectedType"),
            BusinessUnit: bu
        }
        action.setParams({
            'StartDate': startdate,
            'EndDate': enddate,
            'data': JSON.stringify(dispData)
        });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            console.log('State of Response :' + state);
            if (state === "SUCCESS") {
                var accountplan = actionResult.getReturnValue();
                console.log(accountplan.Id);
                var appEvent = $A.get("e.c:KAM_NewAccountPlanSaveAndContinue");
                appEvent.setParams({
                    "isOpen": false,
                    "showAccountplans": true,
                    "AccountPlanId": accountplan.Id
                });
                appEvent.fire();
                let message = 'Account Plan successfully created!!';
                this.showToast(component, 'Success', message, 'success', '3000');
            } else if (state === 'ERROR') {
                console.log (JSON.stringify (actionResult.getError ()));
                let message = ':' + this.normalizeError(actionResult.getError ()) ;
                this.showToast(component, 'Error', message, 'error', '3000');
            } else {
                console.log (JSON.stringify (actionResult.getError ()));
            }
        });
        $A.enqueueAction(action);
    }
})