({
    initHelper : function(component){
        //console.log ('Parent init method is invoked')
    },
    toggleDetailContent : function(component) {
        $A.util.toggleClass(component.getConcreteComponent ().find ('item-wrapper'), 'accountoverview-detail__closed');
    },
    show : function(component) {
        $A.util.removeClass(component.find ('item-container'), 'slds-hide');
    },
})