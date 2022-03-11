({              
    submit : function (component, event) {
        component.set ('v.isLoading', true);
        let button = component.find('disableEnableButtonId');
    	button.set('v.disabled',true);
        this.invokeApex (component, 'c.createSampleRequest', {
            "opportunityId": component.get("v.recordId")
        }).then (
            $A.getCallback (result => {
                console.log(result);
                
                if(result === 'SUCCESS'){
                	this.handleShowNotice(component, event, 'Sample request submitted successfully.', 'Success!', 'success');
            		$A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();				
                }
                else{
                	this.handleShowNotice(component, event, result, 'Something went wrong!', 'error');
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
    }
})