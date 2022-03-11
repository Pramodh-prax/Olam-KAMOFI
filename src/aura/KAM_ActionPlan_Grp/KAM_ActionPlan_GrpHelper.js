({
    STAGE_CLOSING_WON : 'Closing Won',
    doInit : function(component, event) {
        let sectionData = component.get ('v.sectionData');
        component.set ('v.isLoading', true);

        let params = {
            overViewMetadata : JSON.stringify (sectionData.compDetail), 
            data : JSON.stringify ({
                accountPlan : sectionData.accountPlan
            })
        }
        let self = this;
        this.invokeApex (component, 'c.getDetails', params)
        .then(
            $A.getCallback(result => {
                let accIds = []
                if (result && typeof result !== 'undefined' && result !== null) {
                result = JSON.parse (result);
                component.set ('v.accounts', result);
                result.forEach (ele => {
                        accIds.push (ele.Id);
                    });
                }
				let params = {
                	accPlan : Object.assign (sectionData.accountPlan, {attributes : undefined}),
                    accIdStr : JSON.stringify (accIds)
                };
                return self.invokeApex (component, 'c.getGroupDefendDevelopGainOpportunities', params) 
            })
        ).then (
            $A.getCallback(results => {
                
                let allAccountItems = [];
                let namesMap = {};

                if (results && results.length > 0) {
                    
                    results.forEach (ele => {
                        if (!namesMap.hasOwnProperty (ele.AccountId)) {
                        	namesMap[ele.AccountId] = {name : ele.Account.Name}
                       	}
                        if (ele.OpportunityLineItems) {
                        	ele.OpportunityLineItems.forEach (item => {
                            	item = Object.assign (item, {'AccountId' : ele.AccountId, 'IsClosed' : ele.StageName === this.STAGE_CLOSING_WON})
                            })
                            allAccountItems = allAccountItems.concat (ele.OpportunityLineItems);
                        }
            		});
                    
                    component.set ('v.result', JSON.stringify(allAccountItems));
                    this.updateVolumeBasedOnUnitOfMeasure (component, allAccountItems, component.get ('v.selectedUnitOfMeasure'));
				} else {
                    component.set ('v.opportunitiesByCategories', {});
				}
                component.set ('v.namesMap', namesMap);
                component.set ('v.isLoading', false);
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
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                let message = ':' + this.normalizeError (error) ;
                this.showToast(component, 'Error', message, 'error', '3000');
                console.log('Promise was rejected: ', error);                    
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
            
            
            ele = Object.assign (ele, 
                {
                    Volume__c : self.recalculateVoume (component, ele.Converted_Volume_in_MT__c, selectedUnitOfMeasure)
                }
            );
        });
        this.createTabularData (component, result);
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
                    console.log('result for save comments',result);
                    result = JSON.parse (result);
                    if (result.hasOwnProperty ('contentDocumentId')) {
                        component.set ('v.contentDocumentId', result.contentDocumentId);
                    }
                    if (result.hasOwnProperty ('comments')) {
                        component.set ('v.sectionComments', JSON.parse (result.comments));
            			console.log('Set comments');
                    }
                }
                this.refreshComments (component);
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
                        } else {
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

                let children = {};
                for (const [cKey, cValue] of Object.entries(subCategoryMap)) {

                    let subSubCategoryMap = self.getFlatten (component, cValue.children);
                    let totalSubVolume = 0;
                    let totalWonSubVolume = 0;

                    for (const [sKey, sValue] of Object.entries(subSubCategoryMap)) {
                        totalSubVolume += sValue.totalVolume;
                        totalWonSubVolume += sValue.wonVolume;  
                    }

                    let nullSubCategoryMap = self.nullChildYearFlatten(component, cValue.nullSubCategoryChilds)

                    for (const [sKey, sValue] of Object.entries(nullSubCategoryMap)) {
                        totalSubVolume += sValue.totalVolume;
                        totalWonSubVolume += sValue.wonVolume;
                    }

                    children[cKey] = {
                        subCategories: subSubCategoryMap,
                        nullSubCategoryChilds: nullSubCategoryMap,
                        totalVolume : totalSubVolume,
                        wonVolume : totalWonSubVolume
                    }
                    totalVolume += children[cKey].totalVolume;
                    wonVolume += children[cKey].wonVolume
                }

                tempObj.subCategories = children;
            }

            tempObj.nullSubCategoryChilds = self.nullChildYearFlatten(component, value.nullSubCategoryChilds);
            for (const [sKey, sValue] of Object.entries(tempObj.nullSubCategoryChilds)) {
                totalVolume += sValue.totalVolume;
                wonVolume += sValue.wonVolume;
            }
            tempObj.totalVolume = totalVolume;
            tempObj.wonVolume = wonVolume;

            resultMap[key] = tempObj;
        }
        //console.log ('resultMap :' + resultMap);
        //console.log ('resultMap :' + JSON.stringify (resultMap))
        component.set ('v.opportunitiesByCategories', resultMap);
        component.set ('v.isUnitOfMeasureDisabled', (!resultMap || (resultMap && Object.keys(resultMap).length === 0 && resultMap.constructor === Object))) ;
    },
    getFlatten : function (component, items) {
        let subReturn = {};
    
        let subSubCategoryMap = {};
        items.forEach ( (ele, index) => {
            if (subSubCategoryMap.hasOwnProperty (ele.Product2.Product_Sub_Category_2__c)) {
                subSubCategoryMap[ele.Product2.Product_Sub_Category_2__c].children.push (ele);
            } else {
                subSubCategoryMap[ele.Product2.Product_Sub_Category_2__c] = {children : [ele] }; 
            }
        })

        for (const [cKey, cValue] of Object.entries(subSubCategoryMap)) {
            
            let totalSubVolume = 0;
            let totalWonSubVolume = 0;

            let accKeyObj = {};
            cValue.children.forEach (ele => {
                if (accKeyObj.hasOwnProperty (ele.AccountId)) {
                    accKeyObj[ele.AccountId].children.push (ele);
                } else {
                    accKeyObj[ele.AccountId] = {children : [ele]};
                }
            })

            let returnObj = {};
            for (const [accKey, accValue] of Object.entries(accKeyObj)) {
    
                let totalSubSubVolume = 0;
                let totalWonSubSubVolume = 0;

                accValue.children.forEach (ele => {
                    ele = Object.assign (ele, 
                        {
                            totalVolume : (ele.Volume__c ? ele.Volume__c : 0),
                            wonVolume : ele.IsClosed ? (ele.Volume__c ? ele.Volume__c : 0) : 0
                        }
                    );
                    totalSubVolume += ele.totalVolume;
                    totalWonSubVolume += ele.wonVolume;

                    totalSubSubVolume += ele.totalVolume;
                    totalWonSubSubVolume += ele.wonVolume;
                    
                })
                returnObj [accKey] = {
                    subCategories : accValue.children,
                    totalVolume : totalSubSubVolume,
                    wonVolume : totalWonSubSubVolume
                };
            }

            subReturn [cKey ? cKey : 'no_subSubCat'] = {
                subCategories :returnObj,
                totalVolume : totalSubVolume,
                wonVolume : totalWonSubVolume
            };
        }
        return subReturn;
    },
    nullChildYearFlatten : function(component, items) {

        let accKeyObj = {};
        items.forEach (ele => {
            if (accKeyObj.hasOwnProperty (ele.AccountId)) {
                accKeyObj[ele.AccountId].children.push (ele);
            } else {
                accKeyObj[ele.AccountId] = {children : [ele]};
            }
        })

        let returnObj = {};
        for (const [accKey, accValue] of Object.entries(accKeyObj)) {
            
            let totalSubVolume = 0;
            let totalWonSubVolume = 0;

            accValue.children.forEach (ele => {
                ele = Object.assign (ele, 
                    {
                        totalVolume : (ele.Volume__c ? ele.Volume__c : 0),
                        wonVolume : ele.IsClosed ? (ele.Volume__c ? ele.Volume__c : 0) : 0
                    }
                );
                totalSubVolume += ele.totalVolume;
                totalWonSubVolume += ele.wonVolume;
            })
            returnObj [accKey] = {
                subCategories :accValue.children,
                totalVolume : totalSubVolume,
                wonVolume : totalWonSubVolume
            };
        }
        return returnObj;
    }
})