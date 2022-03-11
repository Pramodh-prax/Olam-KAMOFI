({
    NUMBER_OF_PREVIOUS_YEARS : 3,
    YEAR_MAP_VALUES : ["1stYear", "2ndYear", "3rdYear", "currentYear"],
    doInit : function (component, event) {
        component.set ('v.isLoading', true);
        let sectionData = component.get ('v.sectionData');

        const accountPlan = sectionData.accountPlan;
        const currentYear = Number (accountPlan.Year__c) || new Date().getFullYear ();  

        let yearsArray = [];
        
        for (let index = 0; index < this.NUMBER_OF_PREVIOUS_YEARS; index++ ) {
            yearsArray.push (currentYear - (index + 1));
        }

        yearsArray.sort((a, b) => {
            if (a > b) return 1;
            if (a < b) return -1;
            return 0;
        });

        component.set ('v.years', yearsArray);
        component.set ('v.currentYear', currentYear);


        
        let yearMap = {};
        yearsArray.push (currentYear);
        yearsArray.forEach ( (ele, index) => {
            yearMap[ele] = this.YEAR_MAP_VALUES[index];
        });

        component.set ('v.yearMap', yearMap);


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
                this.updateLocalVariables (component, result);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);                    
            })
        );
        this.fetchBudgets (component);
    },
    fetchBudgets : function (component) {
        let sectionData = component.get ('v.sectionData');

        let yearsArray = Array.from (component.get ('v.years'));
        yearsArray.push (component.get ('v.currentYear'));

        let params = {
            accountPlanStr : JSON.stringify (sectionData.accountPlan),
            yearsStr : JSON.stringify (yearsArray)
        };
        this.invokeApex (component, 'c.getOverAllBudgets', params)
        .then(
            $A.getCallback(result => {
                component.set ('v.result', JSON.stringify(result));
                this.updateVolumeBasedOnUnitOfMeasure (component, result, component.get ('v.selectedUnitOfMeasure'));
               // this.modifyBudgetLines  (component, result)
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
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
            if (ele.Budget_vs_Actual_Lines__r && ele.Budget_vs_Actual_Lines__r.length > 0)
            {
                ele.Budget_vs_Actual_Lines__r.forEach (item => {
                item = Object.assign (item, 
                    {
                        Volume__c : self.recalculateVoume (component, item.Volume__c, selectedUnitOfMeasure),
                        Actuals__c :self.recalculateVoume (component, item.Actuals__c, selectedUnitOfMeasure),
                        Total_Consumption__c:self.recalculateVoume (component, item.Total_Consumption__c, selectedUnitOfMeasure)
                    }
                );
            })
        }
        });
        this.modifyBudgetLines  (component, result)
    },
    modifyBudgetLines : function (component, result) {
        component.set ('v.overAllBudgets', undefined);
        let items = [];
        result.forEach (ele => {
            if (ele.Budget_vs_Actual_Lines__r && ele.Budget_vs_Actual_Lines__r.length > 0) {
                ele.Budget_vs_Actual_Lines__r.forEach (item => {
                    item = Object.assign (item, {'Start_date__c' : ele.Start_date__c})
                })
                items = items.concat (ele.Budget_vs_Actual_Lines__r);
            }
        })
        this.createTabularData (component, items);
    },
    updateLocalVariables : function (component, result) {
        if (result && typeof result !== 'undefined' && result !== null) {
            result = JSON.parse (result);

            if (result && result.length > 0 && result [0]) {
                let budget = result [0];

                component.set ('v.budget', budget);
                component.set ('v.budgets', result [0].Budget_vs_Actual_Lines__r.records);
                
                component.set ('v.isAddBudgetButtonDisabled', result[0].Is_Budget_Locked__c);

                // if (result[0].Is_Budget_Locked__c) {
                //     if (result[0].Approval_Status__c === 'Pending') {
                //         component.set ('v.isModifyBudgetBtnDisabled',true);
                //     }
                // }

                this.invokeApex (component, 'c.isLocked', {recordId : result[0].Id})
                .then (
                    $A.getCallback (isLocked => {
                        if (isLocked || (result[0].Is_Budget_Locked__c && result[0].Approval_Status__c === 'Pending')) {
                            component.set('v.isModifyBudgetBtnDisabled', true);
                        }
                    })
                ).catch (
                    $A.getCallback (error => {
                        this.console.log('Promise was rejected: ', error);
                    })
                )

            }
        }
        component.set ('v.isLoading', false);
    },
    createBudgetModal: function (component) {
        let sectionData = component.get ('v.sectionData');
        $A.createComponent(
            'c:KAM_BudgetCreationComp', {
                'accountId': sectionData.accountId,
                'accountPlan' : sectionData.accountPlan,
                'budget' : component.get ('v.budget'),
                'budgets' : component.get ('v.budgets')
            },
            (infoSubPanel, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    component.set ('v.addBudgetModal', infoSubPanel)
                } else if (status === 'INCOMPLETE') {
                    console.log ('No response from server or client is offline.');
                } else if (status === 'ERROR') {
                    console.log (errorMessage);
                }
            }
        );
    },
    onBudgetUpdated : function (component, event) {
        component.set ('v.isLoading', true);
        let sectionData = component.get ('v.sectionData');
        let yearsArray = Array.from (component.get ('v.years'));
        yearsArray.push (component.get ('v.currentYear'));
        // let params = {
        //     accountPlan : sectionData.accountPlan,
        //     years : yearsArray
        // }
        let params = {
            accountPlanStr : JSON.stringify (sectionData.accountPlan),
            yearsStr : JSON.stringify (yearsArray)
        }
        const refreshBudgetPromise = this.invokeApex (component, 'c.refreshBudgetPlan', {accountPlanStr : JSON.stringify (sectionData.accountPlan)})
        //const refreshBudgetPromise = this.invokeApex (component, 'c.refreshBudgetPlan', {accountPlan : sectionData.accountPlan});
        const refreshOverAllBudgetPromise = this.invokeApex (component, 'c.refreshOverAllBudget', params);
        
        Promise.all ([refreshBudgetPromise, refreshOverAllBudgetPromise]).then(
            $A.getCallback(results => {
                this.updateLocalVariables (component, results[0]);
                component.set ('v.result', JSON.stringify(results[1]));
                this.modifyBudgetLines  (component, results[1])
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);                    
            })
        );
    },
    riseRequestForBudgetEdit : function (component, event) {
        let params = {
            budgetStr : JSON.stringify ({
                Id : component.get ('v.budget').Id
            })
        };
        component.set ('v.isLoading', true);
        this.invokeApex (component, 'c.riseRequestForBudgetEdit', params)
        .then (
            $A.getCallback (result => {
                result = JSON.parse (result);
                if (result.success) {
                    let budget = Object.assign (component.get ('v.budget'), {Approval_Status__c : result.budget.Approval_Status__c});
                    component.set ('v.budget', budget);
                    
                    this.onBudgetUpdated (component, event);
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
        );
    },
    createTabularData : function (component, records) {
        let categoryMap = {};

        let self = this;
        
        records.forEach ((ele, index) => {
            if (ele.Category__c) {
              if (categoryMap.hasOwnProperty (ele.Category__c)) {
                if (ele.Sub_Category__c) {
                  categoryMap[ele.Category__c].children.push (ele);
              } else {
                  categoryMap[ele.Category__c].nullSubCategoryChilds.push (ele);
              }
            } else {
                if (ele.Sub_Category__c) {
                    categoryMap[ele.Category__c] = {children : [ele], nullSubCategoryChilds : []}; 
                } else {
                        categoryMap[ele.Category__c] = {children : [], nullSubCategoryChilds : [ele]}; 
                }
            }
          }
        });

        let resultMap = {};

        for (const [key, value] of Object.entries(categoryMap)) {
            let tempObj = {};
            let subCategoryMap = {};
            
                let subTotal = {};
                
            if (value && value.children.length > 0) {
                value.children.forEach ((ele, index) => {
                    if (subCategoryMap.hasOwnProperty (ele.Sub_Category__c)) {
                        if (ele.Sub_Category_2__c) {
                            subCategoryMap[ele.Sub_Category__c].children.push (ele);
                        } else {
                            subCategoryMap[ele.Sub_Category__c].nullSubCategoryChilds.push (ele);
                        }
                    } else {
                        if (ele.Sub_Category_2__c) {
                            subCategoryMap[ele.Sub_Category__c] = {children : [ele], nullSubCategoryChilds : [] }; 
                        } else {
                            subCategoryMap[ele.Sub_Category__c] = {children : [], nullSubCategoryChilds : [ele] };
                        }
                    }
                });
                let children = {};
                let subsubTotal = {};       
                for (const [cKey, cValue] of Object.entries(subCategoryMap)) {
                    let k = cKey ? cKey : 'no_subCat';
                    
                    children[k] = {
                        subCategories : self.getFlatten (component, cValue.children),
                        nullSubCategoryChilds : self.nullChildYearFlatten(component, cValue.nullSubCategoryChilds)
                    }
                        
                    subsubTotal = {};
                    
                    for (const [nKey, nValue] of Object.entries(children[k].subCategories)) {
                        for (const [fKey, fValue] of Object.entries(nValue)) {
                        
                            let tempObj = subsubTotal.hasOwnProperty(fKey) ? subsubTotal[fKey] : {Actuals__c : 0, Volume__c: 0, 'achieved%' : 0};
                            
                            tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c : 0;
                            tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c : 0;
                            tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c : 0;

                            tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c + Number (fValue.Actuals__c) : Number (fValue.Actuals__c);
                            tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c + Number (fValue.Volume__c) : Number (fValue.Volume__c);		
                            //tempObj['achieved%'] = tempObj.Volume__c ? (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2) : 0;
                            tempObj['achieved%'] = (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2);
                            tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c + Number (fValue.Total_Consumption__c) : Number (fValue.Total_Consumption__c);		
                            //tempObj['walletShare%'] = tempObj.Total_Consumption__c ? (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2) : 0;
                            tempObj['walletShare%'] =  (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2);
                            
                            subsubTotal[fKey] = tempObj;
                                
                        }
                    }
                    for (const [nKey, nValue] of Object.entries(children[k].nullSubCategoryChilds)) {
                        
                        let tempObj = subsubTotal.hasOwnProperty(nKey) ? subsubTotal[nKey] : {Actuals__c : 0, Volume__c: 0};
                        tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c : 0;
                        tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c : 0;
                        tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c : 0;

                        tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c + Number (nValue.Actuals__c) : Number (nValue.Actuals__c);
                        tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c + Number (nValue.Volume__c) : Number (nValue.Volume__c);		
                        //tempObj['achieved%'] = tempObj.Volume__c ? (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2) : 0;
                        tempObj['achieved%'] = (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2);
                        tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c + Number (nValue.Total_Consumption__c) : Number (nValue.Total_Consumption__c);		
                        //tempObj['walletShare%'] = tempObj.Total_Consumption__c ? (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2) : 0;
                        tempObj['walletShare%'] = (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2);

                        subsubTotal[nKey] = tempObj;
                        
                    }
                    children[k].subTotal = subsubTotal;
                }
                
                tempObj.subCategories = children;
            
                
                Object.values (tempObj.subCategories).forEach (el => {
                    const ele = el.subTotal;
                    
                    for (const [eKey, eValue] of Object.entries(el.subTotal)) {
                            
                        let tempObj = subTotal.hasOwnProperty(eKey) ? subTotal[eKey] : {Actuals__c : 0, Volume__c: 0};
                        // tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c : 0;
                        // tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c : 0;
                            
                        tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c + Number (eValue.Actuals__c) : Number (eValue.Actuals__c);
                        tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c + Number (eValue.Volume__c) : Number (eValue.Volume__c);		
                        //tempObj['achieved%'] = tempObj.Volume__c ? (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2) : 0;
                        tempObj['achieved%'] = (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2);
                        tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c + Number (eValue.Total_Consumption__c) : Number (eValue.Total_Consumption__c);		
                        //tempObj['walletShare%'] = tempObj.Total_Consumption__c ? (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2) : 0;
                        tempObj['walletShare%'] = (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2);
                        subTotal[eKey] = tempObj;
                        
                        
                        /* subTotal[eKey] =  subTotal.hasOwnProperty(eKey) 
                            ? subTotal[eKey] + Number (eValue)
                            : Number (eValue); */
                    }
                });
            }
            tempObj.nullSubCategoryChilds = self.nullChildYearFlatten(component, value.nullSubCategoryChilds);
            
            for (const [nKey, nValue] of Object.entries(tempObj.nullSubCategoryChilds)) {
            
                let tempObj = subTotal.hasOwnProperty(nKey) ? subTotal[nKey] : {Actuals__c : 0, Volume__c: 0};
                tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c : 0;
                tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c : 0;
                tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c : 0;
                            
                tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c + Number (nValue.Actuals__c) : Number (nValue.Actuals__c);
                tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c + Number (nValue.Volume__c) : Number (nValue.Volume__c);		
                //tempObj['achieved%'] = tempObj.Volume__c ? (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2) : 0;
                tempObj['achieved%'] = (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2);
                tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c + Number (nValue.Total_Consumption__c) : Number (nValue.Total_Consumption__c);		
                //tempObj['walletShare%'] = tempObj.Total_Consumption__c ? (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2) : 0;
                tempObj['walletShare%'] = (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2);

                subTotal[nKey] = tempObj;
            }
            tempObj.subTotal = subTotal;  
            resultMap[key] = tempObj;
        }
        component.set ('v.overAllBudgets', resultMap);
        component.set ('v.isUnitOfMeasureDisabled', (!resultMap || (resultMap && Object.keys(resultMap).length === 0 && resultMap.constructor === Object))) ;
      //  console.log ('resultMap :' + JSON.stringify (resultMap));
    },
    getFlatten : function(component, items) {
        const yearMap = component.get ('v.yearMap');

        let subReturn = {};
    
        let subSubCategoryMap = {};
        items.forEach ( (ele, index) => {
            if (subSubCategoryMap.hasOwnProperty (ele.Sub_Category_2__c)) {
                subSubCategoryMap[ele.Sub_Category_2__c].children.push (ele);
            } else {
                subSubCategoryMap[ele.Sub_Category_2__c] = {children : [ele] }; 
            }
        })
        for (const [cKey, cValue] of Object.entries(subSubCategoryMap)) {
            let returnObj = {};
            cValue.children.forEach (ele => {
                const stYear = new Date (ele.Start_date__c).getFullYear ();
                if (yearMap.hasOwnProperty (stYear)) {
                    ele.Actuals__c = ele.Actuals__c ? ele.Actuals__c : 0;
                    ele.Volume__c = ele.Volume__c ? ele.Volume__c : 0;
                    //ele['achieved%'] = ele.Volume__c ? (100 * (ele.Actuals__c / ele.Volume__c)).toFixed(2) : 0;
                    ele['achieved%'] = (100 * (ele.Actuals__c / ele.Volume__c)).toFixed(2);
                    ele.Total_Consumption__c = ele.Total_Consumption__c ? ele.Total_Consumption__c : 0;
                    //ele['walletShare%'] = ele.Total_Consumption__c ? (100 * (ele.Actuals__c / ele.Total_Consumption__c)).toFixed(2) : 0;
                    ele['walletShare%'] = (100 * (ele.Actuals__c / ele.Total_Consumption__c)).toFixed(2);
                    returnObj[yearMap[stYear]] = ele;
                }
            })
            subReturn [cKey ? cKey : 'no_subSubCat'] = returnObj;
        }
        return subReturn;
    },
    nullChildYearFlatten : function(component, items) {
        const yearMap = component.get ('v.yearMap');
        let returnObj = {};
        items.forEach (ele => {
            const stYear = new Date (ele.Start_date__c).getFullYear ();
            if (yearMap.hasOwnProperty (stYear)) {
                ele.Actuals__c = ele.Actuals__c ? ele.Actuals__c : 0;
                ele.Volume__c = ele.Volume__c ? ele.Volume__c : 0;
                //ele['achieved%'] = ele.Volume__c ? (100 * (ele.Actuals__c / ele.Volume__c)).toFixed(2) : 0;
                ele['achieved%'] = (100 * (ele.Actuals__c / ele.Volume__c)).toFixed(2);
                ele.Total_Consumption__c = ele.Total_Consumption__c ? ele.Total_Consumption__c : 0;
                //ele['walletShare%'] = ele.Total_Consumption__c ? (100 * (ele.Actuals__c / ele.Total_Consumption__c)).toFixed(2) : 0;
                ele['walletShare%'] = (100 * (ele.Actuals__c / ele.Total_Consumption__c)).toFixed(2);
                returnObj[yearMap[stYear]] = ele;
            }
        });
        return returnObj;
    }
})