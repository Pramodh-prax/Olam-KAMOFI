/**
 * @description       : JS controller for the RequestForSampling component.
 * @author            : Bharatesh Shetty
 * @group             : 
 * @last modified on  : 09-06-2021
 * @last modified by  : Bharatesh Shetty
**/
({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
    },
    
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllOppLineItes");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllOppLineItes = component.get("v.listOfAllOppLineItes");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllOppLineItes.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllOppLineItes[i].isChecked = true;
                component.set("v.selectedCount", listOfAllOppLineItes.length);
            } else {
                listOfAllOppLineItes[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllOppLineItes[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfAllOppLineItes", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
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
    
    getSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.listOfAllOppLineItes");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objOpportunityLineItem);
            }
        }
        
        alert(JSON.stringify(selectedRecords)); 
    },
    
    //For processing the selected sampling requests 
    processSampleRequestsController: function(component, event, helper) {
        var allSamplingRequestToProcess = component.get("v.listOfAllSelectedOppLineItes");
        var requiredValidationResponse = helper.doRequiredValidation(allSamplingRequestToProcess);

        console.log("requiredValidationResponse: "+requiredValidationResponse);
        if(requiredValidationResponse == 'VALID'){
            helper.processSampleRequestsHelper(component, event, allSamplingRequestToProcess);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'ERROR',
                message: requiredValidationResponse,
                duration:' 4000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        
        /*var allSamplingRequestToProcess = component.get("v.listOfAllSelectedOppLineItes");
        helper.processSampleRequestsHelper(component, event, allSamplingRequestToProcess)*/
    },
    showUpdateDetails : function (component, event, helper) {
        var allRecords = component.get("v.listOfAllOppLineItes");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        if(selectedRecords.length > 0){
            component.set('v.screenName', 'UPDATE_DETAILS');
            console.log("v.screenName"+component.get("v.screenName"));
            component.set("v.listOfAllSelectedOppLineItes", selectedRecords);
            console.log("selectedRecords: "+component.get("v.listOfAllSelectedOppLineItes"));
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'ERROR',
                message: 'No products are selected. Please select atleast one and proceed.',
                duration:' 4000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },
    showAddProduct : function (component, event, helper) {
        component.set('v.screenName', 'ADD_PRODUCTS');
        console.log("v.screenName"+component.get("v.screenName"));
    },
    closeRemoveProduct : function(component,event,helper){
        console.log('closeRemoveProduct');
        $A.get("e.force:closeQuickAction").fire();
    },
    cancel : function(component,event,helper){
        // on cancel refresh the view (This event is handled by the one.app container. It’s supported in Lightning Experience, the Salesforce app, and Lightning communities. ) 
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire(); 
    }
})