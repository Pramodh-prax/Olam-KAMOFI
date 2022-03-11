({
	 doInit : function(component, event, helper) {
		helper.getBudgetActuals(component, event, helper);
	},
    showBudgetvsActuals : function(component, event, helper) {
        var selectedId = event.target.dataset.id;       
        helper.createBudgetvsActualsModal(component,selectedId);
    },
    viewRelatedList: function (component, event, helper) {  
        var budgetsize=component.get('v.BudgetvsActuals');
        component.set('v.ListNumber',budgetsize.length);
    },
    createBudgetvsActuals: function (component, event, helper) {  
        helper.createBudgetvsActualsNewModal (component); 
    },
    handleSortClick : function (component, event, helper) {
        let sortDir = component.get ('v.sortDir');
        sortDir = (sortDir === 'asc' ? 'desc' : 'asc')
        component.set ('v.sortDir', sortDir);
        helper.sortData (component, component.get ('v.BudgetvsActuals'), sortDir);
    }
})