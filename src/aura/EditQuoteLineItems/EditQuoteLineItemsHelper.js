({
    editQuoteLineItems : function(component, event){
        console.log ('editQuoteLineItems 1 ');
        component.set ('v.isLoading', true);
        debugger;
        var selectedQuoLIList = component.get("v.listOfQuoteLineItemsToEdit");
        var quoteId = component.get("v.recordId");
        
        let fetchLineItemWrapperPromise = this.invokeApex (component, 'c.fetchLineItemWrapper', {
            "QuoLIList":selectedQuoLIList,
            "QuoteId": quoteId
        });
        let fetchIsApprovalRequiredPromise = this.invokeApex (component, 'c.getIsApprovalRequiredValues', {
            "QuoteId": quoteId
        });
        let getUnitOfMeasurePromise = this.invokeApex (component, 'c.getselectOptions', {
            "objObject": component.get("v.QuoteLineItemForPicklistValues"),
            "fld": 'Unit_Of_Measure__c'
        });
        
        Promise.all ([
            fetchLineItemWrapperPromise,
            fetchIsApprovalRequiredPromise,
            getUnitOfMeasurePromise
        ]).then (
            $A.getCallback (results => {
            var oRes = results[0];
                console.log ('oRes: '+oRes);
                if(oRes.length > 0)
                {
                    console.log ('oRes inside: '+oRes);
                	component.set("v.bNoRecordsFound" , false);
                	component.set ('v.isLoading', false);
                	component.set('v.listOfAllSelectedProducts', oRes);
            	}
				else
				{
                    component.set("v.bNoRecordsFound" , true);
            		component.set ('v.isLoading', false);
            	}
        
    	if(results[1].length > 0)
        {
            console.log ('results[1]: '+results[1]);
    		this.updatePickListVals (component, 'isPLMApprovalRequiredOptions', results[1]);
		}
 		if(results[2].length > 0){
    console.log ('results[2]: '+results[2]);
    		this.updatePickListVals (component, 'unitofmeasurePicklistOpts', results[2]);
		}
     	}) ).catch (
    		$A.getCallback ((error) => {
        	//handle error
        	console.log ('Error ' + JSON.stringify (error));
        	this.showToast (component, 'error', 'Error', this.normalizeError (error));
        	//component.set ('v.isDataLoaded', true);
        	component.set ('v.isLoading', false);
    	})
        )   
    },
        
        invokeApex: function (component, functionName, paramsObj, isBackground) {
            
            let promise = new Promise((resolve, reject) => {
                
                let action = component.get(functionName);
                
                if (paramsObj != undefined) {
                action.setParams(paramsObj);
            }
              if (isBackground) {
                action.setBackground();
            }
            action.setCallback(this, (response) => {
                let state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
                resolve(response.getReturnValue());
            } else {
                               reject(Error(this.getErrorMsg(response)));
        }
    })
    $A.enqueueAction(action);

});

return promise;
},
    updatePickListVals : function (component, picklistOptsAttributeName, allValues) {
        
        var opts = [];
        /*if (allValues != undefined && allValues.length > 0) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
        }*/
        for (var i = 0; i < allValues.length; i++) {
            opts.push({
                class: "optionClass",
                label: allValues[i],
                value: allValues[i]
            });
        }
        component.set("v." + picklistOptsAttributeName, opts);               
    },
        showToast : function (component, type, title, message) {
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    "type": type,
                    "title": title,
                    "message": message,
                    "duration":' 4000',
                    "key": 'info_alt',
                    "mode": 'dismissible'
                });
                toastEvent.fire();                    
            } else {
                alert (title + ' ' + message);
            }
        },
            normalizeError : function (errors) {
                let message = 'Error';
                if (errors && Array.isArray (errors) && errors.length > 0 ) {
                    for (let index = 0; index < errors.length; index ++) {
                        let error = errors[index];
                        if (error && error.message) {
                            message += (' : ' + error.message);  
                        } else if (error && error.fieldErrors && Object.keys(error.fieldErrors).length > 0) {
                            Object.keys(error.fieldErrors).forEach (eachKey => {
                                if (error.fieldErrors[eachKey] && Array.isArray (error.fieldErrors[eachKey]) && error.fieldErrors[eachKey].length > 0) {
                                error.fieldErrors[eachKey].forEach (ele => {
                                message += (' : ' + ele.message);
                            })
                        }
                    });
                } else if (error && error.duplicateResults ) {
                    message += ' : ' + JSON.stringify(error.duplicateResults);    
                } else if (error && error.pageErrors  ) {
                    message += ' : ' + JSON.stringify(error.pageErrors);    
                }
            }
}
return message;
},
    updateQuoteLineItems : function(component,event)
    {
        component.set ('v.isLoading', true);
        var listToUpdate = component.get('v.listOfAllSelectedProducts');
        var quoteId = component.get("v.recordId");
        
        var action = component.get('c.updateQuoteLineItem');
        
        action.setParams({
            "QuoteId":quoteId,
            "lstLineItemWrapper":listToUpdate
        });
        
        action.setCallback(this,function(response){
            component.set ('v.isLoading', false);
            var state = response.getState();
            if(state == "SUCCESS")
            {
                if (response.getReturnValue() == 'SUCCESS') {
                    // success toast and close component and quickrefresh
                    this.showToast(component,'success','SUCCESS','All the selcted products are successfully Updated to Quote.');
                    
                    //To close refresh view
                    var AddQuoteLineItemToParentCompEvent = component.getEvent("AddQuoteLineItemToParentCompEvent");
                    AddQuoteLineItemToParentCompEvent.setParams({"action" : 'CLOSE_AND_REFRESH_VIEW'});
                    AddQuoteLineItemToParentCompEvent.fire();
                } 
                else {
                    // Error toast with error message
                    this.showToast(component,'error','ERROR',response.getReturnValue());
                }
            }
            else
            {
                this.showToast(component,'error','ERROR',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    validateBeforeUpdate : function (component,event) {
        var returnString ='VALID';
        var listOfAllSelectedProducts = component.get("v.listOfAllSelectedProducts");
        for (var i = 0; i < listOfAllSelectedProducts.length; i++) {
            if ( !listOfAllSelectedProducts[i].unitPrice || listOfAllSelectedProducts[i].unitPrice == undefined || listOfAllSelectedProducts[i].unitPrice == null || listOfAllSelectedProducts[i].unitPrice =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Unit Price is Required. Please fill and Proceed.';
                break;
            }
            else if ( !listOfAllSelectedProducts[i].volume || listOfAllSelectedProducts[i].volume == undefined || listOfAllSelectedProducts[i].volume == null || listOfAllSelectedProducts[i].volume =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Volume is Required. Please fill and Proceed.';
                break;
            }
            else if ( !listOfAllSelectedProducts[i].unitOfMeasure || listOfAllSelectedProducts[i].unitOfMeasure == undefined || listOfAllSelectedProducts[i].unitOfMeasure == null || listOfAllSelectedProducts[i].unitOfMeasure =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Unit Of Measure is Required. Please fill and Proceed.';
                break;
            }
            else if (listOfAllSelectedProducts[i].isPLMApprovalRequired =="No" && listOfAllSelectedProducts[i].isFileUploaded == false)
            {
                returnString = 'Row No: ' + (i+1)+ '. File uploading is Required. Please upload the file and Proceed.';
                break;
            }
            else{
             console.log('all data valid for this item');      
            }
        }
        return returnString;
    },
})