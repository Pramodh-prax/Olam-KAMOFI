({
    handleOnSaveAndLock : function(component, event, helper) {
        helper.handleOnSave (component, true);
    },
    handleOnSaveAsDraft : function(component, event, helper) {
        helper.handleOnSave (component, false);
    },
    closeModel : function(component, event, helper) {
        component.destroy ();
    },
    doInit : function(component, event, helper) {
        let labels = {
            noData: $A.get ('$Label.c.KAM_No_Data_available_in_table'),
            interactionType : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Interaction_Type'),
            frequency : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Frequency'),
            planned : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Planned'),
            members : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Members'),
            modalHeader : $A.get ('$Label.c.KAM_Engagement_Plan_Table_Header'),
            modalBtnCancel : $A.get ('$Label.c.KAM_Modal_Btn_Cancel'),
            modalBtnSaveAsDraft : $A.get ('$Label.c.KAM_Modal_Btn_Save_As_Draft'),
            modalBtnSaveAndLock : $A.get ('$Label.c.KAM_Modal_Btn_Save_And_Lock'),
        }
        component.set ('v.labels', labels);
        helper.doInit (component, event);
    },
    handleFilterChange : function(component, event, helper) {
        const engagementPlansWrapper = component.get ('v.engagementPlansWrapper');
        engagementPlansWrapper[event.getParam ('index')].attendies = event.getParam ('selectedItems');
        component.set ('v.engagementPlansWrapper', engagementPlansWrapper);
    },
    handleOnFrequencySelected : function(component, event, helper) {
        const index = event.getSource().get('v.name');
        const value = event.getSource().get('v.value');
        const frequencyMapping = component.get ('v.frequencyMapping');

        if (frequencyMapping && frequencyMapping.hasOwnProperty (value)) {
            let engagementPlansWrapper = component.get ('v.engagementPlansWrapper');
            const frqVal = frequencyMapping[value];
            engagementPlansWrapper[index].isPlanedEditable = frqVal.Value_Type__c === 'User Input';
            engagementPlansWrapper[index].engagementPlan.Planned__c = frqVal.Value__c;
            component.set ('v.engagementPlansWrapper', engagementPlansWrapper);
        } 
    },
})