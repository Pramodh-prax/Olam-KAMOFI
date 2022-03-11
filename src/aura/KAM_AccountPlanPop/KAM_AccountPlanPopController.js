({
    doinit : function(component, event, helper) {
        component.set('v.showAccountplans',true);
        component.set('v.isLoading',true);
         var pageReference = component.get("v.pageReference");
        if(pageReference!==undefined && pageReference!==null && pageReference.state!=null)
        {
            var recordId=pageReference.state.c__AccountPlanId; 
            component.set("v.AccountPlanId",recordId);
        }
        helper.getAccountPlan(component);
    },
	closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "showAccountplans" attribute to "Fasle"  
        component.destroy ();
        component.set("v.showAccountplans", false);
    },
    shareAccountPlan : function(component, event, helper) {
        var acctplanId=component.get('v.AccountPlanId');
        var cmpEvent = component.getEvent("KAM_AccountPlanShare");
        cmpEvent.setParams({
            "acctPlanId" : acctplanId});
       // component.set('v.showAccountplans',false);
        cmpEvent.fire();
    },
    genrateAccountPlanPdf : function(component, event, helper) {
        window.print();
       /* var acctplanId=component.get('v.AccountPlanId');
        var info = document.getElementById(component.find('acct-plan')).innerHTML;
        var cmpEvent = component.getEvent("KAM_AccountPlanGeneratePDFevt");
        cmpEvent.setParams({
            "acctPlanId" : acctplanId,
            "pdfInfo" : info});
        component.set('v.showAccountplans',false);
        cmpEvent.fire();*/
    }
})