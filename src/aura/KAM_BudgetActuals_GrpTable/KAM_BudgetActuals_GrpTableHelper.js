({
    doInit : function(component, event) {
        const items = component.get ('v.items');
        const tableId = '#' + component.get ('v.uniqueId') + '-act-budget-table';

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
        $(tableId).append ('<tbody class=""><tr><td colspan="14">' + $A.get ('$Label.c.KAM_No_Data_available_in_table') + '</td></tr></tbody>');
    },
    buidlTable : function (key, value, namesMap) {
        let tr = '';
        let td = '';
        let tbody = '';

        let hasChildren = this.hasChildren (value);
        td = this.getHeadColumn (hasChildren, key, namesMap);
        td += this.addEmptyTd (3);
        td += this.getCatSubTotal (value);
        
        tr = '<tr>' + td + '</tr>';
        if (hasChildren) {
            let hasSubCategories = false;
            let subCatTable = '';
            if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                subCatTable = this.buildSubCategoryTable (namesMap, value, false, 2)
                hasSubCategories = true;
            }

            if (value.nullSubCategoryChilds && Object.keys(value.nullSubCategoryChilds).length > 0) {
                let tempTd = '', tempTr='', tempTbody='';
    
                for (const [accKey, accValue] of Object.entries(value.nullSubCategoryChilds)) {
                    if (accValue && Object.keys(accValue).length > 0) {
                        tempTd = this.addEmptyTd (hasSubCategories ? 3 : 2);
    
                        tempTd += this.getHeadColumn (false, accKey, namesMap);
                        tempTd += this.getCatSubSubTotal (accValue);
            
                        tempTr = '<tr>' + tempTd + '</tr>';
                        tempTbody += '<tbody class="">' + tempTr + '</tbody>';
                    }
                }
    
                if (hasSubCategories) {
                    subCatTable +=  tempTbody;
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
        htmlStr += '<td colspan="14" data-innertable="true">';
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

        let htmlStr = this.addEmptyTd (1);
        htmlStr += '<td colspan="14" data-innertable="true">';
        htmlStr += '<table>';
        for (const [key, value] of Object.entries(items.subCategories)) {
            let hasChildren = this.hasChildren (value);
            td = this.getHeadColumn (hasChildren, key, namesMap);
            
            if (numOfEmptyTds) {
                td += this.addEmptyTd (numOfEmptyTds);
                td += this.getCatSubTotal (value);
            } else {
                td += this.getCatSubSubTotal (value);
            }
            
            tr = '<tr>' + td + '</tr>';
            if (hasChildren) {

                let hasSubCategories = false;
                let subCatTable = '';
                if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                    subCatTable = this.buildSubCategoryTable (namesMap, value, true, numOfEmptyTds - 1);
                    hasSubCategories = true;
                }

                if (value.nullSubCategoryChilds && Object.keys(value.nullSubCategoryChilds).length > 0) {
                    let tempTd = '', tempTr='', tempTbody='';
        
                    for (const [accKey, accValue] of Object.entries(value.nullSubCategoryChilds)) {
                        if (accValue && Object.keys(accValue).length > 0) {
                            tempTd = this.addEmptyTd (numOfEmptyTds);
        
                            tempTd += this.getHeadColumn (false, accKey, namesMap);
                            tempTd += this.getCatSubSubTotal (accValue);
                
                            tempTr = '<tr>' + tempTd + '</tr>';
                            tempTbody += '<tbody class="">' + tempTr + '</tbody>';
                        }
                    }
        
                    if (hasSubCategories) {
                        subCatTable +=  tempTbody;
                    } else {
                        subCatTable += this.createNullSubCatTable (tempTbody, 0);
                    }
                }
                tr += '<tr class="hide">' + subCatTable + '</tr>';

            }
            tbody = '<tbody class="">' + tr + '</tbody>';

            htmlStr += tbody;
        }
        htmlStr += '</table>';
        htmlStr += '</td>';
        return htmlStr;
    },
    getCatSubTotal : function (value) {
        let td = '';
        if (value.hasOwnProperty ('subTotal')) {
            const subTotal = value['subTotal'];

            this.columns.forEach (eachCol => {
                if (typeof subTotal[eachCol.key] !== 'undefined' && subTotal[eachCol.key] !== null) {
                    const colVal = subTotal[eachCol.key];
                    eachCol.displayColumns.forEach (eachCol => {
                        let val = colVal[eachCol] ;
                        if (Number.isNaN (Number (val))
                            || typeof colVal[eachCol] === 'undefined'
                        ) {
                            val = '-';
                        }
                        if((eachCol=='achieved%') ||(eachCol=='walletShare%')){
                            if(val=='-' || val=='Infinity'){
                                td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>'  }
                            else{
                            
                            td += '<td>' +  Math.round((new Intl.NumberFormat('en-IN', { }).format(val))) +"%"+ '</td>';}
                        }else{
                            td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>'
                           }
                       
                        //td += '<td>' + (typeof colVal[eachCol] === 'undefined' ? '' : colVal[eachCol]) + '</td>';
                    });
                } else {
                    eachCol.displayColumns.forEach (eachCol => {
                        td += this.addEmptyTd (1);
                    });     
                }
            })
        } else {
            td += this.addEmptyTd (9);
        }
        return td;
    },
    getCatSubSubTotal : function (value) {
        let td = '';
        this.columns.forEach (eachCol => {
            if (typeof value[eachCol.key] !== 'undefined' && value[eachCol.key] !== null) {
                const colVal = value[eachCol.key];
                eachCol.displayColumns.forEach (eachCol => {
                    let val = colVal[eachCol] ;
                    if (Number.isNaN (Number (val))
                        || typeof colVal[eachCol] === 'undefined'
                    ) {
                        val = '-';
                    }
                    if((eachCol=='achieved%') ||(eachCol=='walletShare%')){
                        if(val=='-' || val=='Infinity'){
                            td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>'  }
                        else{
                        td += '<td>' +  Math.round(new Intl.NumberFormat('en-IN', { }).format(val)) +"%"+ '</td>';}
                    }else{
                        td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>'
                       }

                    //td += '<td>' + (typeof colVal[eachCol] === 'undefined' ? '' : colVal[eachCol]) + '</td>';
                });
            } else {
                eachCol.displayColumns.forEach (eachCol => {
                    td += this.addEmptyTd (1);
                });     
            }
        });
        return td;
    },
    getHeadColumn : function (hasChildren, key, namesMap) {
        let td = '<td><div class="toggle-btn-container detail_toggle">';
        if (hasChildren) {
            td += '<a href="javascript:void(0)" data-toggle="budgetLink" class="detail__operator-cta"></a>';
        }
        td += '<div>' + this.getHeaderValue (key, namesMap) + '</div></div></td>';
        return td;
    },
    hasChildren : function (value) {
        return ( 
            (value.hasOwnProperty ('subCategories') && typeof value['subCategories'] !== 'undefined' &&  Object.keys (value['subCategories']).length > 0 )
            ||
            (value.hasOwnProperty ('nullSubCategoryChilds') && typeof value['nullSubCategoryChilds'] !== 'undefined' &&  Object.keys (value['nullSubCategoryChilds']).length > 0 )
        )
    }, 
    addEmptyTd : function (numTimes) {
        let td = '';
        for (let index = 0; index < numTimes; index ++) {
            td += '<td></td>';
        }
        return td;
    },
    columns : [
        {
            key : '1stYear', 
            displayColumns : ['Volume__c', 'Actuals__c']
        },
        {
            key : '2ndYear', 
            displayColumns : ['Volume__c', 'Actuals__c']
        },
        {
            key : '3rdYear', 
            displayColumns : ['Volume__c', 'Actuals__c']
        },
        
        {
            key : 'currentYear', 
            displayColumns : ['Volume__c', 'Actuals__c', 'achieved%', 'walletShare%']
        }
    ],
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
    }
})