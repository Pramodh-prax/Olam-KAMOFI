({
	doInit : function(component, event) {
        let sectionData = component.get ('v.sectionData');
        let params = {
            overViewMetadata : JSON.stringify (sectionData.compDetail), 
            data : JSON.stringify ({
                accountPlan : sectionData.accountPlan
            })
        }
        let self = this;
        this.invokeApex (component, 'c.getGroupDetails', params)
        .then(
            $A.getCallback(result => {
                result = JSON.parse (result);
                if (result && typeof result !== 'undefined' && result !== null) {
                    component.set ('v.result', JSON.stringify(result));
                    this.updateVolumeBasedOnUnitOfMeasure (component, result, component.get ('v.selectedUnitOfMeasure'));
                   // component.set ('v.Consumptions', this.createTabledata(component,result));
                }
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                let message = ':' + this.normalizeError (error) ;
                this.showToast(component, 'Error', message, 'error', '3000');
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
        component.set ('v.Consumptions', this.createTabledata(component,result));
    },
    createTabledata: function (component, recodStr) {
        let categoryMap = {};
        let records = recodStr;
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
        component.set ('v.isUnitOfMeasureDisabled', (!resultMap || (resultMap && Object.keys(resultMap).length === 0 && resultMap.constructor === Object))) ;
        return JSON.parse(JSON.stringify(resultMap));
    }
})