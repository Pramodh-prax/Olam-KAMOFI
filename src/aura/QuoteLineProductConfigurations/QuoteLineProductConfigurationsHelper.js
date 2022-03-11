({
	doInit : function(component, event, helper){
        component.set ('v.isLoading', true);
        
        this.invokeApex (component, 'c.getConfigurations', {
            "recordId": component.get("v.recordId")
        }).then (
            $A.getCallback (result => {
                console.log(result);
                var resultTemp = JSON.parse(result);
                if(resultTemp.message === 'SUCCESS'){
                	//this.handleShowNotice(component, event, 'Quote PDF Saved Successfully.', 'Success!', 'success');
                	//Commented and changed/added as part of SAP API JSON change
                	//component.set("v.productConfigurations", result.productConfigList);
                	
                	var productConfigurationsSAP = resultTemp.productConfigSAP;
                    var configList = productConfigurationsSAP.configurations;
                    console.log ('productConfigurationsSAP: ' + productConfigurationsSAP);
                    console.log ('configList: ' + configList);
                	component.set("v.productConfigurationsSAP", productConfigurationsSAP);	
                	component.set ('v.isLoading', false);
                }
                else{
                	this.handleShowNotice(component, event, resultTemp, 'Something went wrong!', 'error');
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
                
                
    handleSubmit : function(component, event, helper){
        component.set ('v.isLoading', true);
        
        //Commented and changed/added as part of SAP API JSON change
        //var productConfig = component.get("v.productConfigurations");
        console.log (' productConfigurationsSAP: ' + component.get("v.productConfigurationsSAP"));
        var productConfigSAP = component.get("v.productConfigurationsSAP");
        
        //Commented as Input range/Customer Range made non required
        //var isValid = this.validateConfigData(productConfigSAP.configurations);
        var isValid = true;
        
        productConfigSAP = JSON.stringify(productConfigSAP);
        console.log('Before Passing '+productConfigSAP);
        if(isValid){
            this.invokeApex (component, 'c.saveConfigurtions', {
                "recordId": component.get("v.recordId"),
                "tempProdConfig": productConfigSAP
            }).then (
                $A.getCallback (result => {
                    console.log(result);
                    
                    if(result === 'SUCCESS'){
                        var popupWindow = component.find('modalDiv').getElement();
                        
                        component.set ('v.isLoading', true);
                        
                        if(popupWindow){
                            popupWindow.style.display = 'none';
                        }
                    
                        this.showToast(component, event, helper, "Configurations updated successfully!");			
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
        }
        else{
             this.handleShowNotice(component, event, 'Product configurations cannot be blank', 'Something went wrong!', 'error');  
             component.set ('v.isLoading', false);
        }
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
 
                            
 	handleShowNotice : function(component, event, message, header, variant) {
        component.find('notifLib').showNotice({
            "variant": variant,
            "header": header,
            "message": message,
            closeCallback: function() {
                
            }
        });
    },
    
    
    showToast : function(component, event, helper, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": message
        });
        toastEvent.fire();
    },
    
    
    validateConfigData : function(productConfig){
        var isValid = true;
        for (let i = 0; i < productConfig.length; i++) {
            if(productConfig[i].customer_range == ''){
                isValid = false;
            }
        }
        return isValid;
    }
})