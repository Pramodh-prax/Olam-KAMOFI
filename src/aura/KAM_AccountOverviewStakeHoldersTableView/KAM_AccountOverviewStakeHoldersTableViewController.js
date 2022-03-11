({
    doInit : function(component, event, helper) {
        let columnHeaders = {
            name : $A.get ('$Label.c.KAM_Stake_Holder_Table_Header_Name'),
            title : $A.get ('$Label.c.KAM_Stake_Holder_Table_Header_Title'),
            email : $A.get ('$Label.c.KAM_Stake_Holder_Table_Header_Email'),
            reportsTo : $A.get ('$Label.c.KAM_Stake_Holder_Table_Header_Reports_To'),
            owner : $A.get ('$Label.c.KAM_Stake_Holder_Table_Header_Owner'),
            accountName : $A.get ('$Label.c.KAM_Stake_Holder_Table_Header_Account')
        }
        let defaultPageSize = Number ($A.get ('$Label.c.KAM_Default_Num_Records_To_Be_Displayed'));
        component.set ('v.pageSize', defaultPageSize || 10);
        component.set ('v.columnHeaders', columnHeaders);
        let hasPaginatedView = component.get ('v.hasPaginatedView');
        let mode = helper.getUrlParameter ('mode'); 
        if (
            (mode && mode !== null && typeof mode !== 'undefined' && mode === 'printPreview')
            ||  !hasPaginatedView  
        ) {
            component.set ('v.displayedItems', component.get ('v.items'));
            component.set ('v.hasPaginatedView', false); //make sure pagination btns are hidden
        } else {
            helper.updateDisplayList (component);
        }
    },
    handlePreviousClick : function (component, event, helper) {
        let currentIndex = component.get ('v.currentIndex');
        let pageSize = component.get ('v.pageSize');
        currentIndex = currentIndex - pageSize;
        if (currentIndex < pageSize) {
            currentIndex = 0;
        }
        component.set ('v.currentIndex', currentIndex);
        helper.updateDisplayList (component);
    },
    handleNextClick : function (component, event, helper) {
        let currentIndex = component.get ('v.currentIndex');
        let pageSize = component.get ('v.pageSize');
        currentIndex = currentIndex + pageSize;
        
        let items = component.get ('v.items');

        if (currentIndex < items.length) {
            component.set ('v.currentIndex', currentIndex);
            helper.updateDisplayList (component);
        }
    },
    scriptLoaded : function (component, event, helper) {
    },

})