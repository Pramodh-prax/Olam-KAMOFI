({
    STAGE_CLOSING_WON : 'Closing Won',
    doInit: function (component, event) {
        let sectionData = component.get('v.sectionData');

        let params = {
            overViewMetadata: JSON.stringify(sectionData.compDetail),
            data: JSON.stringify({
                accountPlan: sectionData.accountPlan
            })
        }
        this.invokeApex(component, 'c.getDetails', params)
        .then(
            $A.getCallback(result => {
               
                component.set ('v.result', result);
                this.updateVolumeBasedOnUnitOfMeasure (component, JSON.parse (result), component.get ('v.selectedUnitOfMeasure'));

                return this.invokeApex(component, 'c.getComments', {
                    accPlan: sectionData.accountPlan
                });
            })
        ).then(
            $A.getCallback(result => {
                if (result && typeof result !== 'undefined' 
                    && result !== null && result !== 'null'
                    && result !== '') {
                        result = JSON.parse(result);
                    if (result.hasOwnProperty ('contentDocumentId')) {
                        component.set ('v.contentDocumentId', result.contentDocumentId);
                    }
                    if (result.hasOwnProperty ('comments')) {
						component.set ('v.sectionComments', 
                                       (Object.assign({}, JSON.parse(JSON.stringify(component.get ('v.sectionComments'))), JSON.parse (result.comments)))
                                      );
						//component.set ('v.sectionComments', JSON.parse (result.comments));
                    }
                } 
                this.refreshComments (component);
                component.set('v.isLoading', false);
            })
        ).catch(
            $A.getCallback(error => {
                component.set('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);
            })
        );
    },

    handleOnUnitOfMeasureChange : function(component, event) {
		let selectedUnitOfMeasure = event.getParam("value");
		let previouslySelectedUnitOfMeasure = component.get ('v.previouslySelectedUnitOfMeasure');
		if (previouslySelectedUnitOfMeasure !== selectedUnitOfMeasure) {
			component.set ('v.previouslySelectedUnitOfMeasure', component.get ('v.selectedUnitOfMeasure'));
			let result = component.get ('v.result');
			if (result && typeof result !== 'undefined' && result !== null) {
				result = JSON.parse (result);
				this.updateVolumeBasedOnUnitOfMeasure (component, result, selectedUnitOfMeasure);
			}
			component.set ('v.selectedUnitOfMeasure', selectedUnitOfMeasure);
		}
	},
    updateVolumeBasedOnUnitOfMeasure : function (component, result, selectedUnitOfMeasure) {
        let self = this;
        result.forEach (ele => {
            if (ele.OpportunityLineItems && ele.OpportunityLineItems.records && ele.OpportunityLineItems.records.length > 0)
            {
            ele.OpportunityLineItems.records.forEach (item => {
                item = Object.assign (item, 
                    {
                        Volume__c : self.recalculateVoume (component, item.Converted_Volume_in_MT__c, selectedUnitOfMeasure)
                        
                    }
                );
            })
        }
        });
        this.createTabularData(component, this.flattenOpportunityLines(result));
    },
    refreshComments : function (component) {
        let comps = component.find ('sectionCommentsComp');
        if (comps) {
            if (comps && Array.isArray (comps)) {
                comps.forEach (ele => {
                    ele.updateLocalComments ();
                })
            } else {
                comps.updateLocalComments ();
            }
        }
    },
    saveComments : function (component, identifier, oldComment, newComment, commentCompRef) {
        console.log('In save controller helper');
        let sectionComments = component.get ('v.sectionComments');
        if (!identifier) {
            this.showToast(component, 'Error', 'Invalid component identifier', 'error', '5000');
            commentCompRef.set ('v.latestComments', oldComment);
            commentCompRef.set ('v.comments', oldComment);
            return; 
        }

        let sectionData = component.get('v.sectionData');
        let contentDocumentId = component.get ('v.contentDocumentId');

        sectionComments[identifier].comments = newComment;
        component.set('v.isLoading', true);
        let params = {
            accPlan : sectionData.accountPlan,
            contentDocumentId : contentDocumentId ? contentDocumentId : null,
            commentStr : JSON.stringify (sectionComments)
        };
        this.invokeApex (component, 'c.saveComments', params)
        .then (
            $A.getCallback(result => {
                if (result && typeof result !== 'undefined' && result !== null && result !== 'null' && result !== '') {
                    result = JSON.parse (result);
                    if (result.hasOwnProperty ('contentDocumentId')) {
                        component.set ('v.contentDocumentId', result.contentDocumentId);
                    }
                    if (result.hasOwnProperty ('comments')) {
                        component.set ('v.sectionComments', JSON.parse (result.comments));
                    }
                }
                this.refreshComments (component);
                console.log('In save ');
                component.set('v.isLoading', false);
            })
        ).catch(
            $A.getCallback(error => {
                commentCompRef.set ('v.latestComments', oldComment);
                commentCompRef.set ('v.comments', oldComment);
                component.set('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);
                this.showToast(component, 'Error', error.toString (), 'error', '5000');
            })
        )
    },
    flattenOpportunityLines: function (oppRecords) {
        let items = [];
        oppRecords.forEach(ele => {
            if (ele.OpportunityLineItems && ele.OpportunityLineItems.records && ele.OpportunityLineItems.records.length > 0) {
                ele.OpportunityLineItems.records.forEach (item => {
                    item = Object.assign (item, {'IsClosed' : ele.StageName === this.STAGE_CLOSING_WON})
                })
                items = items.concat(ele.OpportunityLineItems.records);
            }
        })
        return items;
    },
    createTabularData: function (component, records) {
        component.set ('v.opportunitiesByCategories', undefined);
        let categoryMap = {};

        let self = this;
        records.forEach((ele, index) => {
            if (ele.Product2.Product_Category__c) {
                if (categoryMap.hasOwnProperty(ele.Product2.Product_Category__c)) {
                    if (ele.Product2.Product_Sub_Category__c) {
                        categoryMap[ele.Product2.Product_Category__c].children.push(ele);
                    } else {
                        categoryMap[ele.Product2.Product_Category__c].nullSubCategoryChilds.push(ele);
                    }
                } else {
                    if (ele.Product2.Product_Sub_Category__c) {
                        categoryMap[ele.Product2.Product_Category__c] = {
                            children: [ele],
                            nullSubCategoryChilds: []
                        };
                    } else {
                        categoryMap[ele.Product2.Product_Category__c] = {
                            children: [],
                            nullSubCategoryChilds: [ele]
                        };
                    }
                }
            }
        });

        let resultMap = {};

        for (const [key, value] of Object.entries(categoryMap)) {
            let tempObj = {};
            let subCategoryMap = {};

            let totalVolume = 0;
            let wonVolume = 0;
            if (value && value.children.length > 0) {
                value.children.forEach((ele, index) => {
                    if (subCategoryMap.hasOwnProperty(ele.Product2.Product_Sub_Category__c)) {
                    	if (ele.Product2.Product_Sub_Category_2__c) {
                            subCategoryMap[ele.Product2.Product_Sub_Category__c].children.push(ele);
                      	}else {
                            subCategoryMap[ele.Product2.Product_Sub_Category__c].nullSubCategoryChilds.push(ele);
                        }
                    } else {
                        if (ele.Product2.Product_Sub_Category_2__c) {
                            subCategoryMap[ele.Product2.Product_Sub_Category__c] = {
                                children: [ele],
                                nullSubCategoryChilds: []
                            };
                        } else {
                            subCategoryMap[ele.Product2.Product_Sub_Category__c] = {
                                children: [],
                                nullSubCategoryChilds: [ele]
                            };
                        }
                    }
                });
                console.log('subcategorymap',subCategoryMap);
                let children = {};
                for (const [cKey, cValue] of Object.entries(subCategoryMap)) {

                    let subSubCategoryMap = {};
                    let totalSubVolume = 0;
                    let totalWonSubVolume = 0; 
                    
                    cValue.children.forEach((ele, index) => {
                         
                            
                        ele = Object.assign (ele, 
                                {
                                    totalVolume : (ele.Volume__c ? ele.Volume__c : 0),
                                    wonVolume : ele.IsClosed ? (ele.Volume__c ? ele.Volume__c : 0) : 0
                                }
                        );
                    	
                    	if (subSubCategoryMap.hasOwnProperty(ele.Product2.Product_Sub_Category_2__c)) {
                        	subSubCategoryMap[ele.Product2.Product_Sub_Category_2__c].children.push(ele);
                        }
                    	else{
                        	subSubCategoryMap[ele.Product2.Product_Sub_Category_2__c] = {
                                children: [ele],
                                nullSubCategoryChilds: []
                            };
                    	}
                       
                        totalSubVolume += ele.totalVolume;
                        totalWonSubVolume += ele.wonVolume;
                    })
                    
                    for (const [cKey, cValue] of Object.entries(subSubCategoryMap)) {
                        let totalSubSubVolume = 0;
                    	let totalWonSubSubVolume = 0; 
                        
                        cValue.children.forEach((ele, index) => {
                        	totalSubSubVolume += (ele.Volume__c ? ele.Volume__c : 0);
                            totalWonSubSubVolume += ele.IsClosed ? (ele.Volume__c ? ele.Volume__c : 0) : 0;
                        })
                        
                        cValue.totalVolume = totalSubSubVolume;
                        cValue.wonVolume = totalWonSubSubVolume;
                    }

                    cValue.nullSubCategoryChilds.forEach((ele, index) => {
                        ele = Object.assign (ele, 
                            {
                                totalVolume : (ele.Volume__c ? ele.Volume__c : 0),
                                wonVolume : ele.IsClosed ? (ele.Volume__c ? ele.Volume__c : 0) : 0
                            }
                        );
                        totalSubVolume += ele.totalVolume;
                        totalWonSubVolume += ele.wonVolume;
                    })
                    
                    children[cKey] = {
                        subCategories: subSubCategoryMap,
                        nullSubCategoryChilds: cValue.nullSubCategoryChilds,
                        totalVolume : totalSubVolume,
                        wonVolume : totalWonSubVolume
                    }
                    totalVolume += children[cKey].totalVolume;
                    wonVolume += children[cKey].wonVolume
                }

                tempObj.subCategories = children;
            }

            tempObj.nullSubCategoryChilds = value.nullSubCategoryChilds;
            value.nullSubCategoryChilds.forEach((ele, index) => {
                ele = Object.assign (ele, 
                    {
                        totalVolume : (ele.Volume__c ? ele.Volume__c : 0),
                        wonVolume : ele.IsClosed ? (ele.Volume__c ? ele.Volume__c : 0) : 0
                    }
                );

                totalVolume += ele.totalVolume;
                wonVolume += ele.wonVolume;
            })
            tempObj.totalVolume = totalVolume;
            tempObj.wonVolume = wonVolume;

            resultMap[key] = tempObj;
        }
        component.set ('v.opportunitiesByCategories', resultMap);
        component.set ('v.isUnitOfMeasureDisabled', (!resultMap || (resultMap && Object.keys(resultMap).length === 0 && resultMap.constructor === Object))) ;
    }       
})