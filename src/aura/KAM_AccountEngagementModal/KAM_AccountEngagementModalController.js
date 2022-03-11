({
    doInit : function(component, event, helper) {
        helper.doInit (component, event);
    },
    closeModel: function(component, event, helper) {  
        //component.get ('v.engComp').destroy ();
        component.destroy ();
    }
})