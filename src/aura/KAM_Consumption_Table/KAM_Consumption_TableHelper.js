({
    getConsumptions : function (component) {
        $('[data-toggle="togglelink"').click(function () {
                    $(this).parent().toggleClass('detail_toggle');
                    $(this).parent().parent().parent().next('tr.hide').toggle();
                });

        const items = component.get ('v.items');
        if (items && Object.keys(items).length === 0 && items.constructor === Object) {
            this.addNoDataRow (component);
        } else {
            for (const [key, value] of Object.entries(items)) {
                $('#'+component.get('v.uniqueId')+'-act-Consumption-table').append (this.buidlTable (key, value,component));
            }
        }  
    },
    addNoDataRow : function (component) {
        $('#'+component.get('v.uniqueId')+'-act-Consumption-table').append ('<tbody class=""><tr><td colspan="12">No data available in the table</td></tr></tbody>');
    },
    buidlTable: function (key, value,component) {
        let td = '';
        let tr = '';
        let tbody = '';
		let PlanType = component.get('v.PlanType');
        let hasChildren = this.hasChildren(value);
        td = this.getHeadColumn (hasChildren, key);
        td += this.addEmptyTd (2);
        td += '<td>' + (value.Volume_MT__c ? value.Volume_MT__c : '') + '</td>';
        td += this.addEmptyTd(PlanType === 'Group' ? 3 : 2 );
        
        tr += '<tr>' + td + '</tr>';
        let self = this;
        if (hasChildren) {
			let hasSubCategories = false;
            let subCatTable = '';
            if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                subCatTable = this.addEmptyTd (1);
                subCatTable += '<td colspan="' + (PlanType === 'Group' ? 6 : 5) + '" data-innertable="true">';
                subCatTable += '<table>';
                subCatTable += this.buildSubCategoryTable (value, 1, PlanType, false);
                hasSubCategories = true;
            }

            if (value.nullSubCategoryChilds && Object.keys(value.nullSubCategoryChilds).length > 0) {
                let tempTd = '', tempTr='', tempTbody='';
    			
                if (!hasSubCategories) {
                 	subCatTable = this.addEmptyTd (1);   
                }
                
                value.nullSubCategoryChilds.forEach (item => {
                    tempTd = this.addEmptyTd (hasSubCategories ? 2 : 1);
                    
                    self.fields.forEach(ele => {
                        tempTd += '<td>' + (item[ele] ? item[ele] : '') + '</td>';
                    });
                    if(PlanType=='Group'){
                        tempTd += '<td><a href="/one/one.app?#/sObject/'+ item.Account__c +'/view"  target="blank">'+ item.Account__r.Name +'</a>'+'</td>';
                    }
                    tempTr += '<tr>' + tempTd + '</tr>';
                })
                tempTbody += '<tbody class="">' + tempTr + '</tbody>';
                if (hasSubCategories) {
                    subCatTable +=  tempTbody;
                    subCatTable += '</table>';
                    subCatTable += '</td>';
                } else {
                    subCatTable += this.createNullSubCatTable (tempTbody, 1);
                }
            }
        	tr += '<tr class="hide">' + subCatTable + '</tr>';
        } 
       	tbody = '<tbody class="">' + tr + '</tbody>';

        return tbody;
    },
    createNullSubCatTable : function (tempTbody, numEmptyTd, PlanType) {
            let htmlStr = this.addEmptyTd (numEmptyTd);
            htmlStr += '<td colspan="' + (PlanType === 'Group' ? 6 : 5) + '" data-innertable="true">';
            htmlStr += '<table>';
            htmlStr += tempTbody;
            htmlStr += '</table>';
            htmlStr += '</td>';
            return htmlStr;
    },
	buildSubCategoryTable: function (items, numOfEmptyTds, PlanType, isSubSubTab) {
    	let tr = '';
        let td = '';
        let tbody = '';

        let htmlStr = '';  
        let self = this;
        
        if (isSubSubTab) {
            for (const [key, value] of Object.entries(items.subCategories)) {
                let hasChildren = this.hasChildren (value);
                td = this.getHeadColumn (hasChildren , key);
                
                self.fields.forEach(ele => {
                    td += '<td>' + (value[ele] ? value[ele] : '') + '</td>';
                });
                if(PlanType=='Group'){
                    if (value.Account__c) {
                        td += '<td><a href="/one/one.app?#/sObject/'+ value.Account__c +'/view"  target="blank">'+ value.Account__r.Name +'</a>'+'</td>';   
                    } else {
                        td += '<td></td>';
                    }
                }
                
                tr = '<tr>' + td + '</tr>';
                let subCatTable = '';
                if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                    let tempTd = '', tempTr='', tempTbody='';
                    
                    value.subCategories.children.forEach (item => {
                        tempTd = '';
                        self.fields.forEach(ele => {
                            tempTd += '<td>' + (item[ele] ? item[ele] : '') + '</td>';
                        });
                        if(PlanType=='Group'){
                            if (item.Account__c){
                                tempTd += '<td><a href="/one/one.app?#/sObject/'+ item.Account__c +'/view"  target="blank">'+ item.Account__r.Name +'</a>'+'</td>';
                            } else {
                                tempTd += '<td></td>';
                            }
                        }
                        tempTr += '<tr>' + tempTd + '</tr>';
                	})
                	tempTbody += '<tbody class="">' + tempTr + '</tbody>';
					subCatTable += this.createNullSubCatTable (tempTbody, 1);                
            	}
            	tr += '<tr class="hide">' + subCatTable + '</tr>';
                
                
                tbody = '<tbody class="">' + tr + '</tbody>';
                htmlStr += tbody;
            }
        } else {
         	for (const [key, value] of Object.entries(items.subCategories)) {
                let hasChildren = this.hasChildren (value);
                td = this.getHeadColumn (hasChildren , key);
                
                if (numOfEmptyTds) {
                    td += this.addEmptyTd (numOfEmptyTds);
                }
                self.fields.forEach(ele => {
                    td += '<td>' + (value[ele] ? value[ele] : '') + '</td>';
                });
                if(PlanType=='Group'){
                    if (value.Account__c) {
                        td += '<td><a href="/one/one.app?#/sObject/'+ value.Account__c +'/view"  target="blank">'+ value.Account__r.Name +'</a>'+'</td>';   
                    } else {
                        td += '<td></td>';
                    }
                }
                
                tr = '<tr>' + td + '</tr>';
                if (hasChildren) {
                    let hasSubCategories = false;
                    let subCatTable = '';
                    
                    if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                        subCatTable = this.addEmptyTd (1);
                        subCatTable += '<td colspan="' + (PlanType === 'Group' ? 6 : 5) + '" data-innertable="true">';
                        subCatTable += '<table>';
                        subCatTable += this.buildSubCategoryTable (value, numOfEmptyTds - 1, PlanType, true);
                        subCatTable += '</table>';
                         subCatTable += '</td>';
                        hasSubCategories = true;
                    }
                    
                    if (value.nullSubCategoryChilds && Object.keys(value.nullSubCategoryChilds).length > 0) {
                        let tempTd = '', tempTr='', tempTbody='';
            
                        value.nullSubCategoryChilds.forEach (item => {
                            tempTd = this.addEmptyTd (numOfEmptyTds);
                            
                            self.fields.forEach(ele => {
                                tempTd += '<td>' + (item[ele] ? item[ele] : '') + '</td>';
                            });
                            if(PlanType=='Group'){
                                if (item.Account__c){
                                    tempTd += '<td><a href="/one/one.app?#/sObject/'+ item.Account__c +'/view"  target="blank">'+ item.Account__r.Name +'</a>'+'</td>';
                                } else {
                                    tempTd += '<td></td>';
                                }
                            }
                            tempTr += '<tr>' + tempTd + '</tr>';
                        })
                        tempTbody += '<tbody class="">' + tempTr + '</tbody>';
            
                        if (hasSubCategories) {
                            subCatTable +=  tempTbody;
                            subCatTable += '</table>';
                            subCatTable += '</td>';
                        } else {
                            subCatTable += this.createNullSubCatTable (tempTbody, 1);
                        }
                    }
                    tr += '<tr class="hide">' + subCatTable + '</tr>';
                }
                tbody = '<tbody class="">' + tr + '</tbody>';
                
                htmlStr += tbody;
            }   
        }
        return htmlStr;
    },
    addEmptyTd : function (numTimes) {
        let td = '';
        for (let index = 0; index < numTimes; index ++) {
            td += '<td></td>';
        }
        return td;
    },
    getHeadColumn : function (hasChildren, key) {
        let td = '<td><div class="toggle-btn-container detail_toggle">';
        if (hasChildren) {
            td += '<a href="javascript:void(0)" data-toggle="togglelink" class="detail__operator-cta"></a>';
        }
        td += '<span>' + key + '</span></div></td>';
        
        return td;
    },
	hasChildren : function (value) {
        return ( 
            (value.hasOwnProperty ('subCategories') && typeof value['subCategories'] !== 'undefined' &&  Object.keys (value['subCategories']).length > 0 )
            ||
            (value.hasOwnProperty ('nullSubCategoryChilds') && typeof value['nullSubCategoryChilds'] !== 'undefined' &&  (Object.keys (value['nullSubCategoryChilds'])).length > 0 )
        )
    },     
  	fields : [
    	'Volume_MT__c',
    	'Application__c',
    	'Brands__c'
    ]
})