({
	doInit: function (component, event, helper) {
		helper.doInit(component, event);
	},
	showEngagementPlan: function (component, event, helper) {
		var selectedId = event.target.dataset.id;
		helper.createEngagementModal(component, selectedId);
	},
	viewRelatedList: function (component, event, helper) {
		var engagementsize = component.get('v.EngagementPlanList');
		component.set('v.ListNumber', engagementsize.length);
		var selectedItemNew = component.find('viewhide').label;
	},
	createEngagementPlan: function (component, event, helper) {
		helper.createEngagementNewModal(component);
	},
	handleSortClick : function (component, event, helper) {
        let sortDir = component.get ('v.sortDir');
        sortDir = (sortDir === 'asc' ? 'desc' : 'asc')
        component.set ('v.sortDir', sortDir);
        helper.sortData (component, component.get ('v.EngagementPlanList'), sortDir);
    }
})