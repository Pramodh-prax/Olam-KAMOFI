({
     doInit: function(component, event, helper) {
        helper.searchProducts(component, event,'');
    },
	/* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllProducts");
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

        var listOfAllProducts = component.get("v.listOfAllProducts");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllProducts.length; i++) {
            listOfAllProducts[i].isChecked = selectedHeaderCheck;
            //updatedAllRecords.push(listOfAllProducts[i]);
        }
        
        component.set("v.listOfAllProducts", listOfAllProducts);
        //
        var selectedRecords = component.get("v.listOfAllSelectedProducts");
        if(selectedRecords && selectedRecords.length>0){
            let idArray= selectedRecords.map(ele=> ele.objPBE.Id);
            listOfAllProducts.forEach(ele=>{
                if(selectedHeaderCheck && ele.isChecked && !(idArray.includes(ele.objPBE.Id))){
                	selectedRecords.push(ele);
               	}
                if(!(selectedHeaderCheck) && idArray.includes(ele.objPBE.Id)){
                	let index = selectedRecords.findIndex(ele1 => ele1.objPBE.Id === ele.objPBE.Id);
                	if(index >-1){
                    	selectedRecords.splice(index, 1);
                	}
               	}
            })
        }
        component.set("v.listOfAllSelectedProducts",selectedRecords);
    	component.set("v.selectedCount",selectedRecords.length);
        
    },
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        
        var selectedProduct = event.getSource().get("v.name");
        var listOfAllSelectedProducts = component.get("v.listOfAllSelectedProducts");
        
        if (selectedRec == true) {
            getSelectedNumber++;
            
            listOfAllSelectedProducts.push(selectedProduct);
        } else {
            getSelectedNumber--;
            //const index = listOfAllSelectedProducts.indexOf(selectedProduct);
            /*const index = listOfAllSelectedProducts.map(function(e) { return e.selectedProduct; }).indexOf(selectedProduct.objPBE.Id);
            if (index > -1) {
                listOfAllSelectedProducts.splice(index, 1);
            }*/
            
            var newArray = listOfAllSelectedProducts.filter((item) => item.objPBE.Id !== selectedProduct.objPBE.Id);
            console.log(newArray);
            component.set("v.listOfAllSelectedProducts", newArray);
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
        
        component.set("v.showSelected", getSelectedNumber>0);
    },
    
	OpenEventPopup : function(component, event, helper) {		
        var modalFade1 = component.find('eventPopId');    
        component.find("eventPopId").submitDR(modalFade1);
	},
    cancel : function(component,event,helper){
        var AddQuoteLineItemToParentCompEvent = component.getEvent("AddQuoteLineItemToParentCompEvent");
        AddQuoteLineItemToParentCompEvent.setParams({"action" : 'CANCEL' });
        
        var listOfAllSelectedProducts = component.get("v.listOfAllSelectedProducts");
        var listOfContentDocIds = [];
        
        for (var i = 0; i < listOfAllSelectedProducts.length; i++) {
            if (listOfAllSelectedProducts[i].listOfContentDocIds.length > 0)
            {
                for (var j = 0; j < listOfAllSelectedProducts[i].listOfContentDocIds.length; j++) {
                    listOfContentDocIds.push(listOfAllSelectedProducts[i].listOfContentDocIds[j]);
                }
            }
        }
        
        AddQuoteLineItemToParentCompEvent.setParams({"listOfContentDocIds" : listOfContentDocIds });
        
        AddQuoteLineItemToParentCompEvent.fire(); 
    },
    handleOnApplyMultiFilterEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var filterQuery = event.getParam("filterQuery");
        console.log('filterQuery in Parent comp: '+filterQuery);
        helper.doInitHelper(component, event,filterQuery,'');
    },
    
    showAddProduct : function (component, event, helper) {
        component.set('v.screenName', 'ADD_PRODUCTS');
        console.log("v.screenName"+component.get("v.screenName"));
    },
    
    showAddProductConfig : function (component, event, helper) {
        
        var requiredValidationResponse = helper.validateBeforeProdConfig(component, event);

        console.log("requiredValidationResponse: "+requiredValidationResponse);
        if(requiredValidationResponse == 'VALID'){
            /*component.set('v.screenName', 'ADD_PRODUCT_CONFIG');
            console.log("v.screenName"+component.get("v.screenName"));*/
            
            var shouldFetchProductConfig = helper.checkProductConfigToFetch(component, event);
            if(shouldFetchProductConfig == true){
                helper.fetchProductsConfig(component, event);
            }
            else{
                component.set('v.screenName', 'ADD_PRODUCT_CONFIG');
            }
            //helper.fetchProductsConfig(component, event);
        }
        else{
            helper.showToast(component,'error','ERROR',requiredValidationResponse);
        }
    },
    
    onClickClearFilter : function (component, event, helper) {
        component.find("searchKey").set("v.value",'');
        var showFilters = component.get("v.showFilters");
        if(showFilters == true){
            component.find('productFamily').set('v.value','');
            component.find("productCategory").set("v.value",'');
            component.find("productSubCategory").set("v.value",'');
            component.find("productSubCategory2").set("v.value",'');
            component.find("productBrand").set("v.value",'');
            
            //this.hideFilters(component, event, helper);
            component.set('v.showFilters', false);
        }
        //this.onClickSearch(component, event, helper);
        
        helper.searchProducts(component, event, '', '', '', '', '', '');
    },
    
    onClickSearch : function (component, event, helper) {
        var family = ''; if(component.find("productFamily") != undefined){family = component.find("productFamily").get('v.value');}
        var category = ''; if(component.find("productCategory") != undefined){category = component.find("productCategory").get('v.value');}
        var subCategory = ''; if(component.find("productSubCategory") != undefined){subCategory = component.find("productSubCategory").get('v.value');}
        var subCategory2 = ''; if(component.find("productSubCategory2") != undefined){subCategory2 = component.find("productSubCategory2").get('v.value');}
        var brand = ''; if(component.find("productBrand") != undefined){brand = component.find("productBrand").get('v.value');}
        var searchKey = component.find("searchKey").get('v.value');
        
        helper.searchProducts(component, event, searchKey, category, subCategory, subCategory2, brand, family);
    },
    showFilters : function (component, event, helper) {
    	component.set('v.showFilters', true);
    },
    hideFilters : function (component, event, helper) {
    	component.set('v.showFilters', false);
    },
    onClickShowSelected : function (component, event, helper) {
        var selectedRecords = component.get("v.listOfAllSelectedProducts");
        component.set('v.PaginationList', selectedRecords);
    	component.set('v.showSelected', false);
    },
    onClickBackToResults : function (component, event, helper) {
        var listOfAllProducts = component.get("v.listOfAllProducts");
        //component.set('v.PaginationList', listOfAllProducts);
        helper.paginationSet(component,listOfAllProducts);
    	component.set('v.showSelected', true);
    },
    addPriceBook : function (component, event, helper) {
        helper.addPriceBookHelper(component, event);
        //helper.doInitHelper(component, event,'','');
        helper.searchProducts(component, event, '', '', '', '', '', '');
    },
    showUpdateDetailsBack : function (component, event, helper) {
        component.set('v.screenName', 'UPDATE_DETAILS');
        console.log("v.screenName"+component.get("v.screenName"));
    },
    /*showUpdateDetails : function (component, event, helper) {
        var allRecords = component.get("v.listOfAllProducts");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        if(selectedRecords.length > 0){
            
            //component.set('v.screenName', 'UPDATE_DETAILS');
            //console.log("v.screenName: "+component.get("v.screenName"));
            //component.set("v.listOfAllSelectedProducts", selectedRecords);
            
            component.set("v.listOfAllSelectedProducts", selectedRecords);
            
            helper.checkIfProductConfigRequired(component, event);
            var showAddProductConfig = helper.checkToShowAddProductConfigOrSave(component, event);
            if(showAddProductConfig == true){
                component.set('v.isProductConfigRequired', true);
            }
            component.set('v.screenName', 'UPDATE_DETAILS');
            console.log("v.screenName: "+component.get("v.screenName"));
            
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
    },*/
    /* Commented and changed as part of product config SAP API changes
     * showUpdateDetails : function (component, event, helper) {
        var allRecords = component.get("v.listOfAllProducts");
        var selectedRecords = component.get("v.listOfAllSelectedProducts");
        if(selectedRecords.length > 0){
            
            //component.set('v.screenName', 'UPDATE_DETAILS');
            //console.log("v.screenName: "+component.get("v.screenName"));
            //component.set("v.listOfAllSelectedProducts", selectedRecords);
            
            component.set("v.listOfAllSelectedProducts", selectedRecords);
            
            //helper.checkIfProductConfigRequired(component, event);
            
            component.set ('v.isLoading', true);
            var listOfAllSelectedProducts = component.get("v.listOfAllSelectedProducts");
            var quoteId = component.get("v.recordId");
            helper.invokeApex (component, 'c.fetchProductConfigForSelectedProducts', {
                "QuoteId": quoteId,
                "lstLineItemWrapper": listOfAllSelectedProducts,
                "shouldFecthProductConfig": false
            }).then (
                $A.getCallback (result => {
                    if(result){
                    	component.set('v.listOfAllSelectedProducts', result);
                    }
                })).then($A.getCallback(()=>{
                    component.set('v.isProductConfigRequired', helper.checkToShowAddProductConfigOrSave(component, event));
                    component.set('v.screenName', 'UPDATE_DETAILS');
                    component.set ('v.isLoading', false);
                })).catch (
                    $A.getCallback ((error) => {
                    //handle error
                    console.log ('Error ' + JSON.stringify (error));
                    helper.showToast (component, 'error', 'Error', helper.normalizeError (error));
                    component.set ('v.isLoading', false);
                }))
            
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
    },*/
        
    showUpdateDetails : function (component, event, helper) {
        var allRecords = component.get("v.listOfAllProducts");
        var selectedRecords = component.get("v.listOfAllSelectedProducts");
        if(selectedRecords.length > 0){
            component.set("v.listOfAllSelectedProducts", selectedRecords);
            
            component.set ('v.isLoading', true);
            
            component.set('v.isProductConfigRequired', helper.checkToShowAddProductConfigOrSave(component, event));
            component.set('v.screenName', 'UPDATE_DETAILS');
            component.set ('v.isLoading', false);
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
        
    saveQuoteLineItems : function (component, event, helper) {
        
        var screenName = component.get("v.screenName");
        var requiredValidationResponse = 'VALID';
        
        if(screenName == 'UPDATE_DETAILS'){
            requiredValidationResponse = helper.validateBeforeProdConfig(component, event);
        }
        else if(screenName == 'ADD_PRODUCT_CONFIG'){
            //Commented as Input range/Customer Range made non required
            //requiredValidationResponse = helper.validateBeforeSave(component, event);
        }
        console.log("requiredValidationResponse: "+requiredValidationResponse);
        if(requiredValidationResponse == 'VALID'){
            helper.saveQuoteLineItemsHelper(component, event);
        }
        else{
            helper.showToast(component,'error','ERROR',requiredValidationResponse);
        }
    },
        
    callKeyUp : function(component, event, helper) {
        var searchKey = component.find("searchKey").get('v.value');
        if(searchKey && searchKey.length>3){
            console.log('searchKey: '+searchKey);
        }
        if ( event.keyCode == 13 || ((searchKey && searchKey.length>3) || searchKey.length == 0)){
            //this.onClickSearch(component, event, helper);
            var family = ''; if(component.find("productFamily") != undefined){family = component.find("productFamily").get('v.value');}
            var category = ''; if(component.find("productCategory") != undefined){category = component.find("productCategory").get('v.value');}
            var subCategory = ''; if(component.find("productSubCategory") != undefined){subCategory = component.find("productSubCategory").get('v.value');}
            var subCategory2 = ''; if(component.find("productSubCategory2") != undefined){subCategory2 = component.find("productSubCategory2").get('v.value');}
            var brand = ''; if(component.find("productBrand") != undefined){brand = component.find("productBrand").get('v.value');}
            //var searchKey = component.find("searchKey").get('v.value');
            
            helper.searchProducts(component, event, searchKey, category, subCategory, subCategory2, brand, family);
        }   
    },
    sortByName: function(component, event, helper) {
        helper.sortBy(component, "Name");
        helper.paginationSet(component,listOfAllProducts);
    }
})