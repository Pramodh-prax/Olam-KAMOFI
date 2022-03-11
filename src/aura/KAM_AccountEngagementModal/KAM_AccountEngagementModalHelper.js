({
    doInit: function (component, event, helper) {
        let sectiondata = {
            compDetail: {
                Title__c: 'Engagement Plans'
            }
        };
        component.set('v.SectionData', sectiondata);
        let params = {
            engagementId: component.get('v.EngagementId')
        };

        this.invokeApex(component, 'c.getEngagementPlansById', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set('v.EngagementPlan', result);
                        component.set('v.isLoading', false);
                        //this.createEngagementModal(component);
                    }
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                    console.log('Error Message: ', error);
                })
            );
    },
    createEngagementModal: function (component) {
        $A.createComponent(
            'c:KAM_EngagementPlan', {
                'engPlanForAccount': component.get('v.EngagementPlan'),
                'sectionData': component.get('v.SectionData')
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set('v.engComp', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log(errorMessage);
                }
            }
        );
    }
})