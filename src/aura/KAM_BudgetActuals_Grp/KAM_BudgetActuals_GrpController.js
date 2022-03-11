({
    doInit : function(component, event, helper) {
        component.set ('v.selectedUnitOfMeasure', helper.DEFAULT_UNIT_OF_MEASURE);
		component.set ('v.options', helper.UNIT_OF_MEASURE_OPTIONS);      
        helper.doInit (component, event);
    },
    handleOnUnitOfMeasureChange : function(component, event, helper) {
		helper.handleOnUnitOfMeasureChange (component, event);
	}
    
})