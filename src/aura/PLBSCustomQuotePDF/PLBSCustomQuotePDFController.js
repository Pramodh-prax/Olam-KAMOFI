({
 
    doInit : function(component,event,helper)
    {
       var quoId = component.get("v.recordId");
        console.log('quoteId'+quoId)
       var action = component.get("c.isContactAvailable");
        action.setParams({
            "quoteId":quoId
        })
        
        action.setCallback(this,(res)=>{
            var state = res.getState();
            console.log( 'State ',state);
            var check = res.getReturnValue();
            console.log('check',check);
            if(state == 'SUCCESS')
            {
            	if(!check)
            	{
            		helper.handleShowNotice(component, event, 'Please add Primary Contact On Parent Opportunity before genrating PDF', 'Something went wrong!', 'error');
            		$A.get("e.force:closeQuickAction").fire();
        		}
            }else
            {
                helper.handleShowNotice(component, event, 'Error While fetchning Primary Contact Details', 'Something went wrong!', 'error');
        		$A.get("e.force:closeQuickAction").fire();
    		}
        });
       $A.enqueueAction(action);        
    },
	cancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    savePDF : function(component,event,helper){
        helper.savePDF(component, event, false);
    },
    
    sendEmail : function(component,event,helper){
        helper.savePDF(component, event, true);
    }
})