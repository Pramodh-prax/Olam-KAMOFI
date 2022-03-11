({
    doInit: function (component, event, helper) {
        helper.fetchcurrentUserAccountTeam(component); // fetches current user Account team - Added  by Bharatesh Shetty as part of OFI
        helper.fetchYearPicklist(component, event);
    },
    closeModel: function (component, event, helper) {
        //component.get ('v.engComp').destroy ();
        component.destroy();
    },
    createNewEngagementPlan: function (component, event, helper) {
        var engagementrecords = component.get('v.EngagementCompList');
        var selectedYear = component.get('v.selectedYear');
        let count = 0;
        for (let i = 0; i < engagementrecords.length; i++) {
            if (selectedYear == engagementrecords[i].Year__c) {
                count++;
            }
        }
        if (count == 0) {
            component.set("v.errors", null);
            helper.SaveEngagementPlan(component, selectedYear);
        } else {
            component.set("v.errors", $A.get("$Label.c.KAM_EnagagementPlanYear"));
        }
    }
})