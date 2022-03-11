({
    doInit : function (component,event,helper) {
        let selectedRecord = component.get ('v.selectedRecord');
        if (selectedRecord 
            && typeof selectedRecord !== 'undefined' 
            && selectedRecord !== null 
            && Object.keys (selectedRecord).length > 0 ) {
            component.set ('v.privateSelectedRecord', {
                Name : selectedRecord.Name,
                Id : selectedRecord.Id
            });
            helper.handleOnRecordSelected (component, selectedRecord);
        }
    },
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var compEvent = component.getEvent("blur");
        //compEvent.fire();
        let selectedRecord = component.get ('v.selectedRecord');
        if (selectedRecord 
            && typeof selectedRecord !== 'undefined' 
            && selectedRecord !== null 
            && Object.keys (selectedRecord).length > 0 ) {
            component.set ('v.privateSelectedRecord', {
                Name : selectedRecord.Name,
                Id : selectedRecord.Id
            });
            helper.handleOnRecordSelected (component, selectedRecord);
        }
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.privateSelectedRecord", {} );  
        
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        helper.searchHelper(component,event, '');
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        component.set("v.privateSelectedRecord" , {
            Name : selectedAccountGetFromEvent.Name,
            Id : selectedAccountGetFromEvent.Id
        }); 
        
        helper.handleOnRecordSelected (component, selectedAccountGetFromEvent);
    },
})