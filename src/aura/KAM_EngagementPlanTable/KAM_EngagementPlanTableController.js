({
    doInit : function(component, event, helper) {
        let labels = {
            noData: $A.get ('$Label.c.KAM_No_Data_available_in_table'),
            waitingForApprovalMsg :$A.get ('$Label.c.KAM_Engagement_Plan_Approval_Waiting_Message'),
            draftEngMsg : $A.get ('$Label.c.KAM_Engagement_Plan_Draft_Message'),
            interactionType : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Interaction_Type'),
            frequency : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Frequency'),
            lastEngagement : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Last_Engagement'),
            actualVsPlanned : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Actuals_vs_Planned'),
            members : $A.get ('$Label.c.KAM_Eng_Plan_Table_Header_Members'),
            btnAddOrEditEng : $A.get ('$Label.c.KAM_Eng_Plan_Btn_Add_Or_Edit_Engagaement'),
            btnRquestForEdit : $A.get ('$Label.c.KAM_Eng_Plan_Btn_Request_For_Edit_Engagaement'),
            
        }
        component.set ('v.labels', labels);
        helper.updateMemberDetails (component);
    },
    itemsChange : function(component, event, helper) {
        helper.updateMemberDetails (component);
    }
})