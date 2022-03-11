({
	deleteQuoteLineItemsHelper: function(component, event) { 
        //call apex class method
        component.set ('v.isLoading', true);
        var listOfQuoteLineItemsToDelete = component.get("v.listOfQuoteLineItemsToDelete");
            
        var action = component.get('c.deleteQuoteLineItems');
        
        action.setParams({
            "listOfQuoteLineItemsToDelete": listOfQuoteLineItemsToDelete
        });
        action.setCallback(this, function(response) {
            component.set ('v.isLoading', false);
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() == 'SUCCESS') {
                    // success toast and close component and quickrefresh
                    this.showToast(component,'success','SUCCESS','All Selected Quote Line Items are successfuly deleted.');
                    component.set('v.showConfirmDialog', false);
                    //To close refresh view
                    var AddQuoteLineItemToParentCompEvent = component.getEvent("AddQuoteLineItemToParentCompEvent");
                    AddQuoteLineItemToParentCompEvent.setParams({"action" : 'CLOSE_AND_REFRESH_VIEW'});
                    AddQuoteLineItemToParentCompEvent.fire();
                } 
                else {
                    // Error toast with error message
                    this.showToast(component,'error','ERROR',response.getReturnValue());
                }
            }
            else{
                //Handle error
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function (component, type, title, message) {
    	var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
        	toastEvent.setParams({
                "type": type,
                "title": title,
                "message": message,
                "duration":' 4000',
                "key": 'info_alt',
                "mode": 'dismissible'
            });
            toastEvent.fire();                    
        } else {
            alert (title + ' ' + message);
        }
    },
})