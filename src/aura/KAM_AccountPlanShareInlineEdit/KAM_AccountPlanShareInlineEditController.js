({
    doInit: function(component, event, helper) {  
       // helper.fetchAccessLevelPicklist(component);
    },
	inlineEditAccessLevel : function(component,event,helper){ 
        // show the rating edit field popup 
        component.set("v.accessLevelEditMode", true); 
        // after set AccessLevel true, set picklist options to picklist field 
        //component.find("accRating").set("v.options" , component.get("v.AccessLevel1"));
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("accRating").focus();
        }, 100);
    },
    onRatingChange : function(component,event,helper){ 
        // if picklist value change,
        // then show save and cancel button by set attribute to true
        component.set("v.showSaveCancelBtn",true);
    },
    closeRatingBox : function (component, event, helper) {
       // on focus out, close the input section by setting the 'ratingEditMode' att. as false
        component.set("v.accessLevelEditMode", false); 
    },
    removeAccess : function(component, event, helper) {
        debugger;
        var acctplanshareId=component.get('v.singleRec.Id');
         helper.removeAccessHelper(component,event,acctplanshareId);
    }
})