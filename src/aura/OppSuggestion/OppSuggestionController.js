({
	doInit : function(component, event, helper) {
        helper.getSuggestionOpps(component, event);
    },
    onGetSuggestionOpps : function(component, event, helper) {
        console.log('onGetSuggestionOpps');
		helper.getSuggestionOpps(component, event);
    },
    onCopy : function(component, event, helper) { 
        if (confirm('Are you sure to copy this item?')) {
        	helper.copy(component, event);    
        }
    },
})