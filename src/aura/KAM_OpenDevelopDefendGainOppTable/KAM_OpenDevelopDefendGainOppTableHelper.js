({
    /**
     * Note : This component will only display Open Defend Develop Opportunities
     * Gain Opportunities not displayed
     * Don't get confused by the component name KAM_OpenDefendDevelopGainOppTable
     */
    doInit : function(component, event) {
        component.set ('v.isLoading', true);
        let accountPlan = component.get ('v.accountPlan');
        let params = {
            accPlan : accountPlan
        };
        this.invokeApex (component, 'c.getOpenDefendDevelopOpportunities', params)
        .then (
            $A.getCallback (result => {
               if (result && typeof result !== 'undefined' && result !== null) {
                    component.set ('v.result', JSON.stringify (result));
                    this.updateVolumeBasedOnUnitOfMeasure (component, result, component.get ('v.selectedUnitOfMeasure'));
               }
               component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback (error => {
                component.set ('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);                    
            })
        )
    },
    handleDevOppOnUnitOfMeasureChange : function(component, event) {
		let selectedUnitOfMeasure = event.getParam("value");
		let previouslySelectedUnitOfMeasure = component.get ('v.previouslySelectedUnitOfMeasure');
		if (previouslySelectedUnitOfMeasure !== selectedUnitOfMeasure) {
			component.set ('v.previouslySelectedUnitOfMeasure', component.get ('v.selectedUnitOfMeasure'));
			let result = component.get ('v.result');
			if (result && typeof result !== 'undefined' && result !== null) {
				this.updateVolumeBasedOnUnitOfMeasure (component, JSON.parse(result), selectedUnitOfMeasure);
			}
			component.set ('v.selectedUnitOfMeasure', selectedUnitOfMeasure);
		}
	},
    updateVolumeBasedOnUnitOfMeasure : function (component, result, selectedUnitOfMeasure) {
        let self = this;
        result.forEach (ele => {
            ele = Object.assign (ele, 
                {
                    Estimated_Volume_MT__c : self.recalculateVoume (component, ele.Estimated_Volume_MT__c, selectedUnitOfMeasure)
                }
            );
        });
        component.set ('v.items', result);
        component.set ('v.isUnitOfMeasureDisabled', !result || result === null || typeof result === 'undefined' || (result && result.length === 0));
    },
    getGroupOpportunities : function(component, event) {
        component.set ('v.isLoading', true);

        const allPromises = new Array();

        let accounts = component.get ('v.accounts');

        let accIds = []
        accounts.forEach (ele => {
            accIds.push (ele.Id);
        });
		let params = {
        	accPlan : Object.assign (component.get ('v.accountPlan'), {attributes : undefined}),
            accIdStr : JSON.stringify (accIds)
        };
        this.invokeApex (component, 'c.getGroupOpenDefendDevelopOpportunities', params)
        .then (
            $A.getCallback(results => {
				if (results && typeof results !== 'undefined' && results !== null) {
                    component.set ('v.result', JSON.stringify (results));
                    this.updateVolumeBasedOnUnitOfMeasure (component, results, component.get ('v.selectedUnitOfMeasure'));
               	}
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);                    
            })
        );
    }
})