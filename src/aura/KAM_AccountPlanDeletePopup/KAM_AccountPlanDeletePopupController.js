({
     doInit : function(component, event, helper) {
         component.set('v.showConfirmDialog', true);
	},
	/*handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },*/
     
    handleConfirmDialogYes : function(component, event, helper) {
        console.log('Yes');
        component.set('v.showConfirmDialog', false);
        var acctPlan=component.get('v.AcctPlan');
         console.log('Yes1');
         var cmpEvent = component.getEvent("KAM_AccountPlanDelete");
         console.log('Yes2');
         cmpEvent.setParams({
             "AcctPlan" :acctPlan
        });
        cmpEvent.fire();
      

    },
     
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
        
    }
})