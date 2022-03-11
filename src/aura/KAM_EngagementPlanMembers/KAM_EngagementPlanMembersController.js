({
    doInit : function(component, event, helper) {
        let membersJSON = JSON.parse (component.get ('v.membersJSON'));
        if (membersJSON && membersJSON.length > 0) {
            let members = [];
            membersJSON.forEach(element => {
                members.push (element.title);
            });
            component.set ('v.members', members);
        }
    }
})