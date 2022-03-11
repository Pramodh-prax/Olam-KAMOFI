({              
    submit : function (component, event) {
        component.set ('v.isLoading', true);
        let button = component.find('disableEnableButtonId');
    	button.set('v.disabled',true);
        this.invokeApex (component, 'c.createQuote', {
            "oppId": component.get("v.recordId")
        }).then (
            $A.getCallback (result => {
                console.log(result);
                
                if(result.message === 'SUCCESS'){
                	this.showToast(component, event, helper, "New Quote Created!");
                	this.openQuoteRecord(component, event, helper, result.quoteId);	
					component.set ('v.isLoading', false);
                }
                else{
                	this.handleShowNotice(component, event, result.message, 'Something went wrong!', 'error');
                    component.set ('v.isDataLoaded', true);
                    component.set ('v.isLoading', false);	
            	}                	 
            })
        ).catch (
        	$A.getCallback ((error) => {
                console.log ('Error ' + JSON.stringify (error));
                this.handleShowNotice(component, event, error[0].message, 'Something went wrong!', 'error');
                component.set ('v.isDataLoaded', true);
                component.set ('v.isLoading', false);
            })
        )
    },
              
    
    handleShowNotice : function(component, event, message, header, variant) {
        component.find('notifLib').showNotice({
            "variant": variant,
            "header": header,
            "message": message,
            closeCallback: function() {
                
            }
        });
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
                    reject(response.getError());
                }
            })
            $A.enqueueAction(action);

        });

        return promise;
    },
 
 	openQuoteRecord : function (component, event, helper, quoteId) {
    	var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        	"recordId": quoteId,
             "slideDevName": "detail"
        });
        navEvt.fire();
    },
        
    showToast : function(component, event, helper, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": message
        });
        toastEvent.fire();
    },
})