({
    doinit : function(component, event, helper) {
        helper.getAccountPlan(component);
    },
	closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "showAccountplans" attribute to "Fasle"  
        component.destroy ();
        component.set("v.showAccountplans", false);
    },
    refreshAccountPlan : function(component, event, helper) {

       
        helper.getAccountPlan(component);

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

        let AccountPlan = component.get ('v.AccountPlan');

        let link = '/apex/KAM_AccountOverview?accountId=' + component.get('v.AccountId') 
                    + '&mode=printPreview' 
                    + '&accountPlanId=' + AccountPlan.Id 
                    + '&planName=' + AccountPlan.Name 
                    + '&planBu=' + AccountPlan.BU_Identifier__c 
                    + '&planYear=' + AccountPlan.Year__c
                    + '&planType=' + AccountPlan.Type__c; 
        window.open(link,'_blank');
        
        
        // var acctplanId=component.get('v.AccountPlanId');
        // var info = document.getElementById(component.find('acct-plan')).innerHTML;
        // var cmpEvent = component.getEvent("KAM_AccountPlanGeneratePDFevt");
        // cmpEvent.setParams({
        //     "acctPlanId" : acctplanId,
        //     "pdfInfo" : info});
        // component.set('v.showAccountplans',false);
        // cmpEvent.fire();
    }
})