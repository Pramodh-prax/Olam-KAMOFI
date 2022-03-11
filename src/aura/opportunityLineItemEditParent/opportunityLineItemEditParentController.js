({
    initRecords: function(component, event, helper) {
         helper.doInit (component, event);
    },
    
    Save: function(component, event, helper) {
        // Check required fields(Name) first in helper method which is return true/false
        if (helper.requiredValidation(component, event)){
            // call the saveOpportunityLineItem apex method for update inline edit fields update 
            var action = component.get("c.saveOpportunityLineItem");
            action.setParams({
                "opportunityId": component.get("v.recordId"),
                'lstOpportunityLineItem': component.get("v.OpportunityLineItemList")
            });
            action.setCallback(this, function(response) {
                component.set ('v.isLoading', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // set OpportunityLineItemList list with return value from server.
                    component.set("v.OpportunityLineItemList", storeResponse);
                    // Hide the save and cancel buttons by setting the 'showSaveCancelBtn' false 
                    component.set("v.showSaveCancelBtn",false);
					helper.showToast (component, 'success', 'Success!', 'All Records has been updated successfully.');
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                } else {
                    helper.showToast (component, 'error', 'Error ):', 'Update failed : ' + helper.normalizeError(response.getError ()));
                }
            });
            component.set ('v.isLoading', true);
            $A.enqueueAction(action);
        } 
        
    },
    
    cancel : function(component,event,helper){
        // on cancel refresh the view (This event is handled by the one.app container. It’s supported in Lightning Experience, the Salesforce app, and Lightning communities. ) 
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire(); 
    } 
    
})