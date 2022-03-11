({
    scriptLoaded : function(component, event, helper) {
        if (component.get ('v.items')) {
            let items = [];
            helper.createTree (component, component.get ('v.items')).forEach (ele => {
                items.push (helper.renderList(component, ele));
            })
            helper.appendToDom (component, items);
        }
    },
})