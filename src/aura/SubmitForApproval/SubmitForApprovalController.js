({
	doInit : function(component, event,helper) {
		helper.initHelper(component, event);
	},
    createQuoteLineApproval : function(component,event,helper){
        helper.createQuoteLineApprovalRecord(component,event);
    },
    cancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})