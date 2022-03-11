({
    updateOptionSelected : function(component, selectedOption) {
        let options = component.get ('v.options');
        
        options.forEach (option => {
            option.checked = (option.value === selectedOption);
        });
        component.set ('v.options', options);
    }
})