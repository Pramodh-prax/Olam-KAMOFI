/**
 * @description       : JS helper for the RemoveOpportunityProductControler component.
 * @author            : Bharatesh Shetty
 * @group             : 
 * @last modified on  : 09-02-2021
 * @last modified by  : Bharatesh Shetty
**/
({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){ 
        debugger;
        
        var action = component.get("c.fetchOpportunityLineItemWrapper");
        console.log('recordId: '+ component.get("v.recordId"));
        component.set('v.screenName', 'REMOVE_PRODUCTS');
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
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , false);
                    component.set("v.showSection",true);
                } 
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);  
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
    deleteSelectedHelper: function(component, event, selectedRecords) { 
        //call apex class method
        component.set("v.isLoading",true);
        var action = component.get('c.deleteOpportunityLineItems');
        // pass the all selected record's Id's to apex method 
        console.log("selectedRecords delete: "+selectedRecords);
        action.setParams({
            //"listOfSelectedOppLineItemWrapper": selectedRecords
            listOfSelectedOppLineItemWrapper : selectedRecords
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isLoading",false);
                console.log(state);
                $A.get('e.force:refreshView').fire();
                console.log(response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                if (response.getReturnValue() != 'SUCCESS') {
                    console.log(response.getReturnValue());
                    toastEvent.setParams({
                        title : 'ERROR',
                        message: 'OOOPS! Some error occurred Please Contact System Admin.',
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
                        message: 'All the selected products were successfuly removed from the opportunity.',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                // call the onLoad function for refresh the List view    
                    //this.doInitHelper(component, event);
            }
        });
        $A.enqueueAction(action);
    }
})