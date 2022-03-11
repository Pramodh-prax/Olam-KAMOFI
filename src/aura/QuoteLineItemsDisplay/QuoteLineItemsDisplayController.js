({
    doInit : function(component,event,helper){	
        helper.doInitHelper(component, event, helper); 
        console.log('quoteStatus: '+component.get("v.quoteStatus"));
    },
    /*addProduct2 : function (component, event, helper) {
        var quoteStatus = component.get("v.quoteStatus"); 
        
        if(quoteStatus =='Presented To Customer' || quoteStatus =='Customer Accepted' || quoteStatus =='Customer Denied' ){
            var errorMessage = 'Products cannot be added to the Quote when the Quote Status is '+quoteStatus;
            helper.showToast(component,'error','ERROR',errorMessage);
        }
        else{
            component.set('v.screenName', 'ADD_PRODUCTS');
            console.log("v.screenName"+component.get("v.screenName")); 
        }
    },*/
    addProduct : function (component, event, helper) {
        var quoteRecord = component.get("v.quoteRecord"); 
        if(quoteRecord){
            var errorMessage ='';
            if(!quoteRecord.Opportunity.ContactId){
                errorMessage = 'Ensure a Valid Contact is selected before adding a product.';
                helper.showToast(component,'error','ERROR',errorMessage); 
            }
            else if(quoteRecord.Status =='Presented To Customer' || quoteRecord.Status =='Customer Accepted' || quoteRecord.Status =='Customer Denied' ){
                errorMessage = 'Products cannot be added to the Quote when the Quote Status is '+quoteRecord.Status;
                helper.showToast(component,'error','ERROR',errorMessage);
            }
            else{
              	component.set('v.screenName', 'ADD_PRODUCTS');
                console.log("v.screenName"+component.get("v.screenName")); 
            }
        }
        
    },
    deleteQuoteLineItems : function (component, event, helper) {
        helper.deleteQuoteLineItemsHelper(component, event);
    },
    
    editQuoteLineItems : function (component, event, helper) {
        helper.editQuoteLineItemsHelper(component, event);
    },
    handleAddQuoteLineItemToParentCompEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var eventAction = event.getParam("action");
        var listOfContentDocIds = event.getParam("listOfContentDocIds");
        
        console.log('eventAction: '+eventAction);
        console.log('listOfContentDocIds: '+listOfContentDocIds);
        if(eventAction == 'CANCEL'){
            if(listOfContentDocIds && listOfContentDocIds.length >0){
                //Delete the uploaded files on cancel and then close the comp
                helper.deleteFilesHelper(component, event,listOfContentDocIds);
            }
            //Directly close the comp
            component.set('v.screenName', '');
        }
        if(eventAction == 'CLOSE_AND_REFRESH_VIEW'){
            component.set('v.screenName', '');
            helper.doInitHelper(component, event, helper);
            $A.get('e.force:refreshView').fire();
        }
    },
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var listOfAllProducts = component.get("v.listOfQuoteLineItems");
        
        for (var i = 0; i < listOfAllProducts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllProducts[i].isChecked = true;
                component.set("v.selectedCount", listOfAllProducts.length);
            } else {
                listOfAllProducts[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllProducts[i]);
        }
        component.set("v.listOfQuoteLineItems", updatedAllRecords);
    },
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
    
    showConfigurations: function(component, event, helper){
        helper.showConfigurations(component, event, helper);
    }
})