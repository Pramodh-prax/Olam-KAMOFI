({
    doInit : function(component, event) {
        const items = component.get ('v.items');
        const tableId = '#' + component.get ('v.uniqueId') + '-develop-defend-gain-table-group';

        if (items && Object.keys(items).length === 0 && items.constructor === Object) {
            this.addNoDataRow (tableId);
        } else {
            let namesMap = component.get ('v.namesMap');
            for (const [key, value] of Object.entries(items)) {
                $(tableId).append (this.buidlTable (key, value, namesMap));
            }
        }
    },
    addNoDataRow : function (tableId) {
        $(tableId).append ('<tbody class=""><tr><td colspan="6">' + $A.get ('$Label.c.KAM_No_Data_available_in_table') + '</td></tr></tbody>');
    },
    buidlTable : function (key, value, namesMap) {
        let tr = '';
        let td = '';
        let tbody = '';

        let hasChildren = this.hasChildren (value);
        td = this.getHeadColumn (hasChildren, key, namesMap);
        td += this.addEmptyTd (3);
        td += this.getVolume (value);
        
        tr = '<tr>' + td + '</tr>';
        if (hasChildren) {
            let hasSubCategories = false;
            let subCatTable = '';
            if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                subCatTable = this.addEmptyTd (1);
                subCatTable += '<td colspan="5" data-innertable="true">';
                subCatTable += '<table>';
                subCatTable += this.buildSubCategoryTable (namesMap, value, false, 2);
                hasSubCategories = true;
            }

            if (value.nullSubCategoryChilds && Object.keys(value.nullSubCategoryChilds).length > 0) {
                let tempTd = '', tempTr='', tempTbody='';
                /*if (!hasSubCategories) {
                    subCatTable = this.addEmptyTd (1);   
                }*/
                for (const [accKey, accValue] of Object.entries(value.nullSubCategoryChilds)) {
                    if (accValue && Object.keys(accValue).length > 0) {
                        tempTd = this.addEmptyTd (2);
                        //tempTd = this.addEmptyTd (hasSubCategories ? 2 : 1);
    
                        tempTd += this.getHeadColumn (false, accKey, namesMap);
                        tempTd += this.getVolume (accValue);
            
                        tempTr += '<tr>' + tempTd + '</tr>';
                    }
                }
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
    createNullSubCatTable : function (tempTbody, numEmptyTd) {
        let htmlStr = this.addEmptyTd (numEmptyTd);
        htmlStr += '<td colspan="5" data-innertable="true">';
        htmlStr += '<table>';
        htmlStr += tempTbody;
        htmlStr += '</table>';
        htmlStr += '</td>';
        return htmlStr;
    },
    buildSubCategoryTable : function (namesMap, items, isSubSub, numOfEmptyTds) {
        let tr = '';
        let td = '';
        let tbody = '';

        let htmlStr = '';
        
       /* if (isSubSub) {
            for (const [key, value] of Object.entries(items.subCategories)) {
            let hasChildren = this.hasChildren (value);
            td = this.getHeadColumn (numOfEmptyTds ? hasChildren: false, key, namesMap);
            

            if (numOfEmptyTds) {
                td += this.addEmptyTd (numOfEmptyTds);
                td += this.getVolume (value);
            } else {
                td += this.getVolume (value);
            }

            

            tr = '<tr>' + td + '</tr>';
                 let subCatTable = '';
                if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                let tempTd = '', tempTr='', tempTbody='';
            	 for (const [accKey, accValue] of Object.entries(value.subCategories)) {
                 if (accValue && Object.keys(accValue).length > 0) {
                           tempTd = this.addEmptyTd (numOfEmptyTds);
        
                            tempTd += this.getHeadColumn (false, accKey, namesMap);
                            tempTd += this.getVolume (accValue);
                
                            tempTr += '<tr>' + tempTd + '</tr>';
                        }
                    }
                     tempTbody += '<tbody class="">' + tempTr + '</tbody>';
                     subCatTable += this.createNullSubCatTable (tempTbody, 1);
                    
                }
                  tr += '<tr class="hide">' + subCatTable + '</tr>';
                  tbody = '<tbody class="">' + tr + '</tbody>';

            htmlStr += tbody;
            
            
            }}
        // let htmlStr = this.addEmptyTd (1);
        // htmlStr += '<td colspan="5" data-innertable="true">';
        // htmlStr += '<table>';
        else{ */
            for (const [key, value] of Object.entries(items.subCategories)) {
            let hasChildren = this.hasChildren (value);
            td = this.getHeadColumn (numOfEmptyTds ? hasChildren: false, key, namesMap);
            

            if (numOfEmptyTds) {
                td += this.addEmptyTd (numOfEmptyTds);
                td += this.getVolume (value);
            } else {
                td += this.getVolume (value);
            }
            tr = '<tr>' + td + '</tr>';
                
            if (hasChildren && numOfEmptyTds) {
                let hasSubCategories = false;
                let subCatTable = '';
                if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                    subCatTable = this.addEmptyTd (1);
                    subCatTable += '<td colspan="5" data-innertable="true">';
                    subCatTable += '<table>';
                    subCatTable += this.buildSubCategoryTable (namesMap, value, true, numOfEmptyTds - 1);
                    subCatTable += '</table>';
                    hasSubCategories = true;
                }

                if (value.nullSubCategoryChilds && Object.keys(value.nullSubCategoryChilds).length > 0) {
                    let tempTd = '', tempTr='', tempTbody='';
        
                    for (const [accKey, accValue] of Object.entries(value.nullSubCategoryChilds)) {
                        if (accValue && Object.keys(accValue).length > 0) {
                            tempTd = this.addEmptyTd (numOfEmptyTds);
        
                            tempTd += this.getHeadColumn (false, accKey, namesMap);
                            tempTd += this.getVolume (accValue);
                
                            tempTr += '<tr>' + tempTd + '</tr>';
                        }
                    }
                    tempTbody += '<tbody class="">' + tempTr + '</tbody>';
        
                    if (hasSubCategories) {
                        subCatTable +=  tempTbody;
                        subCatTable += '</table>';
                        subCatTable += '</td>';
                    } else {
                        subCatTable += this.createNullSubCatTable (tempTbody, 0);
                    }
                }
         
                	//subCatTable += '</table>';
                    //subCatTable += '</td>';
                 tr += '<tr class="hide">' + subCatTable + '</tr>';
                }
            tbody = '<tbody class="">' + tr + '</tbody>';

            htmlStr += tbody;
            }
        // htmlStr += '</table>';
        // htmlStr += '</td>';
        return htmlStr;
        },
    addEmptyTd : function (numTimes) {
        let td = '';
        for (let index = 0; index < numTimes; index ++) {
            td += '<td></td>';
        }
        return td;
    },
    getVolume : function (value) {
        let td = '';
        this.columns.forEach (ele => {
            if (value.hasOwnProperty (ele)) {
                td += '<td>' + (typeof value[ele] === 'undefined' ? '' :new Intl.NumberFormat('en-IN', { }).format(value[ele])) + '</td>';    
            } else {
                td += this.addEmptyTd (1);
            }
        });
        return td;
    },
    showExpandButton : function (value) {
        return (value.subCategories && Object.keys(value.subCategories).length > 0) 
                || 
                ( value.nullSubCategoryChilds && value.nullSubCategoryChilds.length > 1);
    },
    hasChildren : function (value) {
        return ( 
            (value.hasOwnProperty ('subCategories') && typeof value['subCategories'] !== 'undefined' &&  Object.keys (value['subCategories']).length > 0 )
            ||
            (value.hasOwnProperty ('nullSubCategoryChilds') && typeof value['nullSubCategoryChilds'] !== 'undefined' &&  (Object.keys (value['nullSubCategoryChilds'])).length > 0 )
        )
    }, 
    getHeadColumn : function (hasChildren, key, namesMap) {
        let td = '<td><div class="toggle-btn-container detail_toggle">';
        if (hasChildren) {
            td += '<a href="javascript:void(0)" data-toggle="oppLink" class="detail__operator-cta"></a>';
        }
        td += '<span>' + this.getHeaderValue (key, namesMap) + '</span></div></td>';
        return td;
    },
    getHeaderValue : function (key, namesMap) {

        let sObjPrefix = '(';
        Object.values (this.sObjectPrefix).forEach (eachVal => {
            sObjPrefix += eachVal + "|";
        });
        if (Object.values (this.sObjectPrefix).length > 0) {
            sObjPrefix = this.replaceLast ('|', '', sObjPrefix);
        }
        sObjPrefix += ')';


        if (sObjPrefix === '()') {
            return key;
        } 

        let regEx = new RegExp( ('^' + sObjPrefix + '([a-zA-Z0-9]{12,15})' + '$'), 'gi');

        if (key.match (regEx) && namesMap.hasOwnProperty (key)) {
            return '<a href="/one/one.app?#/sObject/' + key + '/view" target="_blank">' + namesMap[key].name + '</a>';
            //return namesMap[key].name;
        } 
        return key;
    },
    sObjectPrefix : {
        account : '001'
    },
    replaceLast : function (find, replace, string) {
        var lastIndex = string.lastIndexOf(find);
        
        if (lastIndex === -1) {
            return string;
        }
        
        var beginString = string.substring(0, lastIndex);
        var endString = string.substring(lastIndex + find.length);
        
        return beginString + replace + endString;
    },
    columns : [
        'totalVolume',
        'wonVolume'
    ]
})