({
   selectRecord : function(component, event, helper){      
    // get the selected record from list  
      var getSelectRecord = component.get("v.oRecord");
      var selectedOpliRecord = component.get("v.opliRecord"); 
    // call the event   
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
         compEvent.setParams({"recordByEvent" : getSelectRecord });
       	 compEvent.setParams({"opportunityLineItemId" :selectedOpliRecord});
    // fire the event  
         compEvent.fire();
    },
})