({
	 selectUser : function(component, event, helper){      
    // get the selected user from list  
      var getSelectUser = component.get("v.UserName");
    // call the event   
      var compEvent = component.getEvent("KAM_AccountPlanShareUserList");
    // set the Selected user to the event attribute.  
         compEvent.setParams({"userByEvent" : getSelectUser,
                              "showUserdetail" : true});  
    // fire the event  
         compEvent.fire();
    }
})