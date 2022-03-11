({
	onValidate : function(component, event) {
        var action = component.get("c.validate");
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
                var missingFields = response.getReturnValue();
                var missingFieldsString = missingFields.join(', ');
                
                if (missingFields && missingFields.length) {
                    component.set("v.modalContext", 'Please fill the fields: ' + missingFieldsString);
                } else {
                    component.set("v.modalContext", '');
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Validation",
                    "type": missingFields && missingFields.length ? 'error' : "success",
                    "message": missingFields && missingFields.length ? 'Please fill the fields: ' + missingFieldsString : 'Success!'
                });
                toastEvent.fire();
            }
        });
        component.set("v.spinnerWaiting", true);
        $A.enqueueAction(action);
    }
})