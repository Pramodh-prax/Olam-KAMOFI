({
    fireSaveCommentEvent : function(cmp, identifier, oldComment, newComment) {
        let compEvent = cmp.getEvent("saveCommentEvent");
        if (compEvent) {
            compEvent.setParams({"identifier" : identifier, "oldComment" : oldComment, "newComment" : newComment, "compRef" : cmp});
            compEvent.fire();
        } else {
            alert ('Unable to save your comments !!');
        }
    }
})