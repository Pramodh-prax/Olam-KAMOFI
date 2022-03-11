/**
 * @description       : JS controller for the RemoveOpportunityProductControler component.
 * @author            : Bharatesh Shetty
 * @group             : 
 * @last modified on  : 09-02-2021
 * @last modified by  : Bharatesh Shetty
**/
({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
       
    },
    
    closefunc: function(component, event, helper) {
           var dismissActionPanel = $A.get("e.force:closeQuickAction");
               dismissActionPanel.fire(); 
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
    
    //For Delete selected records 
    deleteSelected: function(component, event, helper) {
        console.log("inside deleteselected function");
        let allRecordsToRemove = component.get("v.listOfAllSelectedOppLineItes");
        let reasonFilledForAllRemovedItems = true;
        
        console.log("all records to remove",allRecordsToRemove.length);
       
        for (var i = 0; i < allRecordsToRemove.length; i++) {
            console.log("inside for loop ");  
            // var reason = allRecordsToRemove[i].reasonForRemoval.trim(); 
            
            /*console.log("reason "+i+" : "+allRecordsToRemove[i].reasonForRemoval);
            if (!allRecordsToRemove[i].reasonForRemoval || allRecordsToRemove[i].reasonForRemoval == undefined) {
                if(allRecordsToRemove[i].reasonForRemoval.trim() == "" || allRecordsToRemove[i].reasonForRemoval == ""){
                    reasonFilledForAllRemovedItems = false;
                    break;
                }
            }*/
            
            
            let reason = allRecordsToRemove[i].reasonForRemoval; 
            console.log("reason check",reason);
           
            if ( !reason || reason == undefined || reason==null || (reason.startsWith(" ") && reason.endsWith(" ")) || reason =="")
            {
                reasonFilledForAllRemovedItems = false;
                 break;
                
            }
        }
        console.log("reasonFilledForAllRemovedItems: "+reasonFilledForAllRemovedItems);
        if(reasonFilledForAllRemovedItems == true){
            helper.deleteSelectedHelper(component, event, allRecordsToRemove);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'ERROR',
                message: 'Please fill the reason for removal for all the products.',
                duration:' 4000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        // call the helper function and pass all selected record id's. 
        //Commented now for testing purpose  
    },
    showUpdateReasonForRemoval : function (component, event, helper) {
        var allRecords = component.get("v.listOfAllOppLineItes");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        if(selectedRecords.length > 0){
            component.set('v.screenName', 'UPDATE_REASON_FOR_REMOVAL');
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
        
        //If seected item ength is 0 then throw error.
    },
    showRemoveProduct : function (component, event, helper) {
        component.set('v.screenName', 'REMOVE_PRODUCTS');
        console.log("v.screenName"+component.get("v.screenName"));
    },
    closeRemoveProduct : function(component,event,helper){
        console.log('closeRemoveProduct');
        $A.get("e.force:closeQuickAction").fire();
    },
    displayTable : function (component, event, helper) {
        component.set("v.showTable", true);
        component.set("v.showParent", false);
        console.log("v.showTable"+component.get("v.showTable"));
        console.log("v.showParent"+component.get("v.showParent"));
        var allRecords = component.get("v.listOfAllOppLineItes");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        component.set("v.listOfAllSelectedOppLineItes", selectedRecords);
        console.log("selectedRecords: "+component.get("v.listOfAllSelectedOppLineItes"));
        //If seected item ength is 0 then throw error.
    },
    handleBackToRemoveOpportunityProductEvent : function (component, event, helper) {
        component.set("v.showTable", false);
        component.set("v.showParent", true);
        console.log("v.showTable"+component.get("v.showTable"));
        console.log("v.showParent"+component.get("v.showParent"));
        /*var allRecords = component.get("v.listOfAllOppLineItes");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        component.set("v.listOfAllSelectedOppLineItes", selectedRecords);*/
        console.log("selectedRecords: "+component.get("v.listOfAllSelectedOppLineItes"));
    },
})