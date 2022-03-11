({
    doInit : function(component, event, helper) {
        let labels = {
            noData: $A.get ('$Label.c.KAM_No_Data_available_in_table'),
            oppty : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Oppty_Name'),
            account : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Account_Name'),
            createdDate : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Created_Date'),
            estimatedVolume : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Estimated_Volume'),
            sampleSent : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Sample_Sent'),
            sampleAccepted : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Sample_Accepted'),
            stage : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Stage'),
            lastModifiedDate : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Last_ModifiedDate'),
            product : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Product'),
            sampleSentDate : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Sample_Sent_Date'),
            samplingStatus : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Sampling_Status'),
            category : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Category'),
            owner : $A.get ('$Label.c.KAM_Action_Plan_Table_Header_Owner')
        }
        component.set ('v.labels', labels);
        
        if (component.get ('v.displayType') === 'individual') {
        
            helper.doInit (component, event);
        } else if (component.get ('v.displayType') === 'group') {
            
            helper.getGroupOpportunities (component, event);
        }
    },
    scriptLoaded : function(component, event, helper) {
        
    },
    handleRowToggle : function (component, event, helper) {
        $(event.currentTarget).parent().toggleClass ('detail_toggle');
        $(event.currentTarget).parent().parent().parent().parent().next('tr.hide').toggle ()
    },
})