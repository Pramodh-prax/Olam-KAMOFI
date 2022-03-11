({
    doInit : function(component, event, helper) {
        let selectedOption = component.get ('v.selectedOption');
        if (selectedOption && selectedOption !== '' && selectedOption !== null && typeof selectedOption !== 'undefined') {
            helper.updateOptionSelected (component, selectedOption);
        } else {
            let options = component.get ('v.options');
            let selectedVal;
            options.forEach (option => {
                if (option.checked) {
                    selectedVal = option.value;
                    return;
                }
            });
            if (selectedVal && selectedVal !== '' && selectedVal !== null && typeof selectedVal !== undefined) {
                component.set ('v.selectedOption', selectedVal);
            }
        }
    },
    handleRadioChange : function(component, event, helper) {
        event.stopPropagation ();
        component.set ('v.selectedOption', event.target.value);
        helper.updateOptionSelected (component, event.target.value);
    }
})