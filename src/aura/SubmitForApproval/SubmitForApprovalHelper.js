({
	initHelper : function(component, event) {
        component.set ('v.isLoading', true);
        var action = component.get("c.getQuoteLineApprovals");
        
        action.setParams({
                QuoteId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                component.set ('v.isLoading', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.QuoteLineItemsListRequiredApproval", response.getReturnValue());                
                }
                else if(state === "ERROR"){
                    console.log('A problem occurred: ' + JSON.stringify(response.error));
                }
            });
            $A.enqueueAction(action);
	},
    
    
    
    createQuoteLineApprovalRecord : function(component, event){
        component.set ('v.isLoading', true);
        
        var action = component.get("c.createQuoteLineApprovals");
        
        var quoteLineApprovalWrapRecords = component.get("v.QuoteLineItemsListRequiredApproval");
        var quoteLineApprovals = [];
        
        for(var i=0; i<quoteLineApprovalWrapRecords.length; i++){
            var quoteLineApproval = quoteLineApprovalWrapRecords[i];
            if(quoteLineApproval.approvalMatrix.Approver_1__c){
                var quoteLineApprovalNew = {
                    Account__c : quoteLineApproval.quoteLine.Quote.AccountId,
                    Approval_Status__c : 'Not Started',
                    Brand__c : quoteLineApproval.quoteLine.Product2.Brand__c,
                    Product_Category__c : quoteLineApproval.quoteLine.Product2.Product_Category__c,
                    Product_Sub_Category__c : quoteLineApproval.quoteLine.Product2.Product_Sub_Category__c,
                    Product_Sub_Category_2__c : quoteLineApproval.quoteLine.Product2.Product_Sub_Category_2__c,
                    Quote_Line_Item__c : quoteLineApproval.quoteLine.Id,
                    Quote__c : quoteLineApproval.quoteLine.QuoteId,
                    Approver_1__c : quoteLineApproval.approvalMatrix.Approver_1__c,
                    Approver_2__c : quoteLineApproval.approvalMatrix.Approver_2__c,
                    Approver_3__c : quoteLineApproval.approvalMatrix.Approver_3__c
                }
                
                quoteLineApprovals.push(quoteLineApprovalNew);
            }
        }
        
        action.setParams({
            quoteLineApprovals : quoteLineApprovals
        });
        
        action.setCallback(this, function(response) {
            component.set ('v.isLoading', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() == 'SUCCESS') {
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                    this.showToast(component,'success','SUCCESS','Quote Line Items are successfuly submitted for approval.');
                    //To close refresh view
                    //var AddQuoteLineItemToParentCompEvent = component.getEvent("AddQuoteLineItemToParentCompEvent");
                   //AddQuoteLineItemToParentCompEvent.setParams({"action" : 'CLOSE_AND_REFRESH_VIEW'});
                   //AddQuoteLineItemToParentCompEvent.fire();
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
    }
})