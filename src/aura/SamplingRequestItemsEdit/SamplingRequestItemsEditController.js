({
    handleComponentEvent : function(component, event, helper) {	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
       var selectedOpportunityLineItemId = event.getParam("opportunityLineItemId");
	   
        var selectedAccountRecord = component.get("v.selectedAccountLookUpRecord");
        var selectedUserRecord = component.get("v.selectedUserLookUpRecord");
        
        var currentWrapperItem = component.get("v.singleRec");
        currentWrapperItem.accountId = selectedAccountRecord.Id;
        currentWrapperItem.PDandIUserId = selectedUserRecord.Id;

        component.set("v.singleRec",currentRecord);
        if(component.get("v.selectedLookUpRecord") != ''){ 
            component.set("v.showSaveCancelBtn",true);
        }
    },  
})