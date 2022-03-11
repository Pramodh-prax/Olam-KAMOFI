({
	doInit : function(component,event,helper){	
        helper.doInit(component, event, helper); 
    },
    
    handleSubmit : function(component, event, helper){
        helper.handleSubmit(component, event, helper);
    },
    
    handleCloseModal : function(component, event, helper){
        var popupWindow = component.find('modalDiv').getElement();
        if(popupWindow){
            popupWindow.style.display = 'none';
        }
    }
})