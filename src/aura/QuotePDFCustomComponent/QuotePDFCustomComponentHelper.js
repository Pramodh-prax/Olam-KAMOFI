({
	savePDF : function (component, event, sendEmail) {
        component.set ('v.isLoading', true);
        let button = component.find('saveButtonId');
        let button2 = component.find('sendEamilButtonId');
        
    	button.set('v.disabled',true);
        button2.set('v.disabled',true);
        
        this.invokeApex (component, 'c.createDoc', {
                "quoteId": component.get("v.recordId")
            
        }).then (
            $A.getCallback (result => {
                console.log(result);
                
                
                if(result.message === 'SUCCESS'){
                
                	this.handleShowNotice(component, event, 'Quote PDF Saved Successfully.', 'Success!', 'success');
                    
                	if(sendEmail == true){
                        this.sendEmail(component, event, result.docId, result.conEmail);
                    }	
                
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
    },
 

 	sendEmail : function(component, event, docId, toAddress) {
        var actionAPI = component.find("quickActionAPI");
        
    	var subject = "Quote Email";
    	var emailBody = "Hi, <br/><br/> This is test quote email";
    
        var fields = {Subject: {value: subject}, HtmlBody: {value: emailBody}, ToAddress: {value: toAddress}, ContentDocumentIds: {value: docId}};
        var args = {actionName: "Quote.SendEmail", targetFields: fields};
                      
        actionAPI.setActionFieldValues(args).then(function(result){
            console.log(result);
        }).catch(function(e){
            if(e.errors){
                //If the specified action isn't found on the page, show an error message in the my component
            }
        });
    }
})