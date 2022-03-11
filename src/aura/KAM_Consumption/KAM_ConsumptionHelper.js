({
    getConsumptionshelper: function (component) {
        let sectionData = component.get('v.sectionData');
        let self = this;
        let params = {
            overViewMetadata: JSON.stringify(sectionData.compDetail),
            data: JSON.stringify({
                accountId: sectionData.accountId,
                accountPlan: sectionData.accountPlan
            })
        };
        this.invokeApex(component, 'c.getDetails', params)
            .then(
                $A.getCallback(result => {
                    if (result && typeof result !== 'undefined' && result !== null) {
                        component.set ('v.result', result);
                        this.updateVolumeBasedOnUnitOfMeasure (component, JSON.parse (result), component.get ('v.selectedUnitOfMeasure'));
                    }
                    component.set('v.isLoading', false);
                })
            ).catch(
                $A.getCallback(error => {
                    component.set('v.isLoading', false);
                    console.log('Error Message: ', error);
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
                console.log('result',result);
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
                    Volume_MT__c : self.recalculateVoume (component, ele.Volume_MT__c, selectedUnitOfMeasure)
                }
            );
        });
        this.createTabledata(component, JSON.stringify (result));
    },
    createTabledata: function (component, recodStr) {

        component.set('v.overAllConsumptions', undefined);
        let categoryMap = {};
        let records = JSON.parse(recodStr);
        records.forEach(ele => {
            if (ele.Category__c) {
                if (categoryMap.hasOwnProperty(ele.Category__c)) {
                    if (ele.Sub_Category__c) {
                        categoryMap[ele.Category__c].children.push(ele);
                    } else {
                        // categoryMap[ele.Category__c].children.push (ele);
                        categoryMap[ele.Category__c].nullSubCategoryChilds.push(ele);
                    }
                } else {
                    if (ele.Sub_Category__c) {
                        categoryMap[ele.Category__c] = {
                            children: [ele],
                            nullSubCategoryChilds: []
                        };
                    } else {


                        // categoryMap[ele.Category__c] = {children : [ele], nullSubCategoryChilds : []}; 

                        categoryMap[ele.Category__c] = {
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

            if (value && value.children.length > 0) {
                value.children.forEach((ele, index) => {
                    if (subCategoryMap.hasOwnProperty(ele.Sub_Category__c)) {
                        if (ele.Sub_Category_2__c) {
                            subCategoryMap[ele.Sub_Category__c].children.push(ele);
                        } else {
                            subCategoryMap[ele.Sub_Category__c].nullSubCategoryChilds.push(ele);
                        }
                    } else {
                        if (ele.Sub_Category_2__c) {
                            subCategoryMap[ele.Sub_Category__c] = {
                                children: [ele],
                                nullSubCategoryChilds: []
                            };
                        } else {
                            subCategoryMap[ele.Sub_Category__c] = {
                                children: [],
                                nullSubCategoryChilds: [ele]
                            };
                        }
                    }
                });
            }

            let tempSubCategory = {};
            let tempRollVolume = 0;
            for (const [sKey, sValue] of Object.entries(subCategoryMap)) {
                let subsubCatMap = {};

                let volume = 0;
                sValue.children.forEach((ele, index) => {
                    if (subsubCatMap.hasOwnProperty(ele.Sub_Category_2__c)) {
                        subsubCatMap[ele.Sub_Category_2__c].children.push(ele);
                    } else {
                        subsubCatMap[ele.Sub_Category_2__c] = {
                            children: [ele]
                        };
                    }
                    volume += (ele.Volume_MT__c ? ele.Volume_MT__c : 0);
                })

                sValue.nullSubCategoryChilds.forEach((ele, index) => {
                    volume += (ele.Volume_MT__c ? ele.Volume_MT__c : 0);
                });

				let xsubsubCatMap = {};
				for (const [xKey, xValue] of Object.entries(subsubCatMap)) {
                    let tempVolume = 0;
                    if (xValue.children) {
                     	xValue.children.forEach((ele, index) => {
                            tempVolume += (ele.Volume_MT__c ? ele.Volume_MT__c : 0);
                        });   
                    }
                    xsubsubCatMap [xKey] = {
                        subCategories : xValue,
                        Volume_MT__c : tempVolume
                    };
                }
                tempSubCategory[sKey] = {
                    subCategories: xsubsubCatMap,
                    nullSubCategoryChilds: sValue.nullSubCategoryChilds,
                    Volume_MT__c: volume
                };

                tempRollVolume += tempSubCategory[sKey].Volume_MT__c;
            }

            tempObj.subCategories = tempSubCategory;
            tempObj.Volume_MT__c = tempRollVolume;
            tempObj.nullSubCategoryChilds = value.nullSubCategoryChilds;
            value.nullSubCategoryChilds.forEach((ele, index) => {
                tempObj.Volume_MT__c += (ele.Volume_MT__c ? ele.Volume_MT__c : 0);
            });
            resultMap[key] = tempObj;
        }
        component.set('v.overAllConsumptions', resultMap);

        component.set ('v.isUnitOfMeasureDisabled', (!resultMap || (resultMap && Object.keys(resultMap).length === 0 && resultMap.constructor === Object))) ;
    }

})