({
    doinit : function(component, event, helper) {
        
        helper.getAccountPlansHelper(component);
        // helper.fetchCurrentUserBU(component);
        // helper.fetchAccountTeams(component);
        // helper.fetchUserRoles(component);
    },
    showAccountPlanPop : function(component, event, helper) {
        component.set('v.isOpen',true);
    },
    handleKAM_NewAccountPlanSave : function(component, event, helper) {
        var isOpen = event.getParam("isOpen");
        component.set("v.isOpen", isOpen);
        helper.getAccountPlansHelper(component);
    },
    handleKAM_NewAccountPlanSaveAndNew: function(component, event, helper){
        var isOpen = event.getParam("isOpen");
        var AccountPlanId = event.getParam("AccountPlanId");
            component.set("v.AccountPlanId", AccountPlanId);
        var showAccountplans = event.getParam("showAccountplans");
        component.set("v.isOpen", isOpen);
         helper.getAccountPlansHelper(component);
        component.set("v.showAccountplans", showAccountplans);
        if(showAccountplans){
            helper.createPlanOverViewComp (component);
        }
       
    },
    handleKAM_AccountPlanRowEdit : function(component, event, helper) {
        var AccountPlanId = event.getParam("acctPlanId");
 
        // set the handler attributes based on event data
        component.set("v.AccountPlanId", AccountPlanId);
        component.set("v.showAccountplans", true);
        helper.createPlanOverViewComp (component);
    },
    handleKAM_AccountPlanShare : function(component, event) {
        var AccountPlanId = event.getParam("acctPlanId");
 
        // set the handler attributes based on event data
        component.set("v.AccountPlanId", AccountPlanId);
        component.set("v.showAccountplanShare", true);
    },
    handleKAM_AccountPlanGeneratePDF : function(component, event) {
        var AccountPlanId = event.getParam("accountPlanId");
 		var pdfInfo = event.getParam("pdfInfo");
        // set the handler attributes based on event data
        component.set("v.AccountPlanId", AccountPlanId);
         component.set("v.pdfContent", pdfInfo);
        component.set("v.showAccountplanGenratePdf", true);
       
    },
     handleKAM_deleteAccountPlan: function(component, event, helper){
         console.log('in event '); 
        var AcctPlan = event.getParam("AcctPlan");
         console.log('Plan Id',AcctPlan.Id);
          helper.deleteAccountPlanHelper(component,helper,AcctPlan.Id); 
       
    }
    
})