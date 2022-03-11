({
    updateDisplayList : function(component) {
        let currentIndex = component.get ('v.currentIndex');
        let pageSize = component.get ('v.pageSize');
        let items = component.get ('v.items');
        let displayedItems = items.slice(currentIndex, (currentIndex + pageSize));
        component.set ('v.displayedItems', displayedItems);

        component.set ('v.isPreviousBtnDisabled', currentIndex < pageSize);
        component.set ('v.isNextBtnDisabled', (currentIndex + pageSize) > items.length - 1);
    }
})