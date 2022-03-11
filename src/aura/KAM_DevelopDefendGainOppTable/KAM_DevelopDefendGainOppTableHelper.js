({
    doInit : function(component, event) {
        const items = component.get ('v.items');
        const tableId = '#' + component.get ('v.uniqueId') + '-develop-defend-gain-table';

        if (items && Object.keys(items).length === 0 && items.constructor === Object) {
            this.addNoDataRow (tableId);
        } else {
            for (const [key, value] of Object.entries(items)) {
                $(tableId).append (this.buidlTable (key, value));
            }
        }
    },
    addNoDataRow : function (tableId) {
        $(tableId).append ('<tbody class=""><tr><td colspan="12">' + $A.get ('$Label.c.KAM_No_Data_available_in_table') + '</td></tr></tbody>');
    },
    buidlTable : function (key, value) {
        let tr = '';
        let td = '';
        let tbody = '';

        let hasChildren = this.hasChildren (value);
        td = this.getHeadColumn (value.subCategories && Object.keys(value.subCategories).length > 0, key);
        td += this.addEmptyTd (2);
        td += this.getVolume (value);
        
        tr = '<tr>' + td + '</tr>';
        if (hasChildren) {
            let hasSubCategories = false;
            let subCatTable = '';
            if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                subCatTable = this.buildSubCategoryTable (value, false);
                hasSubCategories = true;
            }
            tr += '<tr class="hide">' + subCatTable + '</tr>';

            //tr += '<tr class="hide">' + this.buildSubCategoryTable (value.subCategories, false) + '</tr>';
        }
        tbody = '<tbody class="">' + tr + '</tbody>';

        return tbody;
    },
    createNullSubCatTable : function (tempTbody, numEmptyTd) {
        let htmlStr = this.addEmptyTd (numEmptyTd);
        htmlStr += '<td colspan="4" data-innertable="true">';
        htmlStr += '<table>';
        htmlStr += tempTbody;
        htmlStr += '</table>';
        htmlStr += '</td>';
        return htmlStr;
    },
    buildSubCategoryTable : function (items, isSubSub) {
        let tr = '';
        let td = '';
        let tbody = '';

        let htmlStr = this.addEmptyTd (1);
        htmlStr += '<td colspan="4" data-innertable="true">';
        htmlStr += '<table>';
        for (const [key, value] of Object.entries(items.subCategories)) {
            let hasChildren = this.hasChildren (value);
            td = this.getHeadColumn (this.showExpandButton (value), key);
            
            if (isSubSub) {
                td += this.getVolume (value);
            } else {
                td += this.addEmptyTd (1);
                td += this.getVolume (value);
            }

            tr = '<tr>' + td + '</tr>';
            if (hasChildren) {
                let hasSubCategories = false;
                let subCatTable = '';
                if (value.subCategories && Object.keys(value.subCategories).length > 0) {
                    subCatTable = this.buildSubCategoryTable (value, true);
                    hasSubCategories = true;
                }

                // if (value.nullSubCategoryChilds && value.nullSubCategoryChilds.length > 0) {
                //     let tempTd = '', tempTr='', tempTbody='';
        
                //     value.nullSubCategoryChilds.forEach (ele => {
                //         //if (!isSubSub) {
                //             tempTd = this.addEmptyTd (1);
                //         //}
                //         tempTd += this.getVolume (ele);
    
                //         tempTr = '<tr>' + tempTd + '</tr>';
                //         tempTbody += '<tbody class="">' + tempTr + '</tbody>';
                //     })
        
                //     if (hasSubCategories) {
                //         subCatTable +=  tempTbody;
                //     } else {
                //         subCatTable += this.createNullSubCatTable (tempTbody, 0);
                //     }
                // }
                tr += '<tr class="hide">' + subCatTable + '</tr>';

                //tr += '<tr class="hide">' + this.buildSubCategoryTable (value.subCategories, true) + '</tr>';
            }
            tbody = '<tbody class="">' + tr + '</tbody>';

            htmlStr += tbody;
        }

        if (items.nullSubCategoryChilds && items.nullSubCategoryChilds.length > 0) {
            let tempTd = '', tempTr='', tempTbody='';

            items.nullSubCategoryChilds.forEach (ele => {
                tempTd = this.addEmptyTd (isSubSub ? 1 : 2);
                tempTd += this.getVolume (ele);

                tempTr = '<tr>' + tempTd + '</tr>';
                tempTbody += '<tbody class="">' + tempTr + '</tbody>';
            })
            htmlStr += tempTbody;
        }
        htmlStr += '</table>';
        htmlStr += '</td>';
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
                td += '<td>' + (typeof value[ele] === 'undefined' ? '' :  new Intl.NumberFormat('en-IN', { }).format(value[ele])) + '</td>';    
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
            (value.hasOwnProperty ('nullSubCategoryChilds') && typeof value['nullSubCategoryChilds'] !== 'undefined' &&  (value['nullSubCategoryChilds']).length > 0 )
        )
    }, 
    getHeadColumn : function (hasChildren, key) {
        let td = '<td><div class="toggle-btn-container detail_toggle">';
        if (hasChildren) {
            td += '<a href="javascript:void(0)" data-toggle="oppLink" class="detail__operator-cta"></a>';
        }
        td += '<span>' + key + '</span></div></td>';
        return td;
    },
    columns : [
        'totalVolume',
        'wonVolume'
    ]
})