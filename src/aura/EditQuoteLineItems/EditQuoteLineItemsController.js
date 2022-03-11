({
	doInit : function(component, event,helper){
		helper.editQuoteLineItems(component, event);
 	},
    cancel : function(component,event,helper){
        var AddQuoteLineItemToParentCompEvent = component.getEvent("AddQuoteLineItemToParentCompEvent");
        AddQuoteLineItemToParentCompEvent.setParams({"action" : 'CANCEL' });
        AddQuoteLineItemToParentCompEvent.fire(); 
    },
    updateQuoteLineItems : function(component,event,helper) {
        var requiredValidationResponse = helper.validateBeforeUpdate(component, event);
        
        console.log("requiredValidationResponse: "+requiredValidationResponse);
        if(requiredValidationResponse == 'VALID'){
            helper.updateQuoteLineItems(component,event);
        }
        else{
            helper.showToast(component,'error','ERROR',requiredValidationResponse);
        }
    }
})