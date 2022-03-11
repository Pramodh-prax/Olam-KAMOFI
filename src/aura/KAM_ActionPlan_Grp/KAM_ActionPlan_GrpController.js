({
    doInit : function(component, event, helper) {
        let labels = {
            noData: $A.get ('$Label.c.KAM_No_Data_available_in_table'),
            salesActionPlan : $A.get ('$Label.c.KAM_Action_Plan_Section_Sales_Action'),
            developActionPlan : $A.get ('$Label.c.KAM_Action_Plan_Section_Develop_Action'),
            serviceAndPresentActionPlan : $A.get ('$Label.c.KAM_Action_Plan_Section_Service_and_Present_Action'),
            PresentActionPlan : $A.get ('$Label.c.KAM_Action_Plan_Section_Present_Action'),
            serviceActionPlan : $A.get ('$Label.c.KAM_Action_Plan_Section_Service_Action')

        }
        component.set ('v.labels', labels);
        component.set ('v.selectedUnitOfMeasure', helper.DEFAULT_UNIT_OF_MEASURE);
		component.set ('v.options', helper.UNIT_OF_MEASURE_OPTIONS);
        let sectionComments = {
            salesActionPlan : {
                key : 'salesActionPlan',
                comments : ''
            },
            developmentActionPlan : {
                key : 'developmentActionPlan',
                comments : ''
            },
            serviceAndPresentActionPlan : {
                key : 'serviceAndPresentActionPlan',
                comments : ''
            },
            serviceActionPlan : {
                key : 'serviceActionPlan',
                comments : ''
            },
        };

        component.set ('v.sectionComments', sectionComments);
        helper.doInit (component, event);
    },
    handleOnUnitOfMeasureChange : function(component, event, helper) {
		helper.handleOnUnitOfMeasureChange (component, event);
	},
    handleCommentSaveEvent : function (component, event, helper) {
        helper.saveComments (component, event.getParam("identifier"), event.getParam("oldComment"), event.getParam("newComment"));
    }
})