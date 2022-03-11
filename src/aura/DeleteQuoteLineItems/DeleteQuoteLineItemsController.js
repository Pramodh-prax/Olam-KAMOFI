({
    /*handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },*/
     
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
        var AddQuoteLineItemToParentCompEvent = component.getEvent("AddQuoteLineItemToParentCompEvent");
        AddQuoteLineItemToParentCompEvent.setParams({"action" : 'CANCEL' });
        AddQuoteLineItemToParentCompEvent.fire(); 
    },
     
    handleConfirmDialogYes : function(component, event, helper) {
        console.log('Yes');
        helper.deleteQuoteLineItemsHelper(component, event);
    },
})