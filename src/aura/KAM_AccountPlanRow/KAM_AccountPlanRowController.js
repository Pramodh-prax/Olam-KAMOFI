({
     doInit: function(component, event, helper) {  
         
         var year = new Date().getFullYear();
         component.set('v.currentYear',year.toString());
       	helper.getCustomPermission(component);
     },
	closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "showAccountplans" attribute to "Fasle"  
        component.set("v.showAccountplans", false);
    },
    editAccountPlan : function(component, event, helper) {
        var rowIndex = event.currentTarget.parentElement.parentElement.id ;
        var acctplan=component.get('v.AccountPlanList');
        var cmpEvent = component.getEvent("KAM_AccountPlanRowEdit");
        cmpEvent.setParams({
            "acctPlanId" : acctplan[rowIndex].Id});
        cmpEvent.fire();
    },
    shareAccountPlan : function(component, event, helper) {
        var rowIndex = event.currentTarget.parentElement.parentElement.id ;
        var acctplan=component.get('v.AccountPlanList');
        var cmpEvent = component.getEvent("KAM_AccountPlanShare");
        cmpEvent.setParams({
            "acctPlanId" : acctplan[rowIndex].Id});
        cmpEvent.fire();
    },
    deleteAccountPlan : function(component, event, helper) {
        
        	console.log('I am in controller1');
        	var acctPlan_Id=event.target.dataset.id;
        	console.log('I am in controller2',acctPlan_Id);
        	var index=event.target.dataset.index;
        	var AccountPlanList=component.get('v.AccountPlanList');
        	helper.deleteAccountPlanPopup(component,AccountPlanList[index]);
        	
        	
      },
     
    
     genrateAccountPlanPdf : function(component, event, helper) {
        var rowIndex = event.currentTarget.parentElement.parentElement.id ;
        var acctplan=component.get('v.AccountPlanList');
        var cmpEvent = component.getEvent("KAM_AccountPlanGeneratePDFevt");
        cmpEvent.setParams({
            "accountPlanId" : acctplan[rowIndex].Id});
        cmpEvent.fire();
    }
})