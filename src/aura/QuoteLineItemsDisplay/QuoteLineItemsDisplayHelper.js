({
     /*doInitHelper2 : function(component, event, helper){
            //component.set("v.quoteStatus",'');
            var action = component.get("c.fetchQuoteLineItems"); 
            action.setParams({
                quoteId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.totalRecordsCount", response.getReturnValue().length);
                    component.set("v.listOfQuoteLineItems", response.getReturnValue());
                    var quoteStatus = ''; 
                    var hasContactId = false;
                    if(response.getReturnValue().length>0){
                        for (var i = 0; i < response.getReturnValue().length; i++) {
                                //component.set("v.quoteStatus", response.getReturnValue()[i].Quote.Status);
                                quoteStatus = response.getReturnValue()[i].Quote.Status
                                console.log('Status: '+quoteStatus);
                                break;
                        }
                    }
                    component.set("v.quoteStatus", quoteStatus);
                    console.log('quoteStatus: '+component.get("v.quoteStatus"));
                }
                else if(state === "ERROR"){
                    console.log('A problem occurred: ' + JSON.stringify(response.error));
                }
            });
            $A.enqueueAction(action);
     },*/
    
    doInitHelper : function(component, event, helper){
        var quoteId = component.get("v.recordId");
        console.log('quoteId: ' + quoteId);
        let fetchQuoteLineItemsPromise = this.invokeApex (component, 'c.fetchQuoteLineItems', {
            "quoteId": quoteId
        });
        let fetchQuoteDetailsPromise = this.invokeApex (component, 'c.fetchQuoteDetails', {
            "quoteId": quoteId
        });
        
        Promise.all ([
                fetchQuoteLineItemsPromise,
                fetchQuoteDetailsPromise
		]).then (
            $A.getCallback (results => {
                    component.set("v.totalRecordsCount", results[0].length);
                    component.set("v.listOfQuoteLineItems", results[0]);
                    component.set("v.quoteRecord", results[1]);
            })
        ).catch (
            $A.getCallback ((error) => {
                //handle error
                console.log ('Error ' + JSON.stringify (error));
                this.showToast (component, 'error', 'Error', this.normalizeError (error));
            })
        )
     },
    
    deleteQuoteLineItemsHelper : function (component, event, helper) {
        var allRecords = component.get("v.listOfQuoteLineItems");
        var selectedRecords = [];
       // var isApprovalStatusAccepted = false;
        var isApprovalStatusInProgress = false;
        
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        
        for (var i = 0; i < selectedRecords.length; i++) {
           // if(selectedRecords[i].Approval_Status__c == 'Accepted')
          //  {
           //     isApprovalStatusAccepted = true;
           // }
            
            if(selectedRecords[i].Approval_Status__c == 'In Progress')
            {
                var isApprovalStatusInProgress = true;
            }
        }
        
        if(selectedRecords.length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'ERROR',
                message: 'No Quote Line Items are selected. Please select atleast one and proceed.',
                duration:' 4000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else if(isApprovalStatusInProgress == true)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'ERROR',
                message: 'Approval \'Accepted/In Progress\' Records Can Not Be Deleted. Please UnSelect Those Records',
                duration:' 4000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else{
            //component.set('v.screenName', 'DELETE_PRODUCTS');
            console.log("v.screenName: "+component.get("v.screenName"));
            component.set("v.selectedQuoteLineItems", selectedRecords);
            component.set('v.screenName', 'DELETE_PRODUCTS');
        }
    },
    
    editQuoteLineItemsHelper : function (component, event, helper) {
        var allRecords = component.get("v.listOfQuoteLineItems");
        var selectedRecords = [];
        var isApprovalStatusInProgress = false;
        
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        
        for (var i = 0; i < selectedRecords.length; i++) {
            
            if(selectedRecords[i].Approval_Status__c == 'In Progress')
            {
                var isApprovalStatusInProgress = true;
            }
        }
        
            
        if(selectedRecords.length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'ERROR',
                message: 'No Quote Line Items are selected. Please select atleast one and proceed.',
                duration:' 4000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else if(isApprovalStatusInProgress == true)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'ERROR',
                message: 'Approval \'In Progress\' Records Can Not Be Edited. Please UnSelect Those Records',
                duration:' 4000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else{
            console.log("v.screenName: "+component.get("v.screenName"));
            component.set("v.selectedQuoteLineItems", selectedRecords);
            component.set('v.screenName', 'EDIT_PRODUCTS');
        }
    },
    
    showConfigurations: function (component, event, helper) {
    	var recordId = event.getSource().get('v.value');
        
        $A.createComponent('c:QuoteLineProductConfigurations', {
            recordId : recordId
        },
        (configComp, status, errorMessage) => {
            if (status === 'SUCCESS') {
                component.set ('v.productConfigComp', configComp)
            } else if (status === 'INCOMPLETE') {
                console.log ('No response from server or client is offline.');
            } else if (status === 'ERROR') {
                console.log (errorMessage);
            }
    	}
    )},
   deleteFilesHelper : function(component, event, listOfContentDocIds){
            var action = component.get("c.deleteFiles"); 
            action.setParams({
                "listOfContentDocIds": listOfContentDocIds
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {                
                }
                else if(state === "ERROR"){
                    console.log('A problem occurred: ' + JSON.stringify(response.error));
                }
            });
            $A.enqueueAction(action);
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
})