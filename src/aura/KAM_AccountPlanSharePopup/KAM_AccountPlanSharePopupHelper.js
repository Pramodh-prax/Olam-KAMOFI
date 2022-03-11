({
    fetchAccessLevelPicklist : function(component){
        let params = {
            'objectName': 'Account_Plans__Share',
            'field_apiname': 'AccessLevel',
            'nullRequired': true
        };
        this.invokeApex (component, 'c.getPicklistvalues', params)
        .then(
            $A.getCallback(result => {
                if (result && typeof result !== 'undefined' && result !== null) {
                   component.set('v.AccessLevel', result);
                }
            })
        ).catch (
            $A.getCallback(error => {
                console.log('Error Message: ', error);                    
            })
        );   
    },
    getAccountPlanShare : function(component) {
         let params = {
			accountPlanId :component.get("v.AccountPlanId")
        };
        this.invokeApex (component, 'c.getAccountPlanShare', params)
        .then(
            $A.getCallback(result => {
                if (result && typeof result !== 'undefined' && result !== null) {
                   component.set('v.AccountPlanShare', result);
                }
            })
        ).catch (
            $A.getCallback(error => {
                console.log('Error Message: ', error);                    
            })
        );    
    },
    getUsersByRoles : function(component) {
        this.invokeApex (component, 'c.getUserByDefaultRoles')
        .then(
            $A.getCallback(result => {
                if (result && typeof result !== 'undefined' && result !== null) {
                   component.set('v.UsersList', result);
                }
            })
        ).catch (
            $A.getCallback(error => {
                console.log('Error Message: ', error);                    
            })
        );    
    },       
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchUser");
        // set param to method  
        console.log(component.get("v.AccountId"));
        action.setParams({
            'accountId' :component.get("v.AccountId"),
            'searchKeyWord': getInputkeyWord,
            'listOfAccountPlanShare':component.get("v.AccountPlanShare")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", 'Search Result...');
                }
                
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    saveAccountPlanShareHelper : function(component) {
        var action = component.get("c.saveAccountPlanShare");
        action.setParams({
            'AccounPlanId':component.get("v.AccountPlanId"),
            'UserId' :component.get("v.selectedRecord.Id"),
            'UserName':component.get("v.selectedRecord.Name"),
            'AccountId':component.get("v.AccountId")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('State of Response :'+state);
            if (state === "SUCCESS") {
                var message='The Account Plan is successfully shared with the team member.';
            var type='success';
            this.showToast(component,message,type); 
               
                this.getAccountPlanShare(component);
                this.clear(component);
            }
        });
        $A.enqueueAction(action);
    },
    updateAccountPlanShareHelper : function(component, event, helper) {
        var action = component.get("c.updateAccountPlanShare");
        
        action.setParams({
            'listOfaccountPlanShare':component.get("v.AccountPlanShare")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('State of Response :'+state);
            if (state === "SUCCESS") {
                var message='The Account Plan is successfully shared with the team member.';
            var type='success';
            this.showToast(component,message,type); 
               
                component.set('v.showSaveCancelBtn',false);
                this.getAccountPlanShare(component);
                component.set("v.showAccountplanShare", false);
            }
        });
        $A.enqueueAction(action);
        
    },
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.showUserdetail" , false);
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
    },
    removeAccessHelper : function(component,event,getId) {
        var action = component.get("c.removeAccessAccountPlanShare");
        
        action.setParams({
            'AcctPlanshareId':getId
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('State of Response :'+state);
            if (state === "SUCCESS") {
                var message='The access to this account plan is successfully removed.';
            var type='success';
            this.showToast(component,message,type); 
                
                this.getAccountPlanShare(component);
            }
        });
        $A.enqueueAction(action);
        
    },
    showToast:function(component,message,type) {
        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: message,
                    duration:'3000',
                    key: 'info_alt',
                    type: type,
                    mode: 'pester'
                });
                toastEvent.fire();
        
    }
    
})