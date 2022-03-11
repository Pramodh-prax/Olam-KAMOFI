({
    doInit: function (component, event, helper) {
        
        helper.fetchcurrentUserAccountTeam(component); // fetches current user Account team - Added  by Bharatesh Shetty as part of OFI
        helper.fetchYearPicklist(component, event);
    },
    closeModel: function (component, event, helper) {
        //component.get ('v.engComp').destroy ();
        component.destroy();
    },
    createNewBudgetvsActuals: function (component, event, helper) {

        var BudgetvsActualrecords = component.get('v.BudgetvsActualCompList');
        var selectedYear = component.get('v.selectedYear');
        
        let count = 0;
        for (let i = 0; i < BudgetvsActualrecords.length; i++) {
        
            if (selectedYear == BudgetvsActualrecords[i].Year__c) {
                count++;
            }
        }
        
        if (count == 0) {
            component.set("v.errors", null);
            helper.SaveBudgetvsActuals(component, selectedYear);
        } else {
            component.set("v.errors", $A.get("$Label.c.KAM_BudgetVsActualsYear"));
        }
    }
})