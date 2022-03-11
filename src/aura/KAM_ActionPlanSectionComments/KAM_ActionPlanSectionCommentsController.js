({
    doInit : function(component, event, helper) {
        //component.set ('v.latestComments', component.get ('v.comments'));
    },
    updateLocalComments : function(component, event, helper) {
        component.set ('v.latestComments', component.get ('v.comments'));
    },
    updateCommentVar : function(component, event, helper) {
        component.set ('v.latestComments', event.target.value);
    },
    onEditBtnClicked : function(component, event, helper) {
        component.set ('v.isEditing', true);
    },
    onSaveBtnClicked : function(component, event, helper) {
        component.set ('v.isEditing', false);
        helper.fireSaveCommentEvent (component, component.get ('v.identifier'), component.get ('v.comments'),  component.get ('v.latestComments'));
        component.set ('v.comments', component.get ('v.latestComments'));
    },
    onCancelBtnClicked : function(component, event, helper) {
        component.set ('v.isEditing', false);
        component.set ('v.latestComments', component.get ('v.comments'));
    },
})