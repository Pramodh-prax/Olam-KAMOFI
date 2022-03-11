/**
 * @description       : JS helper for the RequestForSampling component.
 * @author            : Bharatesh Shetty
 * @group             : 
 * @last modified on  : 09-06-2021
 * @last modified by  : Bharatesh Shetty
**/
({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    /*doInitHelper : function(component,event){ 
        debugger;
        var action = component.get("c.fetchOpportunityLineItemWrapper");
        console.log('recordId: '+ component.get("v.recordId"));
        component.set('v.screenName', 'ADD_PRODUCTS');
        action.setParams
        ({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('After callback: ');
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.length > 0){
                    component.set('v.listOfAllOppLineItes', oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                //    component.set("")
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllOppLineItes").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize)); 
                    component.set("v.currentPage", 1);
                 //currentPage = ceil(($startIndex - 1) / $itemsPerPage) + 1;
                 //  ((startIndex-1)/itemsPerPage) + 1,                 
                }
                else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);  
    },*/
    doInitHelper : function (component, event) {
        component.set ('v.isLoading', true);
        component.set('v.screenName', 'ADD_PRODUCTS');
        /*let mapOfPicklistFieldNameWithSobject = new Map([
            ['Unit_of_measure__c', component.get("v.OppLineItemForPicklistValues")],
            ['Target_Margin__c',component.get("v.OppForPicklistValues")],
            ['Key_Driver_to_Win_Project__c',component.get("v.OppForPicklistValues")]
          ]);*/
        //Promise to fetch wrapper
        let fetchOpportunityLineItemWrapperPromise = this.invokeApex (component, 'c.fetchOpportunityLineItemWrapper', {
            "recordId": component.get("v.recordId")
        });
        //Promise to pick List options
        /*let getPicklistOptionsPromise = this.invokeApex (component, 'c.getSelectOptionsForFields', {
            "mapOfPicklistFieldNameWithSobject": mapOfPicklistFieldNameWithSobject
        });*/
        let getUnitOfMeasurePromise = this.invokeApex (component, 'c.getselectOptions', {
            "objObject": component.get("v.OppLineItemForPicklistValues"),
            "fld": 'UoM__c'
        });
        let getTargetMarginPromise = this.invokeApex (component, 'c.getselectOptions', {
            "objObject": component.get("v.OppForPicklistValues"),
            "fld": 'Target_Margin__c'
        });
        let getKeyDriverPromise = this.invokeApex (component, 'c.getselectOptions', {
            "objObject": component.get("v.OppForPicklistValues"),
            "fld": 'Key_Driver_to_Win_Project__c'
        });
        Promise.all ([
                fetchOpportunityLineItemWrapperPromise, 
                getUnitOfMeasurePromise,
                getTargetMarginPromise,
                getKeyDriverPromise
		]).then (
            $A.getCallback (results => {
                component.set("v.OpportunityLineItemList", results[0]);
                console.log ('results[0] ' +results[0]);
                console.log ('results[1] ' +results[1]);
                console.log ('results[2] ' +results[2]);
                console.log ('results[3] ' +results[3]);
                /*this.updatePickListVals (component, 'unitofmeasurePicklistOpts', results[1].get('Unit_of_measure__c'));
                this.updatePickListVals (component, 'keyDriverToWinProjectPicklistOpts', results[1].get('Target_Margin__c'));
                this.updatePickListVals (component, 'targetMarginPicklistOpts', results[1].get('Key_Driver_to_Win_Project__c'));*/
                this.updatePickListVals (component, 'unitofmeasurePicklistOpts', results[1]);
                this.updatePickListVals (component, 'targetMarginPicklistOpts', results[2]);
                this.updatePickListVals (component, 'keyDriverToWinProjectPicklistOpts', results[3]);
                component.set ('v.isDataLoaded', true);
                component.set ('v.isLoading', false);
                var oRes = results[0];
                if(oRes.length > 0){
                    component.set('v.listOfAllOppLineItes', oRes);
                    var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                //    component.set("")
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllOppLineItes").length > i){
                            PaginationLst.push(oRes[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize)); 
                    component.set("v.currentPage", 1);
                 //currentPage = ceil(($startIndex - 1) / $itemsPerPage) + 1;
                 //  ((startIndex-1)/itemsPerPage) + 1,                 
                }
                else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                }
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
        if (allValues != undefined && allValues.length > 0) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
        }
        for (var i = 0; i < allValues.length; i++) {
            opts.push({
                class: "optionClass",
                label: allValues[i],
                value: allValues[i]
            });
        }
        component.set("v." + picklistOptsAttributeName, opts);               
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
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    processSampleRequestsHelper: function(component, event, allSamplingRequestToProcess) { 
        //call apex class method
        component.set ('v.isLoading', true);
        var action = component.get('c.processSampleRequests');
        debugger;
        // pass the all selected record's Id's to apex method 
        console.log("allSamplingRequestToProcess: "+allSamplingRequestToProcess);
        action.setParams({
            //"listOfSelectedOppLineItemWrapper": selectedRecords
            "listOfSelectedOppLineItemWrapper" : allSamplingRequestToProcess
        });
        action.setCallback(this, function(response) {
            component.set ('v.isLoading', false);
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(state);
                $A.get('e.force:refreshView').fire();
                console.log(response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                if (response.getReturnValue() != 'SUCCESS') {
                    console.log(response.getReturnValue());
                    toastEvent.setParams({
                        title : 'ERROR',
                        message: 'OOOPS! Some error occurred Please Contact System Admin. '+response.getReturnValue(),
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    // if getting any error while delete the records , then display a alert msg/
                    //   alert('The following error has occurred. while Delete record-->' + response.getReturnValue());
                } else {
                    console.log('check it--> delete successful');
                    toastEvent.setParams({
                        title : 'SUCCESS',
                        message: 'Develop Opportunities have been created for all the selected sampling requests.',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    doRequiredValidation : function (selectedSamplingWrapperList) {
        console.log("selectedSamplingWrapperList: "+selectedSamplingWrapperList);
        var returnString ='VALID';
        for (var i = 0; i < selectedSamplingWrapperList.length; i++) {
            if ( !selectedSamplingWrapperList[i].OppName || selectedSamplingWrapperList[i].OppName == undefined || selectedSamplingWrapperList[i].OppName == null)
            {
                returnString = 'Row No: ' + (i+1)+ '. Opportunity Name is Required. Please fill and Proceed.';
                break;
            }
            else if (selectedSamplingWrapperList[i].OppName =="" || selectedSamplingWrapperList[i].OppName.trim() =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Opportunity Name is Required. It cannot be blank or have empty spaces. Please fill a valid name and Proceed.';
                break;
            }
            else if ( !selectedSamplingWrapperList[i].accountId || selectedSamplingWrapperList[i].accountId == undefined || selectedSamplingWrapperList[i].accountId == null || selectedSamplingWrapperList[i].accountId=="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Account is Required. Please Select an Account and Proceed.';
                break;
            }
            else if ( !selectedSamplingWrapperList[i].estimatedVolume || selectedSamplingWrapperList[i].estimatedVolume == undefined || selectedSamplingWrapperList[i].estimatedVolume == null || selectedSamplingWrapperList[i].estimatedVolume =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Estimated Volume is Required. Please fill and Proceed.';
                break;
            }
            else if ( !selectedSamplingWrapperList[i].taregtSellingPrice || selectedSamplingWrapperList[i].taregtSellingPrice == undefined || selectedSamplingWrapperList[i].taregtSellingPrice == null || selectedSamplingWrapperList[i].taregtSellingPrice =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Target Selling Price is Required. Please fill and Proceed.';
                break;
            }
            else if ( !selectedSamplingWrapperList[i].unitOfMeasure || selectedSamplingWrapperList[i].unitOfMeasure == undefined || selectedSamplingWrapperList[i].unitOfMeasure == null || selectedSamplingWrapperList[i].unitOfMeasure =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. UOM(Sample) is Required. Please fill and Proceed.';
                break;
            }
            else if ( !selectedSamplingWrapperList[i].quantityOfSample || selectedSamplingWrapperList[i].quantityOfSample == undefined || selectedSamplingWrapperList[i].quantityOfSample == null || selectedSamplingWrapperList[i].quantityOfSample =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Quantity of Sample is Required. Please fill and Proceed.';
                break;
            }
            else if ( !selectedSamplingWrapperList[i].firstSampleDueDate || selectedSamplingWrapperList[i].firstSampleDueDate == undefined || selectedSamplingWrapperList[i].firstSampleDueDate == null || selectedSamplingWrapperList[i].firstSampleDueDate =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. First Sample Due Date is Required. Please fill and Proceed.';
                break;
            }
            else if ( !selectedSamplingWrapperList[i].keyDriverToWinProject || selectedSamplingWrapperList[i].keyDriverToWinProject == undefined || selectedSamplingWrapperList[i].keyDriverToWinProject == null || selectedSamplingWrapperList[i].keyDriverToWinProject =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Key Driver to win Project is Required. Please fill and Proceed.';
                break;
            }
             else if ( !selectedSamplingWrapperList[i].targetMargin || selectedSamplingWrapperList[i].targetMargin == undefined || selectedSamplingWrapperList[i].targetMargin == null || selectedSamplingWrapperList[i].targetMargin =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Target Margin is Required. Please fill and Proceed.';
                break;
            }
            else if ( !selectedSamplingWrapperList[i].PDandIUserId || selectedSamplingWrapperList[i].PDandIUserId == undefined || selectedSamplingWrapperList[i].PDandIUserId == null || selectedSamplingWrapperList[i].PDandIUserId=="")
            {
                returnString = 'Row No: ' + (i+1)+ '. PD&I Member is Required. Please Select an User and Proceed.';
                break;
            }
            else{
             console.log('all data valid for this item');      
            }
        }
        return returnString;
    },
})