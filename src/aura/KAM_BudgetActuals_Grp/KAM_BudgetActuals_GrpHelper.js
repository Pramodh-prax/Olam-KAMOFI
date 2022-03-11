({
    NUMBER_OF_PREVIOUS_YEARS : 3,
    YEAR_MAP_VALUES : ["1stYear", "2ndYear", "3rdYear", "currentYear"],
    setYearDetails : function (component) {
        let sectionData = component.get ('v.sectionData');

        const currentYear = Number (sectionData.accountPlan.Year__c) || new Date().getFullYear ();  

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

    },
    doInit : function (component, event) {
        component.set ('v.isLoading', true);

        this.setYearDetails (component);

        let sectionData = component.get ('v.sectionData');

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
 
 				let yearsArray = Array.from (component.get ('v.years'));
				yearsArray.push (component.get ('v.currentYear'));
				let params = {
                    accIdStr : JSON.stringify (accIds),
                    accountPlanStr : JSON.stringify (Object.assign (sectionData.accountPlan, {attributes : undefined})),
                    yearsStr : JSON.stringify (yearsArray)
                };

                return this.invokeApex (component, 'c.getGroupOverAllBudgets', params)
            })
        ).then (
            $A.getCallback(results => {
                component.set ('v.overAllBudgets', undefined);

                let allAccountItems = [];

                let namesMap = {};
                if (results && results.length > 0) {
            
            		results.forEach (ele => {
                      	if (!namesMap.hasOwnProperty (ele.Account__c)) {
                        	namesMap[ele.Account__c] = {name : ele.Account__r.Name}
                       	}
                        if (ele.Budget_vs_Actual_Lines__r && ele.Budget_vs_Actual_Lines__r.length > 0) {
							ele.Budget_vs_Actual_Lines__r.forEach (item => {
                            	item = Object.assign (item, 
                                	{
                                            'Start_date__c' : ele.Start_date__c,
                                            'Account__c' : ele.Account__c
                                	}
								);
                             })
                             allAccountItems = allAccountItems.concat (ele.Budget_vs_Actual_Lines__r);
						}                        
    				});
                    component.set ('v.result', JSON.stringify(allAccountItems));
                    this.updateVolumeBasedOnUnitOfMeasure (component, allAccountItems, component.get ('v.selectedUnitOfMeasure'));
                  //  this.createTabularData (component, allAccountItems); 
                }
                component.set ('v.namesMap', namesMap);
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
                   
                    Volume__c : self.recalculateVoume (component, ele.Volume__c, selectedUnitOfMeasure),
                    Actuals__c :self.recalculateVoume (component, ele.Actuals__c, selectedUnitOfMeasure),
                    Total_Consumption__c:self.recalculateVoume (component, ele.Total_Consumption__c, selectedUnitOfMeasure)
                }
            );
        });
        this.createTabularData (component, result); 
    },
    createTabularData : function (component, records) {
        component.set ('v.overAllBudgets', undefined);
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
                        for (const [eKey, eValue] of Object.entries(nValue.subTotal)) {
                                    
                            let tempObj = subsubTotal.hasOwnProperty(eKey) ? subsubTotal[eKey] : {Actuals__c : 0, Volume__c: 0, Total_Consumption__c : 0};
                            
                            tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c + Number (eValue.Actuals__c) : Number (eValue.Actuals__c);
                            tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c + Number (eValue.Volume__c) : Number (eValue.Volume__c);		
                            //tempObj['achieved%'] = tempObj.Volume__c ? (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2) : 0;
                            tempObj['achieved%'] = (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2);
                            tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c + Number (eValue.Total_Consumption__c) : Number (eValue.Total_Consumption__c);		    
                            //tempObj['walletShare%'] = tempObj.Total_Consumption__c ? (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2) : 0;
                            tempObj['walletShare%'] = (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2);
                            subsubTotal[eKey] = tempObj;
                        }
                    }
                        
                    for (const [acKey, acValue] of Object.entries(children[k].nullSubCategoryChilds)) {
                        for (const [nKey, nValue] of Object.entries(acValue)) {
                            let tempObj = subsubTotal.hasOwnProperty(nKey) ? subsubTotal[nKey] : {Actuals__c : 0, Volume__c: 0, Total_Consumption__c : 0};
                            tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c : 0;
                            tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c : 0;
                            tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c : 0;     
                            tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c + Number (nValue.Actuals__c) : Number (nValue.Actuals__c);
                            tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c + Number (nValue.Volume__c) : Number (nValue.Volume__c);		
                            //tempObj['achieved%'] = tempObj.Volume__c ? (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2) : 0;
                            tempObj['achieved%'] = (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2);
                            tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c + Number (nValue.Total_Consumption__c) : Number (nValue.Total_Consumption__c);		
                            //tempObj['walletShare%'] = tempObj.Total_Consumption__c ? (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2) : 0;
                            tempObj['walletShare%'] =  (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2);
                            subsubTotal[nKey] = tempObj;
                        }
                    }
                    children[k].subTotal = subsubTotal;
                }
                
                tempObj.subCategories = children;
            
                
                Object.values (tempObj.subCategories).forEach (el => {
                    const ele = el.subTotal;
                    
                    for (const [eKey, eValue] of Object.entries(el.subTotal)) {
                            
                        let tempObj = subTotal.hasOwnProperty(eKey) ? subTotal[eKey] : {Actuals__c : 0, Volume__c: 0, Total_Consumption__c : 0};
                           
                        tempObj.Actuals__c = tempObj.Actuals__c ? tempObj.Actuals__c + Number (eValue.Actuals__c) : Number (eValue.Actuals__c);
                        tempObj.Volume__c = tempObj.Volume__c ? tempObj.Volume__c + Number (eValue.Volume__c) : Number (eValue.Volume__c);		
                        //tempObj['achieved%'] = tempObj.Volume__c ? (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2) : 0;
                        tempObj['achieved%'] = (100 * (tempObj.Actuals__c / tempObj.Volume__c)).toFixed(2);
                        tempObj.Total_Consumption__c = tempObj.Total_Consumption__c ? tempObj.Total_Consumption__c + Number (eValue.Total_Consumption__c) : Number (eValue.Total_Consumption__c);		     
                        //tempObj['walletShare%'] = tempObj.Total_Consumption__c ? (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2) : 0;
                        tempObj['walletShare%'] = (100 * (tempObj.Actuals__c / tempObj.Total_Consumption__c)).toFixed(2);
                        subTotal[eKey] = tempObj;
                    }
                });
            }
            tempObj.nullSubCategoryChilds = self.nullChildYearFlatten(component, value.nullSubCategoryChilds);

            for (const [acKey, acValue] of Object.entries(tempObj.nullSubCategoryChilds)) {
                for (const [nKey, nValue] of Object.entries(acValue)) {
            
                    let tempObj = subTotal.hasOwnProperty(nKey) ? subTotal[nKey] : {Actuals__c : 0, Volume__c: 0, Total_Consumption__c : 0};
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
            }
            
            tempObj.subTotal = subTotal;  
            resultMap[key] = tempObj;
        }
        component.set ('v.overAllBudgets', resultMap);
        component.set ('v.isUnitOfMeasureDisabled', (!resultMap || (resultMap && Object.keys(resultMap).length === 0 && resultMap.constructor === Object))) ;
        //console.log ('resultMap :' + JSON.stringify (resultMap));
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
            
            let accKeyObj = {};
            cValue.children.forEach (ele => {
                if (accKeyObj.hasOwnProperty (ele.Account__c)) {
                    accKeyObj[ele.Account__c].children.push (ele);
                } else {
                    accKeyObj[ele.Account__c] = {children : [ele]};
                }
            })

            let returnObj = {};
            let subsubTotal = {};
            for (const [accKey, accValue] of Object.entries(accKeyObj)) {
                let yearMappedEle = {};
                accValue.children.forEach (ele => {
                    const stYear = new Date (ele.Start_date__c).getFullYear ();
                    if (yearMap.hasOwnProperty (stYear)) {
                        ele.Actuals__c = ele.Actuals__c ? ele.Actuals__c : 0;
                        ele.Volume__c = ele.Volume__c ? ele.Volume__c : 0;
                        //ele['achieved%'] = ele.Volume__c ? (100 * (ele.Actuals__c / ele.Volume__c)).toFixed(2) : 0;
                        ele['achieved%'] = (100 * (ele.Actuals__c / ele.Volume__c)).toFixed(2);
                        ele.Total_Consumption__c = ele.Total_Consumption__c ? ele.Total_Consumption__c : 0;
                        //ele['walletShare%'] = ele.Total_Consumption__c ? (100 * (ele.Actuals__c / ele.Total_Consumption__c)).toFixed(2) : 0;
                        ele['walletShare%'] = (100 * (ele.Actuals__c / ele.Total_Consumption__c)).toFixed(2);
                        yearMappedEle[yearMap[stYear]] = ele;


                        let susSubObj = subsubTotal.hasOwnProperty(yearMap[stYear]) ? subsubTotal[yearMap[stYear]] : {Actuals__c : 0, Volume__c: 0, 'achieved%' : 0};

                        susSubObj.Actuals__c = susSubObj.Actuals__c ? susSubObj.Actuals__c : 0;
                        susSubObj.Volume__c = susSubObj.Volume__c ? susSubObj.Volume__c : 0;
                        susSubObj.Total_Consumption__c = susSubObj.Total_Consumption__c ? susSubObj.Total_Consumption__c : 0;

                        susSubObj.Actuals__c = susSubObj.Actuals__c ? susSubObj.Actuals__c + Number (ele.Actuals__c) : Number (ele.Actuals__c);
                        susSubObj.Volume__c = susSubObj.Volume__c ? susSubObj.Volume__c + Number (ele.Volume__c) : Number (ele.Volume__c);		
                        //susSubObj['achieved%'] = susSubObj.Volume__c ? (100 * (susSubObj.Actuals__c / susSubObj.Volume__c)).toFixed(2) : 0;
                        susSubObj['achieved%'] = (100 * (susSubObj.Actuals__c / susSubObj.Volume__c)).toFixed(2);
                        susSubObj.Total_Consumption__c = susSubObj.Total_Consumption__c ? susSubObj.Total_Consumption__c + Number (ele.Total_Consumption__c) : Number (ele.Total_Consumption__c);		
                        //susSubObj['walletShare%'] = susSubObj.Total_Consumption__c ? (100 * (susSubObj.Actuals__c / susSubObj.Total_Consumption__c)).toFixed(2) : 0;
                        susSubObj['walletShare%'] = (100 * (susSubObj.Actuals__c / susSubObj.Total_Consumption__c)).toFixed(2);
                        subsubTotal[yearMap[stYear]] = susSubObj;
                    }
                })
                returnObj [accKey] = yearMappedEle
            }
            subReturn [cKey ? cKey : 'no_subSubCat'] = {
                subCategories :returnObj,
                subTotal : subsubTotal
            };
        }
        return subReturn;
    },
    nullChildYearFlatten : function(component, items) {

        let accKeyObj = {};
        items.forEach (ele => {
            if (accKeyObj.hasOwnProperty (ele.Account__c)) {
                accKeyObj[ele.Account__c].children.push (ele);
            } else {
                accKeyObj[ele.Account__c] = {children : [ele]};
            }
        })

        const yearMap = component.get ('v.yearMap');
        let returnObj = {};
        for (const [accKey, accValue] of Object.entries(accKeyObj)) {
            let yearMappedEle = {};
            accValue.children.forEach (ele => {
                const stYear = new Date (ele.Start_date__c).getFullYear ();
                if (yearMap.hasOwnProperty (stYear)) {
                    ele.Actuals__c = ele.Actuals__c ? ele.Actuals__c : 0;
                    ele.Volume__c = ele.Volume__c ? ele.Volume__c : 0;
                    //ele['achieved%'] = ele.Volume__c ? (100 * (ele.Actuals__c / ele.Volume__c)).toFixed(2) : 0;
                    ele['achieved%'] = (100 * (ele.Actuals__c / ele.Volume__c)).toFixed(2);
                    ele.Total_Consumption__c = ele.Total_Consumption__c ? ele.Total_Consumption__c : 0;
                    //ele['walletShare%'] = ele.Total_Consumption__c ? (100 * (ele.Actuals__c / ele.Total_Consumption__c)).toFixed(2) : 0;
                    ele['walletShare%'] = (100 * (ele.Actuals__c / ele.Total_Consumption__c)).toFixed(2);
                    yearMappedEle[yearMap[stYear]] = ele;
                }
            })
            returnObj [accKey] = yearMappedEle
        }
        return returnObj;
    }
})