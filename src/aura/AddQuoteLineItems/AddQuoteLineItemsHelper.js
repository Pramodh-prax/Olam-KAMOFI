({
	searchProducts : function (component, event, searchKey, category, subCategory, subCategory2, brand, family) {
        component.set ('v.isLoading', true);
        //Commented for now and removed as default screen name
        //will be set afterwards
        //component.set('v.screenName', 'ADD_PRODUCTS');
        
        //Promise to fetch wrapper
        
        var quoteId = component.get("v.recordId");
        
        let fetchLineItemWrapperPromise = this.invokeApex (component, 'c.fetchLineItemWrapper', {
            "QuoteId": quoteId,
            "searchKey": searchKey,
            "category": category,
            "subCategory": subCategory,
            "subCategory2": subCategory2,
            "brand": brand,
            "family": family
        });
        let fetchPriceBooksPromise = this.invokeApex (component, 'c.getPriceBooks', {
            "QuoteId": quoteId
        });
        let fetchIsApprovalRequiredPromise = this.invokeApex (component, 'c.getIsApprovalRequiredValues', {
            "QuoteId": quoteId
        });
        let getUnitOfMeasurePromise = this.invokeApex (component, 'c.getselectOptions', {
            "objObject": component.get("v.QuoteLineItemForPicklistValues"),
            "fld": 'Unit_Of_Measure__c'
        });
        Promise.all ([
                fetchLineItemWrapperPromise,
                fetchPriceBooksPromise,
                fetchIsApprovalRequiredPromise,
                getUnitOfMeasurePromise
		]).then (
            $A.getCallback (results => {
                if(results[1].length > 0){
                component.set("v.PriceBooks",results[1]);
                component.set('v.screenName', 'ADD_PRICEBOOK');
                component.set ('v.isLoading', false);
            }
                            else{
                            //component.set("v.OpportunityLineItemList", results[0]);
                            //console.log ('results[0] ' +results[0]);
                            component.set ('v.isDataLoaded', true);
            component.set ('v.isLoading', false);
        
        component.set('v.screenName', 'ADD_PRODUCTS');
        
        var oRes = results[0];
        if(oRes.length > 0){
            var selectedRecords = component.get("v.listOfAllSelectedProducts");
            if(selectedRecords && selectedRecords.length>0){
                component.set('v.showSelected', true);
                let idArray= selectedRecords.map(ele=> ele.objPBE.Id);
                oRes.forEach(ele=>{
                    ele.isChecked = idArray.includes(ele.objPBE.Id);
                })
            }
            else{
                component.set('v.showSelected', false);
            }
            component.set("v.bNoRecordsFound" , false);
            component.set('v.listOfAllProducts', oRes); 
            this.paginationSet(component,oRes);
        }
        else{
            // if there is no records then display message
            component.set("v.bNoRecordsFound" , true);
        }
        
    }
    if(results[2].length > 0){
    this.updatePickListVals (component, 'isPLMApprovalRequiredOptions', results[2]);
}
 else{
 
 }
 if(results[3].length > 0){
    this.updatePickListVals (component, 'unitofmeasurePicklistOpts', results[3]);
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
	updatePickListVals : function (component, picklistOptsAttributeName, allValues) {
     	
 		var opts = [];
        /*if (allValues != undefined && allValues.length > 0) {
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
        }*/
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
    addPriceBookHelper : function(component,event){
        var selectedPriceBookId = component.find("pricebooks").get("v.value");
        var action = component.get("c.updateQuotePriceBook");
        action.setParams({
            "QuoteId": component.get("v.recordId"),
            "priceBookId": selectedPriceBookId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()==true){
                    
                }
                else{
                    //Handle error
                }
            }
            else{
                //Handle error
            }
        }); 
        $A.enqueueAction(action);
    },
        paginationSet : function(component,records){
            var pageSize = component.get("v.pageSize");
            var totalLength = records.length ;
            component.set("v.totalRecordsCount", totalLength);
            component.set("v.startPage",0);
            component.set("v.endPage",pageSize-1);
            var PaginationLst = [];
            for(var i=0; i < pageSize; i++){
                if(component.get("v.listOfAllProducts").length > i){
                    PaginationLst.push(records[i]);    
                } 
            }
            component.set('v.PaginationList', PaginationLst);
            //use Math.ceil() to Round a number upward to its nearest integer
            component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize)); 
            component.set("v.currentPage", 1);
        },
        fetchProductsConfig : function(component,event){
        
        component.set ('v.isLoading', true);
        var listOfAllSelectedProducts = component.get("v.listOfAllSelectedProducts");
        var quoteId = component.get("v.recordId");
        var action = component.get("c.fetchProductConfigForSelectedProducts");
        action.setParams({
            "QuoteId": quoteId,
            "lstLineItemWrapper": listOfAllSelectedProducts,
            "shouldFecthProductConfig": true
        });
        action.setCallback(this, function(response) {
            component.set ('v.isLoading', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log ('response.getReturnValue(): ' +response.getReturnValue());
                if(response.getReturnValue().length > 0){
                    component.set('v.listOfAllSelectedProducts', response.getReturnValue());
                    component.set('v.screenName', 'ADD_PRODUCT_CONFIG');
                    console.log("v.screenName: "+component.get("v.screenName"));
                }
                else{
                    //Handle error
                }
            }
            else{
                //Handle error
            }
        }); 
        $A.enqueueAction(action);
    },
    
        validateBeforeProdConfig : function (component,event) {
        var returnString ='VALID';
        var listOfAllSelectedProducts = component.get("v.listOfAllSelectedProducts");
        for (var i = 0; i < listOfAllSelectedProducts.length; i++) {
            if ( !listOfAllSelectedProducts[i].unitPrice || listOfAllSelectedProducts[i].unitPrice == undefined || listOfAllSelectedProducts[i].unitPrice == null || listOfAllSelectedProducts[i].unitPrice =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Unit Price is Required. Please fill and Proceed.';
                break;
            }
            else if ( !listOfAllSelectedProducts[i].volume || listOfAllSelectedProducts[i].volume == undefined || listOfAllSelectedProducts[i].volume == null || listOfAllSelectedProducts[i].volume =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Volume is Required. Please fill and Proceed.';
                break;
            }
            else if ( !listOfAllSelectedProducts[i].unitOfMeasure || listOfAllSelectedProducts[i].unitOfMeasure == undefined || listOfAllSelectedProducts[i].unitOfMeasure == null || listOfAllSelectedProducts[i].unitOfMeasure =="")
            {
                returnString = 'Row No: ' + (i+1)+ '. Unit Of Measure is Required. Please fill and Proceed.';
                break;
            }
            else if (listOfAllSelectedProducts[i].isPLMApprovalRequired =="No" && listOfAllSelectedProducts[i].isFileUploaded == false)
            {
                returnString = 'Row No: ' + (i+1)+ '. File uploading is Required. Please upload the file and Proceed.';
                break;
            }
            else{
             console.log('all data valid for this item');      
            }
        }
        return returnString;
    },
        validateBeforeSave : function (component,event) {
        var returnString ='VALID';
        var listOfAllSelectedProducts = component.get("v.listOfAllSelectedProducts");
        for (var i = 0; i < listOfAllSelectedProducts.length; i++) {
            if (listOfAllSelectedProducts[i].listOfProductConfigWrapperFinal.length > 0)
            {
                for (var j = 0; j < listOfAllSelectedProducts[i].listOfProductConfigWrapperFinal.length; j++) {
                    if ( !listOfAllSelectedProducts[i].listOfProductConfigWrapperFinal[j].new_range || listOfAllSelectedProducts[i].listOfProductConfigWrapperFinal[j].new_range == undefined || listOfAllSelectedProducts[i].listOfProductConfigWrapperFinal[j].new_range == null || listOfAllSelectedProducts[i].listOfProductConfigWrapperFinal[j].new_range =="")
                    {
                        returnString = 'Row No: ' + (i+1)+ '. Customer Range in Product Config is blank. Please fill and Proceed.';
                        break;
                    }
                }
            }
            else{
             console.log('all data valid for this item');      
            }
        }
        return returnString;
    },
        checkProductConfigToFetch : function (component,event) {
        var shouldFetchProductConfig = false;
        var listOfAllSelectedProducts = component.get('v.listOfAllSelectedProducts');
        for (var i = 0; i < listOfAllSelectedProducts.length; i++) {
            if ( listOfAllSelectedProducts[i].isProdConfigFetched == false)
            {
                shouldFetchProductConfig = true;
                break;
            }
        }
        return shouldFetchProductConfig;
    },
        saveQuoteLineItemsHelper: function(component, event) { 
        //call apex class method
        component.set ('v.isLoading', true);
        var listOfAllSelectedProducts = component.get("v.listOfAllSelectedProducts");
        var quoteId = component.get("v.recordId");
            
        var action = component.get('c.createQuoteLineItem');
        
        action.setParams({
            "QuoteId": quoteId,
            "lstLineItemWrapper": listOfAllSelectedProducts
        });
        action.setCallback(this, function(response) {
            component.set ('v.isLoading', false);
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() == 'SUCCESS') {
                    // success toast and close component and quickrefresh
                    this.showToast(component,'success','SUCCESS','All the selcted products are successfully added to Quote.');
                    
                    //To close refresh view
                    var AddQuoteLineItemToParentCompEvent = component.getEvent("AddQuoteLineItemToParentCompEvent");
                    AddQuoteLineItemToParentCompEvent.setParams({"action" : 'CLOSE_AND_REFRESH_VIEW'});
                    AddQuoteLineItemToParentCompEvent.fire();
                } 
                else {
                    // Error toast with error message
                    this.showToast(component,'error','ERROR',response.getReturnValue());
                }
            }
            else{
                //Handle error
            }
        });
        $A.enqueueAction(action);
    },
        checkToShowAddProductConfigOrSave : function (component,event) {
        var showAddProductConfig = false;
        var listOfAllSelectedProducts = component.get('v.listOfAllSelectedProducts');
        for (var i = 0; i < listOfAllSelectedProducts.length; i++) {
            if ( listOfAllSelectedProducts[i].isProductConfigRequired == true)
            {
                showAddProductConfig = true;
                break;
            }
        }
        return showAddProductConfig;
    },
    sortBy: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            listOfAllProducts = component.get("v.listOfAllProducts");
        sortAsc = sortField != field || !sortAsc;
        listOfAllProducts.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.listOfAllProducts", listOfAllProducts);
    }
     
})