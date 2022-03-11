({
	getSuggestionOpps : function(component, event) {
        console.log('getSuggestionOpps..........');
        var action = component.get("c.getSuggestionOpps");
        var recId = component.get("v.recordId");
        var self = this;
        action.setParams({
            recId: recId
        });
        action.setCallback(this, function(response) {
            component.set("v.spinnerWaiting", false);
            var state = response.getState();
            if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        return alert(errors[0].message);
                    }
                } else {
                    return console.log("Unknown error");
                }
            } else {
                var suggestionOpps = response.getReturnValue();
                console.log('suggestionOpps');
                console.log(suggestionOpps, suggestionOpps.length);
                if (suggestionOpps && suggestionOpps.length) {
                    for (const element of suggestionOpps) {
                        console.log("LOOP",element.TCBs__r.Unit_CTN__c);
                       // element.TCBs__r.Unit_CTN__c;
                    }
                    component.set("v.hasNoItem", false);
                }
                component.set("v.modalContext", 'suggestionOpps.length: ' + suggestionOpps.length);
                component.set("v.suggestionOpps", suggestionOpps);
            }
        });
        component.set("v.spinnerWaiting", true);
        $A.enqueueAction(action);
    },
    copy : function(component, event) {            
        var oppToCopyId = event.getSource().get("v.value");
        console.log('copy..........');
        var action = component.get("c.copy");
        var recId = component.get("v.recordId");
        var self = this;
        action.setParams({
            recId: recId,
            oppToCopyId: oppToCopyId
        });
        action.setCallback(this, function(response) {
            component.set("v.spinnerWaiting", false);
            var state = response.getState();
            if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        return alert(errors[0].message);
                    }
                } else {
                    return console.log("Unknown error");
                }
            } else {
                var ret = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Copy",
                    "type": !ret ? "error" : "success",
                    "message": ret ? 'Copy successfully!' : 'Something wrong, please try again!'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        component.set("v.spinnerWaiting", true);
        $A.enqueueAction(action);
    }
})