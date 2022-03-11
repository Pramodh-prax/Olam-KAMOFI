({
    doInit : function(component, event) {
        component.set ('v.isLoading', true);
        let self = this;
        let params = {
            'planType' : component.get ('v.accountPlan').Type__c
        };
        this.invokeApex (component, 'c.getAccountPlanSections', params)
        .then(
            $A.getCallback(result => {
                const allPromises = new Array();
                if (result && typeof result !== 'undefined' && result !== null) {
                    JSON.parse (result).forEach (ele => {
                        const data = {};
                        data.compDetail = ele;
                        data.accountId = component.get ('v.accountId');
                        data.accountPlan = component.get ('v.accountPlan');
                        data.sObjectName = component.get ('v.sObjectName');
                        
                        allPromises.push(self.createComponent(
                            component,
                            ele.Component_Name__c,
                            {'sectionData': data}
                            )
                        );
                    });
                }
                return Promise.all(allPromises);
            })
        ).then (
            $A.getCallback(sections => {
                component.set('v.sectionItems', sections);
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                console.log('Promise was rejected: ', error);                    
            })
        );
    },
})