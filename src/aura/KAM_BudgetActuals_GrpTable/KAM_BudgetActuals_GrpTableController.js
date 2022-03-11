({
    scriptLoaded : function(component, event, helper) {
        helper.doInit (component, event);

        $('[data-toggle="budgetLink"]').click(function(){
            $(this).parent().toggleClass ('detail_toggle');
            $(this).parent().parent().parent().next('tr.hide').toggle();
        });
    },
    doInit : function(component, event, helper) {
        const labels = {
            noData: $A.get ('$Label.c.KAM_No_Data_available_in_table'),
            category : $A.get ('$Label.c.KAM_Budget_Table_Header_Category'),
            subcategory : $A.get ('$Label.c.KAM_Budget_Table_Header_Sub_Category'),
            subcategory2 : $A.get ('$Label.c.KAM_Budget_Table_Header_Sub_Category_2'),
            achieved : $A.get ('$Label.c.KAM_Budget_Table_Header_Achieved'),
            budget : $A.get ('$Label.c.KAM_Budget_Table_Header_Budget'),
            actual : $A.get ('$Label.c.KAM_Budget_Table_Header_Actuals'),
            account : $A.get ('$Label.c.KAM_Budget_Table_Header_Account'),
            walletShare : $A.get ('$Label.c.KAM_Budget_Table_Header_Wallet_Share')
        };
        component.set ('v.labels', labels);
    }
})