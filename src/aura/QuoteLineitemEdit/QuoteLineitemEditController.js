({
    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");

        // Get the file name
        //uploadedFiles.forEach(file => console.log(file.name));
        
        var listOfContentDocIds = [];
        var obj = component.get("v.obj");
        
        if(uploadedFiles.length>0){
            uploadedFiles.forEach(file => listOfContentDocIds.push(file.documentId));
            //listOfContentDocIds.push(file.documentId);
            //var obj = component.get("v.obj"); 
            //var keyName = "isFileUploaded";
            obj["isFileUploaded"] = true;
            //component.set("v.obj",obj);
            //console.log('file.documentId: '+file.documentId);
        }
        obj["listOfContentDocIds"] = listOfContentDocIds;
        component.set("v.obj",obj);
        debugger;
    }
})