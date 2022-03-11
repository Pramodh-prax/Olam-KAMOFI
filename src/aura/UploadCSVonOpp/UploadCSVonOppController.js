({    
    doinit : function(component, event, helper) {
        console.log('Aura Component Loaded');
        var oppid = component.get("v.recordId");
        console.log('oppid in Helper:' + oppid);
        var action = component.get('c.CheckPriceBook');    
        action.setParams({
            
            OppId : oppid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var checkResult = response.getReturnValue();
            console.log('checkResult:'+checkResult);
            console.log('state value:'+state);
            if (response.getState() == "SUCCESS") { 
                if(checkResult == "SUCCESS"){
                    component.set("v.showUpload", true);
                }
                
                else if (checkResult == "ERROR") {
                    component.set("v.errorMessage",'Please select Pricebook before uploading tender sheet.');
                    component.set("v.isError",true);
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
    },
    CreateRecord: function (component, event, helper) {
        component.set("v.showUploadButton", false);
        var fileInput = component.find("file").getElement();
        console.log('fileInput:'+fileInput);
        var file = fileInput.files[0];
        
        console.log('alert(file):'+file);//alert(file);
        if (file){
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                
                console.log("EVT FN");
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component,csv);
                //var result1 = helper.xlsx2JSON(component,csv);
                console.log('Result:'+result);
                helper.CreateProduct(component,result);
                
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
        }   
    },
    insertProducstsData : function (component, event, helper) {
        component.set("v.showUploadButton", false);
        component.set("v.showUpload", false);
        
        //component.set("v.counter",0);
        //component.set("v.progress",0);
        //component.set("v.totalRecordCount",0);
        var fileInput = component.find("file").getElement();
        console.log('fileInput:'+fileInput);
        var file = fileInput.files[0];
        
        console.log('alert(file):'+file);//alert(file);
        if (file){
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                
                console.log("EVT FN");
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component,csv);
                //var result1 = helper.xlsx2JSON(component,csv);
                console.log('Result:'+result);
                helper.insertProductsData(component,result);
                
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
        }   
    },
    
    //for close cross functionality
    closeModelCreateRFI: function(component, event, helper) {
        component.set("v.showUpload", false);  
    },
    
    cancelButton: function(component, event, helper) { 
        $A.get("e.force:closeQuickAction").fire();
    },
    
    showfiledata :  function (component, event, helper){    
        component.set("v.isLoading",true);
        component.set("v.showDownloadCSVButton",false);
        var action = component.get('c.checkrequiredfields');    
        //console.log('123');
        console.log('action:'+action);
        action.setCallback(this, function(response) {
            console.log('3');
            var state = response.getState();
            var checkResult = response.getReturnValue();
            component.set("v.isLoading",false);
            console.log('checkResult123:'+checkResult);
            console.log('state value:'+state);
            if (response.getState() == "SUCCESS") { 
                console.log('checkResult123:'+checkResult);
                component.set("v.showRequiredField",checkResult);
                var fileInput = component.find("file").getElement();
        console.log('fileInput:'+fileInput);
        var file = fileInput.files[0];
        
        console.log('alert(file):'+file);//alert(file);
        if (file){
            //console.log("File");
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                
                console.log("EVT FN");
                var csv = evt.target.result;
                var result = helper.Headerandvaluecheck(component,csv);
                console.log('Result:'+result);
                
                if(result != "SUCCESS"){
                    component.set("v.errorMessage",result);
                    component.set("v.showUpload",false);
                    component.set("v.isError",true);
                }
                else if(result == "SUCCESS"){
                    component.set("v.showUploadButton",true);
                }
                //helper.insertProductsData(component,result);
                
            }
            reader.onerror = function (evt) {
                //console.log("error reading file");
            }
        } 
            }
        }); 
        
        $A.enqueueAction(action); 
    },
    
    //Try
    /*downloadCSV : function(component, event, helper, fileTitle) {
        console.log('inside downloadCSV');
        // 3. Getting table data to download it in CSV.
        var gridData = component.get("v.gridData");       // 4. Spliting headers form table.
        console.log('gridData:'+gridData);
        var gridDataHeaders = gridData["headers"];
        console.log('gridDataHeaders:'+gridDataHeaders);
        //var fileTitle = "Error";
        // 5. Spliting row form table.
        var gridDataRows = gridData["rows"];
        console.log('gridDataRows:'+gridDataRows);
        // 6. CSV download.
        var csv = '';
        for(var i = 0; i < gridDataHeaders.length; i++){         
            csv += (i === (gridDataHeaders.length - 1)) ? gridDataHeaders[i]["title"] : gridDataHeaders[i]["title"] + ','; 
        }
        csv += "\n";
        var data = [];
        for(var i = 0; i < gridDataRows.length; i++){
            var gridRowIns = gridDataRows[i];
            var gridRowInsVals = gridRowIns["vals"];
            var tempRow = [];
            for(var j = 0; j < gridRowInsVals.length; j++){                                     
                var tempValue = gridRowInsVals[j]["val"];
                if(tempValue.includes(',')){
                    tempValue = "\"" + tempValue + "\"";
                }
                tempValue = tempValue.replace(/(\r\n|\n|\r)/gm,"");                 
                tempRow.push(tempValue);
            }
            data.push(tempRow); 
        }
        data.forEach(function(row){
            csv += row.join(',');
            csv += "\n";
        });
        // 6. To download table in CSV format.
         console.log('csv:'+csv);
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'fileTitle'+'.csv'; 
        hiddenElement.click();
    },*/
    // ## function call on Click on the "Download As CSV" Button. 
    downloadCSV : function(component,event,helper){
        
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.gridData");
        console.log('stockData:'+stockData);
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'Tender Error.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        }, 
    handleFileSelect :  function (component, event, helper){    
        component.set("v.isLoading",true);
        component.set("v.showDownloadCSVButton",false);
        var action = component.get('c.getTenderMetadatDetails');
        console.log('action:'+action);
        action.setCallback(this, function(response) {
            component.set("v.isLoading",false);
            console.log('response.getState():'+response.getState());
            console.log('response.getReturnValue():'+response.getReturnValue());
            if (response.getState() == "SUCCESS") { 
                var mapOfColumnNameWithTenderMetadata = response.getReturnValue();
                console.log('mapOfColumnNameWithTenderMetadata :'+mapOfColumnNameWithTenderMetadata);
                var fileInput = component.find("file").getElement();
                console.log('fileInput:'+fileInput);
                var file = fileInput.files[0];
                
                console.log('alert(file):'+file);//alert(file);
                if (file){
                    var fr=new FileReader();
                    /*fr.onload=function(){
                    document.getElementById('output')
                            .textContent=fr.result;
                }*/
                    
                    //var fileDetails = this.files[0];
                    file.arrayBuffer().then(function (ab) {
                        var data = new Uint8Array(ab);
                        var workbook = XLSX.read(data, {
                            type: "array"
                        });
                        /* *****************************************************************
                    * DO SOMETHING WITH workbook: Converting Excel value to Json       *
                    ********************************************************************/
                            var first_sheet_name = workbook.SheetNames[0];
                            /* Get worksheet */
                            var worksheet = workbook.Sheets[first_sheet_name];
                            var _JsonData = XLSX.utils.sheet_to_json(worksheet,{defval:"",raw: false});
                            /************************ End of conversion ************************/
                            
                            console.log(_JsonData);
                            
                            var result = '';
                            //Check to see if all the columns are present in the selected sheet
                            result = helper.checkMissingColumns(component,_JsonData,mapOfColumnNameWithTenderMetadata);
                            if(result!=''){
                                if(result === 'EMPTY'){
                                   result = 'One or more empty columns found in the selected Global Template. Please check.';  
                                }
                                else{
                                    result = result+' Column/s are missing from the Global Template';
                                }
                                component.set("v.errorMessage",result);
                                component.set("v.showUpload",false);
                                component.set("v.isError",true);
                            }
                            else{
                                //All columns are present so check for required fields data check
                                var setOfMissingRequiredFieds = new Set();
                                setOfMissingRequiredFieds = helper.checkMissingRequiredColumnValues(component,_JsonData,mapOfColumnNameWithTenderMetadata);
                                
                                // If all the required fields are prsent then set the _JsonData to the UI attribute for later purpose
                                //If condition needs to be changed
                                if(setOfMissingRequiredFieds.size==0){
                                    
                                    console.log("result: "+result);
                                    console.log(_JsonData);
                                    var json = JSON.stringify(_JsonData);
                                    component.set("v.fileItemsConvertedToJSON",json);
                                    component.set("v.showUploadButton",true);
                                    console.log("XSLX to json: "+json);
                                }
                                else{
                                    setOfMissingRequiredFieds.forEach (function(value) {
                                        if(result===''){
                                            result = value;
                                        }
                                        else{
                                            result = result+', '+value;
                                        }
                                    })
                                    result = result+' Column value/s are required but empty in the selected Global Template.'; 
                                    //results ='Here need to add required fields missing error';
                                    component.set("v.errorMessage",result);
                                    component.set("v.showUpload",false);
                                    component.set("v.isError",true);
                                }
                            }
                        });
                } 
                else{
                    //handle File reading failed
                }
            }
            else{
                //Hadle Error state in server call
            }
        }); 
        
        $A.enqueueAction(action); 
    },
    handleFileUpload : function (component, event, helper) {
        component.set("v.showUploadButton", false);
        component.set("v.showUpload", false);
        
        var fileItemsConvertedToJSON = component.get("v.fileItemsConvertedToJSON");
        helper.insertProductsData(component,fileItemsConvertedToJSON);
    },
    
})