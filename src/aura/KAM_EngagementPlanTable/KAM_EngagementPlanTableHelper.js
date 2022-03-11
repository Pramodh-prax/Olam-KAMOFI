({
    updateMemberDetails : function(component) {
        let items = component.get ('v.items');
        if (items && items.length > 0) {
            items.forEach (ele => {
                if (ele.Attendee__c) {
                    let membersJSON = JSON.parse (ele.Attendee__c);

                    if (membersJSON && membersJSON.length > 0) {
                        let members = [];
                        membersJSON.forEach(element => {
                            members.push (element.title);
                        });

                        ele = Object.assign (ele, {members : members});
                    }
                }
            })
            component.set ('v.planLines', items);
        }
    }
})