({
    
    doInit: function(component, event, helper) {
        // call the fetchPickListVal(component, field_API_Name, aura_attribute_name_for_store_options) -
        // method for get picklist values dynamic   
        var defaultRecord = {};
        var currentRecord = component.get("v.singleRec");
        defaultRecord.Name = currentRecord.Product2.Name;
        defaultRecord.Id = currentRecord.Product2Id;
        component.set("v.selectedLookUpRecord",defaultRecord);
        component.set("v.Product2IdEditMode", true); 
       
        let UnitofmeasurePicklistOpts = JSON.parse (component.get ('v.UnitofmeasurePicklistOptsStr'));
        if (UnitofmeasurePicklistOpts 
            && UnitofmeasurePicklistOpts !== null
            && currentRecord.Unit_of_measure__c
            && typeof UnitofmeasurePicklistOpts !== 'undefined') 
        {
            UnitofmeasurePicklistOpts.forEach (ele => {
                ele = Object.assign (ele, {
	                selected : (currentRecord.Unit_of_measure__c && currentRecord.Unit_of_measure__c.toLowerCase () === ele.value.toLowerCase ()) ? true : false
            	});   
            });
        }
    	component.set ('v.UnitofmeasurePicklistOpts', UnitofmeasurePicklistOpts);
    
    	let SamplingStatusPicklistOpts = JSON.parse (component.get ('v.SamplingStatusPicklistOptsStr'));
        if (SamplingStatusPicklistOpts 
            && SamplingStatusPicklistOpts !== null
    		&& currentRecord.Sampling_Status__c
            && typeof SamplingStatusPicklistOpts !== 'undefined') 
        {
            SamplingStatusPicklistOpts.forEach (ele => {
                ele = Object.assign (ele, {
    				selected : (currentRecord.Sampling_Status__c && currentRecord.Sampling_Status__c.toLowerCase () === ele.value.toLowerCase ()) ? true : false
            	});  
            });
		}
        component.set ('v.SamplingStatusPicklistOpts', SamplingStatusPicklistOpts);
        
		let ReasonforResamplingPicklistOpts = JSON.parse (component.get ('v.ReasonforResamplingPicklistOptsStr'));
        if (ReasonforResamplingPicklistOpts 
            && ReasonforResamplingPicklistOpts !== null
    		&& currentRecord.Reason_for_Resampling__c
            && typeof ReasonforResamplingPicklistOpts !== 'undefined') 
        {
            ReasonforResamplingPicklistOpts.forEach (ele => {
                ele = Object.assign (ele, {
    				selected : (currentRecord.Reason_for_Resampling__c && currentRecord.Reason_for_Resampling__c.toLowerCase () === ele.value.toLowerCase ()) ? true : false
            	});  
            });
		}
        component.set ('v.ReasonforResamplingPicklistOpts', ReasonforResamplingPicklistOpts);
		
    },
    handleComponentEvent : function(component, event, helper) {	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
       var selectedOpportunityLineItemId = event.getParam("opportunityLineItemId");
	   
        var selectedProduct = component.get("v.selectedLookUpRecord");
        var currentRecord = component.get("v.singleRec");
        currentRecord.Product2.Name = selectedProduct.Name;
        currentRecord.Product2Id = selectedProduct.Id;

        component.set("v.singleRec",currentRecord);
        if(component.get("v.selectedLookUpRecord") != ''){ 
            component.set("v.showSaveCancelBtn",true);
        }
    }, 
    checkifResampling : function(component, event, helper){
      var samplingStatus = event.getSource().get("v.value");
      if(samplingStatus == '10'){
        component.set("v.ReasonForResamplingBoolean",false);
      }
      else{
      	component.set("v.ReasonForResamplingBoolean",true);      
      }
    },
})