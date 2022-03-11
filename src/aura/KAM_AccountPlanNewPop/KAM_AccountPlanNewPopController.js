({
    doInit: function (component, event, helper) {
        helper.fetchTypePicklist(component); // fetches PickList Values of Type Field
        helper.fetchYearPicklist(component); // fetches PickList Values of Year Field
        helper.fetchcurrentUserAccountTeam(component); // fetches current user Account team - Added  by Bharatesh Shetty as part of OFI
    },
    closeModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    createAccountPlan: function (component, event, helper) {
        var name = component.get("v.Name");
        var startdate = component.get("v.StartDate");
        var enddate = component.get("v.EndDate");
        var year = component.get("v.selectedYear");
        var type = component.get("v.selectedType");
        if (name == null || startdate == null || enddate == "" || year == "" || type == null) {
            var message = 'Please fill mandatory fields!!';
            helper.showToast(component, 'Error', message, 'error', '3000');
        } else {
            helper.saveAccountPlanHelper(component);
        }

    },
    onChangeofYear: function (component, event, helper) {
        var startdate;
        var enddate;
        var year = component.get('v.selectedYear');
        if (year == '--None--') {
            startdate = '';
            enddate = '';
        } else {
            startdate = year + "-01-01";
            enddate = year + "-12-31";
        }
        component.set('v.StartDate', startdate);
        component.set('v.EndDate', enddate);
    },
    saveAndContinueAccountPlan: function (component, event, helper) {
        var name = component.get("v.Name");
        var startdate = component.get("v.StartDate");
        var enddate = component.get("v.EndDate");
        var year = component.get("v.selectedYear");
        var type = component.get("v.selectedType");
        if (name == null || startdate == null || enddate == "" || year == "" || type == null) {
            var message = 'Please fill mandatory fields!!';
            helper.showToast(component, 'Error', message, 'error', '3000');

        } else {
            helper.saveAndContinueAccountPlanHelper(component);
        }

    }
})