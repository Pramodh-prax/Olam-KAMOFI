({
    requiredValidation : function(component,event) {
        // get all accounts.. 	
        var allRecords = component.get("v.OpportunityLineItemList");
        var isValid = true;
        // play a for loop on all account list and check that account name is not null,   
        for(var i = 0; i < allRecords.length;i++){
            if(allRecords[i].Product2.Name == null || allRecords[i].Product2.Name.trim() == ''){
                alert('Complete this field : Row No ' + (i+1) + ' Name is null' );
                isValid = false;
            }  
        }
        return isValid;
    },
    doInit : function (component, event) {
        component.set ('v.isLoading', true);
        let fetchOpportunityLineItemPromise = this.invokeApex (component, 'c.fetchOpportunityLineItem', {
            "opportunityId": component.get("v.recordId")
        });
        let getselectOptionsSamplingPromise = this.invokeApex (component, 'c.getselectOptions', {
            "objObject": component.get("v.objInfoForPicklistValues"),
            "fld": 'Sampling_Status__c'
        });
        let getselectOptionsUnitOfMeasurePromise = this.invokeApex (component, 'c.getselectOptions', {
            "objObject": component.get("v.objInfoForPicklistValues"),
            "fld": 'Unit_of_measure__c'
        });
        let getselectOptionsReasonforResamplingPromise = this.invokeApex (component, 'c.getselectOptions', {
            "objObject": component.get("v.objInfoForPicklistValues"),
            "fld": 'Reason_for_Resampling__c'
        });
        Promise.all ([
            	fetchOpportunityLineItemPromise, 
                getselectOptionsSamplingPromise,
            	getselectOptionsUnitOfMeasurePromise,
            	getselectOptionsReasonforResamplingPromise
		]).then (
            $A.getCallback (results => {
                component.set("v.OpportunityLineItemList", results[0]);
                this.updatePickListVals (component, 'SamplingStatusPicklistOptsStr', results[1]);
                this.updatePickListVals (component, 'UnitofmeasurePicklistOptsStr', results[2]);
                this.updatePickListVals (component, 'ReasonforResamplingPicklistOptsStr', results[3]);
                component.set ('v.isDataLoaded', true);
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback ((error) => {
                //handle error
                console.log ('Error ' + JSON.stringify (error));
                this.showToast (component, 'error', 'Error', this.normalizeError (error));
                component.set ('v.isDataLoaded', true);
                component.set ('v.isLoading', false);
            })
        )
        
    },
	showToast : function (component, type, title, message) {
    	var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
        	toastEvent.setParams({
                "type": type,
                "title": title,
                "message": message
            });
            toastEvent.fire();                    
        } else {
            alert (title + ' ' + message);
        }
    },
	updatePickListVals : function (component, picklistOptsAttributeName, allValues) {
     	
 		var opts = [];
        if(allValues != undefined && allValues != null){
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: "",
                selected : true
            });
        }
        
        for(var key in allValues){
        console.log('key : '+ key+ 'Map value: ', allValues[key]);
        opts.push({
                class: "optionClass",
                label: key,
                value: allValues[key],
                selected : false
            });
    }
        component.set("v." + picklistOptsAttributeName, JSON.stringify (opts));               
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
 	normalizeError : function (errors) {
    	let message = 'Error';
        if (errors && Array.isArray (errors) && errors.length > 0 ) {
            for (let index = 0; index < errors.length; index ++) {
                let error = errors[index];
                if (error && error.message) {
                    message += (' : ' + error.message);  
                }
                if (error && error.fieldErrors && Object.keys(error.fieldErrors).length > 0) {
                    Object.keys(error.fieldErrors).forEach (eachKey => {
                        if (error.fieldErrors[eachKey] && Array.isArray (error.fieldErrors[eachKey]) && error.fieldErrors[eachKey].length > 0) {
                        	error.fieldErrors[eachKey].forEach (ele => {
                        		message += (' : ' + ele.message);
                    		})
                    	}
                		else{
                            message += ' : ' + error.pageErrors[eachKey].message;
                        }
                    });
                }else if (error && error.duplicateResults && Object.keys(error.duplicateResults).length > 0) {
                	Object.keys(error.duplicateResults).forEach (eachKey => {
                        if (error.duplicateResults[eachKey] && Array.isArray (error.duplicateResults[eachKey]) && error.duplicateResults[eachKey].length > 0) {
                        	error.duplicateResults[eachKey].forEach (ele => {
                        		message += (' : ' + ele.message);
                    		})
                    	}
    					else{
                            message += ' : ' + error.pageErrors[eachKey].message;
                        }
                    });   
                }else if (error && error.pageErrors && Object.keys(error.pageErrors).length > 0) {
                	Object.keys(error.pageErrors).forEach (eachKey => {
                        if (error.pageErrors[eachKey] && Array.isArray (error.pageErrors[eachKey]) && error.pageErrors[eachKey].length > 0) {
                        	error.pageErrors[eachKey].forEach (ele => {
                        		message += (' : ' + ele.message);
                    		})
                    	}
                        else{
                            message += ' : ' + error.pageErrors[eachKey].message;
                        }
                    });    
                }
            }
        }
		return message;
	}
})