({
    doInit : function(component, event) {
        
        const frequencyPickListPromise = this.getFrequencyPickList (component);
        const frequencyMappingPromise = this.invokeApex (component, 'c.getActiveFrequencyMapping');

        component.set ('v.isLoading', true);

        Promise.all ([frequencyPickListPromise, frequencyMappingPromise]).then (
            $A.getCallback (results => {
                component.set ('v.frequencyOptions', results[0]);
                this.createFrequencyMap (component, results[1]);
            })
        ).then (
            $A.getCallback (() => {
                return this.getEngangementTypePickList (component);
                // let engagementPlans = component.get ('v.engagementPlans');
                // if (!engagementPlans || engagementPlans && engagementPlans.length == 0) {
                //     return this.getEngangementTypePickList (component);
                // } else {
                //     return Promise.resolve ();
                // }
            })
        ).then (
            $A.getCallback (result => {
                if (result && typeof result !== 'undefined') {

                    let engagementPlans = [];

                    component.set ('v.engangementTypeOptions', result);

                    let lines = component.get ('v.engagementPlans');

                    result.forEach(element => {
                        let index = -1;
                        if (lines && lines.length > 0) {
                            index = lines.findIndex (ele => ele.Type_of_Engagement__c == element.value);   
                        }
                        if (index > -1) {
                            engagementPlans.push (lines[index]);
                        } else {
                            engagementPlans.push ({
                                Type_of_Engagement__c : element.value
                            })
                        }
                    });                        

                    component.set ('v.engagementPlans', engagementPlans);
                }
                this.updatePlanWrapper (component);
                component.set ('v.isLoading', false);
            })
        )
        .catch (
            $A.getCallback (error => {
                component.set ('v.isLoading', false);
                console.log ('Error :' + error);
            })
        )
    },
    createFrequencyMap : function (component, items) {
        if (items && typeof items !== 'undefined' && items.length > 0) {
            const frequencyMapping = items.reduce ((accum, currentVal) => {
                accum[currentVal.MasterLabel] = currentVal;
                return accum;
            }, {});
            component.set ('v.frequencyMapping', frequencyMapping);
        }
    },
    updatePlanWrapper : function (component) {
        let engagementPlans = component.get ('v.engagementPlans');
        let engagementPlansWrapper = [];

        const frequencyMapping = component.get ('v.frequencyMapping');

        let self = this;
        engagementPlans.forEach (ele => {
            const isPlanedEditable = self.verifyPlanNeedsUserInput (component, ele, frequencyMapping);
            engagementPlansWrapper.push ({
                engagementPlan : ele,
                attendies : ele.Attendee__c ? JSON.parse (ele.Attendee__c) : [],
                isPlanedEditable : isPlanedEditable
            })
        });

        component.set ('v.engagementPlansWrapper', engagementPlansWrapper);
    },
    verifyPlanNeedsUserInput : function (component, ele, frequencyMapping) {
        if (ele.Frequency__c) {
            if (frequencyMapping && frequencyMapping.hasOwnProperty (ele.Frequency__c)) {
                const frqVal = frequencyMapping[ele.Frequency__c];
                return frqVal.Value_Type__c === 'User Input';
            } 
        }
        return false;
    },
    getEngangementTypePickList : function (component) {
        let params = {
            objectName : 'Engagement_Plan_Line__c', 
            fieldName : 'Type_of_Engagement__c', 
            discardInactive : true, 
            shouldIncludeNone : false
        }
        return this.invokeApex (component, 'c.getEngangementPickListValuesByField', params);
    },
    getFrequencyPickList : function (component) {
        let params = {
            objectName : 'Engagement_Plan_Line__c', 
            fieldName : 'Frequency__c', 
            discardInactive : true, 
            shouldIncludeNone : false
        }
        return this.invokeApex (component, 'c.getEngangementPickListValuesByField', params);
    },
    handleOnSave : function (component, isLocked) {
        let engagementPlansWrapper  = component.get ('v.engagementPlansWrapper');
        let engagementLines = [];
        engagementPlansWrapper.forEach (ele => {
            ele.engagementPlan.Attendee__c = JSON.stringify (ele.attendies);
            ele.engagementPlan.members = undefined;
            engagementLines.push (ele.engagementPlan);
        });
        let engagementPlan = component.get ('v.engagementPlan');
        if (!engagementPlan || typeof engagementPlan === 'undefined' || engagementPlan === null) {
            engagementPlan = {};
            const accountPlan = component.get ('v.accountPlan');
            engagementPlan.Account__c = accountPlan.Account__c;
            engagementPlan.Business_Unit__c = accountPlan.BU_Identifier__c;
            engagementPlan.End_Date__c = accountPlan.EndDate__c;
            engagementPlan.Start_date__c = accountPlan.StartDate__c;
            engagementPlan.Is_Engagement_Plan_Locked__c = isLocked;
            engagementPlan.Year__c = accountPlan.Year__c;
            engagementPlan.Name = accountPlan.BU_Identifier__c + '-' + accountPlan.Year__c;
        } else {
            engagementPlan = Object.assign (engagementPlan, {Is_Engagement_Plan_Locked__c : isLocked, attributes : undefined, Engagement_Plan_Lines__r : undefined});
        }
        
        // if (engagementLines && engagementLines.length > 0) {
        //     engagementLines.forEach (ele => {
        //         ele = Object.assign (ele, {members : undefined});
        //     })
        // }

        let params = { 
            engagementPlanLineStr : JSON.stringify (engagementLines),
            engagementPlanStr : JSON.stringify (engagementPlan)
        }
        component.set ('v.isLoading', true);
        this.invokeApex (component, 'c.createEngagementPlans', params)
        .then (
            $A.getCallback (result => {
                result = JSON.parse (result);
                if (result.success) {
                    component.set ('v.engagementPlans', result.engagementLines);
                    // let plan =  result.engagementPlan;
                    // plan['Engagement_Plan_Lines__r'] = result.engagementLines;
                    component.set ('v.engagementPlan', result.engagementPlan);
                    $A.get('e.force:refreshView').fire();
                    const engagementPlanUpdated = component.getEvent("engagementPlanUpdated");
                    if (engagementPlanUpdated) {
                        engagementPlanUpdated.setParam ('planId', result.engagementPlan.Id);
                        engagementPlanUpdated.fire();
                    }
                    component.destroy ();
                } else {
                    this.showToast(component, 'Error', result.message, 'error', '5000');
                }
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback (error => {
                component.set ('v.isLoading', false);
                console.log ('Error :' + error);
                this.showToast(component, 'Error', error.toString (), 'error', '5000');
            })
        )
    }
})