({
    doInit: function (component, event) {
        var engPlan = component.get('v.engPlanForAccount');
        if (engPlan && typeof engPlan !== 'undefined' && engPlan !== null) {
            this.updateLocalVariables(component, engPlan);
        } else {
            let sectionData = component.get('v.sectionData');

            let params = {
                overViewMetadata: JSON.stringify(sectionData.compDetail),
                data: JSON.stringify({
                    accountPlan: sectionData.accountPlan
                })
            }
            let self = this;
            this.invokeApex(component, 'c.getDetails', params)
                .then(
                    $A.getCallback(result => {
                        this.updateLocalVariables(component, result);
                    })
                ).catch(
                    $A.getCallback(error => {
                        component.set('v.isLoading', false);
                        this.console.log('Promise was rejected: ', error);
                    })
                );
        }
    },
    riseRequestForEngagementPlanEdit: function (component, event) {
        let params = {
            engagementPlanStr: JSON.stringify({
                Id: component.get('v.engagementPlan').Id
            })
        };
        component.set('v.isLoading', true);
        this.invokeApex(component, 'c.riseRequestForEngagementPlanEdit', params)
            .then(
                $A.getCallback(result => {
                    result = JSON.parse(result);
                    if (result.success) {
                        // let engagementPlan = Object.assign(component.get('v.engagementPlan'), {
                        //     Approval_Status__c: result.engagementPlan.Approval_Status__c
                        // });
                        component.set('v.engagementPlan', result.engagementPlan);

                        if ((result.engagementPlan.Is_Engagement_Plan_Locked__c && result.engagementPlan.Approval_Status__c === 'Pending')) {
                            component.set('v.isEngagementRequestForApprovalBtnDisabled', true);
                        }
                        //this.doInit(component, event);
                    } else {
                        this.showToast(component, 'Error', result.message, 'error', '5000');
                    }
                    component.set('v.isLoading', false);
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    console.log('Error :' + error);
                    this.showToast(component, 'Error', error.toString(), 'error', '5000');
                })
            );
    },
    onEngagementPlanUpdated: function (component, event) {
        component.set('v.isLoading', true);
        let sectionData = component.get('v.sectionData');

        let params = {
            engagementId: event.getParam ('planId')
        }
        
        this.invokeApex(component, 'c.getEngagementPlansById', params)
            .then(
                $A.getCallback(result => {
                    this.updateLocalVariables(component, result);
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    this.console.log('Promise was rejected: ', error);
                })
            );
    },
    updateLocalVariables: function (component, result) {
        if (result && typeof result !== 'undefined' && result !== null) {
            result = JSON.parse(result);

            if (result && typeof result !== 'undefined' && result.length > 0) {
                component.set('v.engagementPlan', result[0]);

                if (result[0] &&
                    result[0].Engagement_Plan_Lines__r &&
                    result[0].Engagement_Plan_Lines__r.records) {
                    result[0].Engagement_Plan_Lines__r.records.forEach((ele, index) => {
                        ele.Actuals__c = !ele.Actuals__c ? 0 : ele.Actuals__c;
                    })

                    component.set('v.items', result[0].Engagement_Plan_Lines__r.records);
                }

                component.set('v.isEngagementButtonDisabled', result[0].Is_Engagement_Plan_Locked__c);

                this.invokeApex (component, 'c.isLocked', {recordId : result[0].Id})
                .then (
                    $A.getCallback (isLocked => {
                        if (isLocked || (result[0].Is_Engagement_Plan_Locked__c && result[0].Approval_Status__c === 'Pending')) {
                            component.set('v.isEngagementRequestForApprovalBtnDisabled', true);
                            // if (result[0].Approval_Status__c === 'Pending') {    
                            // }
                        }
                    })
                ).catch (
                    $A.getCallback (error => {
                        this.console.log('Promise was rejected: ', error);
                    })
                )
            }
        }
        component.set('v.isLoading', false);
        if (component.get ('v.launchPlanCreation')) {
            this.createEngagementModal (component);
            component.set ('v.launchPlanCreation', false);
        }
    },
    createEngagementModal: function (component) {
        let sectionData = component.get('v.sectionData');
        $A.createComponent(
            'c:KAM_EngagementCreationComp', {
                'accountId': sectionData.accountId,
                'accountPlan': sectionData.accountPlan,
                'engagementPlan': component.get('v.engagementPlan'),
                'engagementPlans': component.get('v.items')
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set('v.addEngagementModal', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log(errorMessage);
                }
            }
        );
    }
})