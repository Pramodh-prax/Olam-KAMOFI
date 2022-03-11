({
	fetchAccessLevelPicklist : function(component){
        
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            'objectName': 'Account_Plans__Share',
            'field_apiname': 'AccessLevel',
            'nullRequired': true // includes --None--
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS"){
                component.set("v.AccessLevel", actionResult.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    removeAccessHelper : function(component,event,getId) {
        debugger;
         var action = component.get("c.removeAccessAccountPlanShare");
        
        action.setParams({
            'AcctPlanshareId':getId
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('State of Response :'+state);
            if (state === "SUCCESS") {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'The access to this account plan is successfully removed.',
                    duration:'3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var cmpEvent = component.getEvent("KAM_AccountPlanShareInlineEditevt");
        cmpEvent.fire();
            }
        });
        $A.enqueueAction(action);
         
     }

})