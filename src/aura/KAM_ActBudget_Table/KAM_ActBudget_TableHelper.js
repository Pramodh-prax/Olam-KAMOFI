({
    doInit : function(component, event) {
        const items = component.get ('v.items');
        const tableId = '#' + component.get ('v.uniqueId') + '-act-budget-table';

        if (items && Object.keys(items).length === 0 && items.constructor === Object) {
            this.addNoDataRow (tableId);
        } else {
            for (const [key, value] of Object.entries(items)) {
                $(tableId).append (this.buidlTable (key, value));
            }
        }
    },
    addNoDataRow : function (tableId) {
        $(tableId).append ('<tbody class=""><tr><td colspan="13">' + $A.get ('$Label.c.KAM_No_Data_available_in_table') + '</td></tr></tbody>');
    },
    buidlTable : function (key, value) {
        let tr = '';
        let td = '';
        let tbody = '';

        let hasChildren = this.hasChildren (value);
        td = this.getHeadColumn (hasChildren, key);
        td += this.addEmptyTd (2);
        td += this.getCatSubTotal (value);
        
        tr = '<tr>' + td + '</tr>';
        if (hasChildren) {
            tr += '<tr class="hide">' + this.buildSubCategoryTable (value.subCategories, false) + '</tr>';
        }
        tbody = '<tbody class="">' + tr + '</tbody>';

        return tbody;
    },

    buildSubCategoryTable : function (items, isSubSub) {
        let tr = '';
        let td = '';
        let tbody = '';

        let htmlStr = this.addEmptyTd (1);
        htmlStr += '<td colspan="13" data-innertable="true">';
        htmlStr += '<table>';
        for (const [key, value] of Object.entries(items)) {
            let hasChildren = this.hasChildren (value);
            td = this.getHeadColumn (hasChildren, key);
            
            if (isSubSub) {
                td += this.getCatSubSubTotal (value);
            } else {
                td += this.addEmptyTd (1);
                td += this.getCatSubTotal (value);
            }

            tr = '<tr>' + td + '</tr>';
            if (hasChildren) {
                tr += '<tr class="hide">' + this.buildSubCategoryTable (value.subCategories, true) + '</tr>';
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
                        let val = colVal[eachCol];
                        if (Number.isNaN (Number (val))
                            || typeof colVal[eachCol] === 'undefined'
                        ) {
                            val = '-';
                        }
                        if((eachCol=='achieved%') ||(eachCol=='walletShare%')){
                            if(val=='-' || val=='Infinity'){
                                td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>'  }
                            else{
                            td += '<td>' +   Math.round(new Intl.NumberFormat('en-IN', { }).format(val)) +"%"+ '</td>'}
                        }else{
                            td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>'
                           }
                        //td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>';
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
                       if(val=='-' || val=='Infinity') {
                        td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>'   }
                        else{
                        td += '<td>' +   Math.round(new Intl.NumberFormat('en-IN', { }).format(val)) +"%"+ '</td>'}
                   }else{
                    td += '<td>' +  new Intl.NumberFormat('en-IN', { }).format(val) + '</td>' }
                });
            } else {
                eachCol.displayColumns.forEach (eachCol => {
                    td += this.addEmptyTd (1);
                });     
            }
        });
        return td;
    },
    getHeadColumn : function (hasChildren, key) {
        let td = '<td><div class="toggle-btn-container detail_toggle">';
        if (hasChildren) {
            td += '<a href="javascript:void(0)" data-toggle="budgetLink" class="detail__operator-cta"></a>';
        }
        td += '<div>' + key + '</div></div></td>';
        return td;
    },
    hasChildren : function (value) {
        return ( 
            (value.hasOwnProperty ('subCategories') && typeof value['subCategories'] !== 'undefined' &&  Object.keys (value['subCategories']).length > 0 )
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
    ]
})