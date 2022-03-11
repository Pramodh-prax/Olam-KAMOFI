({
    cancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    savePDF : function(component,event,helper){
        helper.savePDF(component, event, false);
    },
    
    sendEmail : function(component,event,helper){
        helper.savePDF(component, event, true);
    }
})