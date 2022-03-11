({
    submit : function(component,event,helper){
        helper.submit(component, event);
    },
    
    cancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})