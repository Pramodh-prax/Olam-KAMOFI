({
    CSV2JSON: function (component,csv) {
      
        var arr = []; 
        arr =  csv.split('\n');
        console.log('arr = '+arr);
        arr.pop();
        var jsonObj = [];
		        
        var headers = arr[0].split(',');
        console.log('headers:'+headers);
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
                console.log('obj headers = ' + obj[headers[j].trim()]);
            }
            
            jsonObj.push(obj);
        }
        var json = JSON.stringify(jsonObj);
        console.log("abcd"+json);
        return json;
        
    },
   
    invokeApex: function (component, functionName, paramsObj, isBackground) {

        let promise = new Promise((resolve, reject) => {

            let action = component.get(functionName);

            if (paramsObj != undefined) {
                action.setParams(paramsObj);
            }
            if (isBackground) {
                action.setBackground();
            }
        	
            action.setCallback(this, (response) => {
                
                console.log('response'+response);
                //for progress bar
            /*    var counter=component.get("v.counter");
                console.log("v.counter "+component.get("v.counter"));
                console.log('counter '+counter);
                counter++;
                component.set("v.counter ",counter);
                console.log("counter"+counter);
                console.log("v.counter "+component.get("v.counter"));
                
            //var interval = setInterval($A.getCallback(function () {
            let progress = component.get("v.counter");
			console.log("progress "+progress);   
             console.log('totalrecordcount'+component.get("v.totalRecordCount"));
            var progressPercentage= (progress*100)/component.get("v.totalRecordCount");
            console.log("progressPercentage "+progressPercentage);                

            var prgBar = component.find("prgBar");
            if(progressPercentage >= 0){
                $A.util.addClass(prgBar,'slds-is-low');
            }
            if(progressPercentage >= 25){
                $A.util.removeClass(prgBar,'slds-is-low');
                $A.util.addClass(prgBar,'slds-is-medium');
            }
            if(progressPercentage >= 50){
                $A.util.removeClass(prgBar,'slds-is-medium');
                $A.util.addClass(prgBar,'slds-is-high');
            }
            if(progressPercentage >= 75){
                $A.util.removeClass(prgBar,'slds-is-high');
                $A.util.addClass(prgBar,'slds-is-critical');
            }
                component.set("v.progress",  progressPercentage);
           // component.set("v.progress", progressPercentage === 100 ? clearInterval(interval) : progressPercentage + 5);
        //}), 1000);
                */
                
                
                let state = response.getState();
             
                if (component.isValid() && state === 'SUCCESS') {
                    resolve(response.getReturnValue());
                } else {
                    reject(Error(this.getErrorMsg(response)));
                }
            })
            $A.enqueueAction(action);

        });

        return promise;
    },
    insertProductsData : function (component,jsonstr){
       // var counter=0;
    	let jsonProducts = JSON.parse (jsonstr);
        let allPromises =  new Array ();
        let oppid = component.get("v.recordId");
        //component.set("v.showProgressBar",true);
        
        component.set("v.isLoading",true);
		let start = window.performance.now (); 
        console.log ('start : ' + start);
        jsonProducts.forEach (ele => {
            allPromises.push (this.invokeApex (component, 'c.insertData', 
                    {
                        OppId : oppid,
                        strfromle : JSON.stringify(ele)
                    }                     
                )
            );
     //counter++;
        })
        Promise.all (allPromises)
        .then ($A.getCallback (results => {
            console.log ('ended : ' + window.performance.now ());
            console.log ('end results: '+results);
            let allSuccess = true;
            let successRecordsCount = 0;
            let failedRecordsCount = 0;
            var listOfErrorRows = [];
            //var ListoferrorRecords ="[";
            //listOfErrorRows.push("[");
            for(var i = 0; i < results.length; i++) {
            console.log ('results[i].isSuccess: '+results[i].isSuccess);
            console.log ('results[i].message: '+results[i].message);
            console.log ('results[i].eachRowAsString: '+results[i].eachRowAsString);
            if(results[i].isSuccess == false){
            allSuccess = false;
            failedRecordsCount = failedRecordsCount+1;
            listOfErrorRows.push(JSON.parse(results[i].eachRowAsString));
            //listOfErrorRows.push(results[i].eachRowAsString);
            console.log('results[i].eachRowAsString1 '+results[i].eachRowAsString);
            //ListoferrorRecords = ListoferrorRecords+results[i].eachRowAsString+",";
            
        }
            else{
            successRecordsCount = successRecordsCount+1;
           
        }
        }
             /*if(allSuccess == false){
            //listOfErrorRows.push("]");
            //ListoferrorRecords = ListoferrorRecords+"]";
        }*/
            console.log('listOfErrorRows '+listOfErrorRows);
            //console.log('ListoferrorRecords '+ListoferrorRecords);
            console.log ('allSuccess '+allSuccess);
            var toastEvent = $A.get("e.force:showToast");
            if(allSuccess == false){
            //var jsonData = JSON.stringify(listOfErrorRows);
            //console.log ('jsonData '+jsonData);
            component.set("v.gridData",listOfErrorRows);
            component.set("v.showDownloadCSVButton",true);
            console.log ('gridData '+component.get("v.gridData"))
            console.log ('showDownloadCSVButton: '+component.get("v.showDownloadCSVButton"));
            toastEvent.setParams({
            title : 'Partial Success',
            message: 'Successful products count : '+successRecordsCount+'. Failed products count : '+failedRecordsCount+'. Click on the Download button to download the error file.',
            duration:' 4000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        }); 
                let msg ="Click on the Download button to download the error file.";
                let sucessmsg = " Successful products count : "+successRecordsCount;
                let failmsg = "Failed products count : "+failedRecordsCount;
                //console.log("abc"+failmsg);
                component.set("v.message",sucessmsg);
                component.set("v.failmsg",failmsg);
                component.set("v.generalmsg",msg);
                
               // component.set("v.message"," Successful products count : "+successRecordsCount +".Failed products count : "+failedRecordsCount+". Click on the Download button to download the error file.");
        }
            else{
            toastEvent.setParams({
            title : 'SUCCESS',
            message: 'All products have been added Successfully.',
            duration:' 4000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });    
                component.set("v.showSuccessMsg",true);
                component.set("v.message","All products have been added Successfully.");
                
        }
        	console.log ('showDownloadCSVButton: '+component.get("v.showDownloadCSVButton"));
            //component.set("v.showProgressBar",false);
            component.set("v.isLoading",false);
              // toastEvent.fire();
               $A.get('e.force:refreshView').fire();
        }))
        .catch ($A.getCallback (errors=> {
            console.log ('ended : ' + window.performance.now ());
            console.log ('end error: '+errors);
            component.set("v.isLoading",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
            title : 'Error',
            message:'SOME ERROR OCCURRED. Please contact system admin',
            messageTemplate: 'Mode is dismissible ,duration is 4sec and Message is overrriden',
            duration:' 4000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
                //toastEvent.fire();
        }));
    },
        
    CreateProduct : function (component,jsonstr){
        var start = window.performance.now (); 
        console.log ('start : ' + start);
        
        console.log('Inside CreateProduct');
        console.log('jsonstr' + jsonstr);
        var oppid = component.get("v.recordId");
        component.set("v.isLoading",true);
        console.log('oppid in Helper:' + oppid);
        var action = component.get('c.insertData');    
        action.setParams({
            strfromle : jsonstr,
            OppId : oppid
        });
        action.setCallback(this, function(response) {
            console.log ('ended : ' + window.performance.now ());
            console.log ('ended : ' + window.performance.now () - start);
            component.set("v.isLoading",false);
            var state = response.getState();
            console.log('state value:'+state);
            var checkResult = response.getReturnValue();
            if (state === "SUCCESS") { 
                console.log('Inside Sucess');
                console.log('response.getState():'+response.getState())
                if(checkResult == "SUCCESS"){
                    //alert("Products Inserted Succesfully");
                    component.set("v.showUploadButton", false);
                    //showSuccessToast(component);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'SUCCESS',
                        message: 'Products added Successfully.',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    //toastEvent.fire();
                }
                else if(checkResult == "ERROR"){
                    alert("Failed to insert Products");
                    //showErrorToast(component);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'SOME ERROR OCCURRED',
                        messageTemplate: 'Mode is dismissible ,duration is 4sec and Message is overrriden',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    //toastEvent.fire();
                }
            }
            else if (state === "ERROR") {
                /*var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    alert('Unknown');
                }*/
                //showErrorToast(component);
            }
        }); 
        
        $A.enqueueAction(action);    
        
    },
    
    /*ValidateProduct : function (component,header){
        console.log('header helper:'+header);
        component.set("v.isLoading",true);
        var action = component.get('c.checkrequiredfields');    
        console.log('1');
        action.setParams({
            
            headers : header
        });
        console.log('action:'+action);
        //debugger;
        action.setCallback(this, function(response) {
            //debugger;
            console.log('3');
            var state = response.getState();
            var checkResult = response.getReturnValue();
            component.set("v.isLoading",false);
            console.log('checkResult:'+checkResult);
            console.log('state value:'+state);
            if (response.getState() == "SUCCESS") { 
                if(checkResult == "SUCCESS"){
                    component.set("v.showUploadButton", true);
                }
                
                else  {
                    component.set("v.errorMessage",checkResult);
                    component.set("v.isError",true);
                    component.set("v.showUpload", false);
                }
            }
        }); 
        
        $A.enqueueAction(action);  
    },*/
    showSuccessToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'SUCCESS',
            message: 'Products added Successfully.',
            duration:' 4000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        //toastEvent.fire();
    },
    showErrorToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:'SOME ERROR OCCURRED',
            messageTemplate: 'Mode is dismissible ,duration is 4sec and Message is overrriden',
            duration:' 4000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        //toastEvent.fire();
    },
        
Headerandvaluecheck: function (component,csv) {
         //debugger;
         var returnresponse = "";
         var isFailed = false;
         var requiredfield = component.get("v.showRequiredField");
         var requiredfieldHeader = requiredfield.split(',');
         console.log('requiredfield size:'+requiredfieldHeader.length);
         var requiredfieldHeaderLength = (requiredfieldHeader.length)-1;
         console.log('requiredfield size1:'+requiredfieldHeaderLength);
        var arr = []; 
        arr =  csv.split('\n'); 
        arr.pop();
        var headers = arr[0].split(',');
         var headerstocheck = arr[0];
         for(var i = 0; i <requiredfieldHeaderLength; i++){
             console.log('abc:'+requiredfieldHeader[i]);
             var ispresent = false;
             for(j=0;j<headers.length; j++){
                 if(headers[j].trim().toLowerCase() == requiredfieldHeader[i].trim().toLowerCase()){
                     ispresent = true;
                 }
             }
             if(ispresent == false){
                 isFailed = true;
                 console.log('i value:'+i);
                 returnresponse = returnresponse+"'"+requiredfieldHeader[i].trim()+"',";
             }
             /*if(headerstocheck.toLowerCase().includes(requiredfieldHeader[i].trim().toLowerCase()) == false){
                isFailed = true;
                 returnresponse = returnresponse+"'"+requiredfieldHeader[i].trim()+"',";
             }*/
         }
         if(isFailed == true){
             returnresponse = returnresponse+"Required fields missing in Global template";
         }
         else if(isFailed == false){
        for(var i = 1; i < arr.length; i++) {
            
            var data = arr[i].split(',');
            //var data = arr[i].match('/(".*?"|[^",\s]+)(?=\s*,|\s*$)/g');
            var obj = {};
            /*
            let str = arr[i];
            let s = '';
            let flag = 0;
            for (let ch of str) {
                if (ch === '"' && flag === 0) {
                    flag = 1;
                }
                else if (ch === '"' && flag == 1) {
                    flag = 0; 
                }
                if (ch === ', ' && flag === 0){
                    ch = '|';
                }
                if (ch !== '"') {
                    s += ch; 
                }
              }
            let properties = s.split("|");
            console.log("headers",headers);
            for (let j in headers) {
                if (properties[j].includes(", ")) {
                    obj[headers[j]] = properties[j].split(", ").map(item => item.trim());
                    console.log("inside for and if loop");
                }
                else obj[headers[j]] = properties[j];
                console.log("inside for and if loop");
                    }
            console.log("objone",obj);
            result.push(obj);
			console.log("resultone"+result);
            let json = JSON.stringify(result);
			console.log("json",json);
     
			*/             
             
            for(var j = 0; j < data.length; j++) {
                console.log('data[j].trim()1:'+data[j].trim());
                if(requiredfield.toLowerCase().includes(headers[j].trim().toLowerCase())){
                    console.log('data[j].trim()2:'+data[j].trim());
                    if(data[j].trim() == "" ){
                        console.log('data[j].trim()3:'+data[j].trim());
                        isFailed = true;
                        if(returnresponse.toLowerCase().includes(headers[j].trim().toLowerCase()) == false){
                            returnresponse = returnresponse+"'"+headers[j].trim()+"',";
                        }
                    }
                }
            }
        }
         if(isFailed == false){
             returnresponse = "SUCCESS";
         }
         else if(isFailed == true){
             returnresponse = returnresponse+" Required field value missing";
         }
         }
         console.log('returnresponse:'+returnresponse);
        return returnresponse;
    },
    convertArrayOfObjectsToCSV : function(component,objectRecords){
        debugger;
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key 
        // this labels use in CSV file header  
        //keys = ['FirstName','LastName','Department','MobilePhone','Id' ];
        //keys = ['Product Family','Product Category','Product Sub Category','Product Sub Category 2','Olam Material Code','Olam Material Description','Customer Material Code','Customer Material Specification','Customer Material Description','Package Type','Region,Country','Key Incoterm','Contract start date','Contract end date','Tentative Bid Volumes','Finalised Volume','UoM','Price/UoM','Is offered by Olam?','Approved to Supply' ];
        
        // Get the CSV header from the list.
        var keys = new Set();
        
        objectRecords.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                keys.add(key);
            });
        });

        // 
        keys = Array.from(keys);
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               
               csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
            console.log('csvStringResult:'+csvStringResult);
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    }, 
        readAndConvertSelectedFile: function (component,file) {
            var _JsonData =[];
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
            _JsonData = XLSX.utils.sheet_to_json(worksheet, { raw: false });
            /************************ End of conversion ************************/
            
            /*for(var i=0;i<_JsonData.length;i++){
                for (var key in _JsonData[i]) {
                    console.log("key:" + key + "  value: " + _JsonData[i][key]);
                }
            }
            console.log(_JsonData);
            var json = JSON.stringify(_JsonData);
            console.log("XSLX to json: "+json);*/
            
        });
        return _JsonData;
    },
    checkMissingColumns: function (component,_JsonData,mapOfColumnNameWithTenderMetadata) {
        console.log(_JsonData);
        var result ='';
        var headerMap=new Map();  
        for (var key in _JsonData[0]) {
            //console.log("key:" + key + "  value: " + _JsonData[0][key]);
            if(key == '__EMPTY'){
               result = 'EMPTY'; 
               break;
            }
            headerMap.set(key,_JsonData[0][key]);
        }
        console.log('headerMap:'+headerMap);
        console.log('headerMap json: '+JSON.stringify(headerMap));

        if(result===''){
            for (var key in mapOfColumnNameWithTenderMetadata) {
                if(headerMap.has(key)){
                    console.log("key:" + key + "  value: " + headerMap[key]);
                }
                else{
                    console.log("key:" + key + "  Not found in file");
                    if(result===''){
                        result = key;
                    }
                    else{
                        result = result+', '+key;
                    }
                }
            }
        }
        return result;
    },
    checkMissingRequiredColumnValues: function (component,_JsonData,mapOfColumnNameWithTenderMetadata) {
        var setOfMissingRequiredFieds = new Set();
        for(var i=0;i<_JsonData.length;i++){
            for (var key in _JsonData[i]) {
                //console.log("key:" + key + "  value: " + _JsonData[i][key]);
                //var eachCellData = _JsonData[i][key];
                //Trim white space issue needs to be resolved
                if(mapOfColumnNameWithTenderMetadata[key].Is_Required__c && _JsonData[i][key]===''){
                    console.log("Column value required but empty: "+key);
                    setOfMissingRequiredFieds.add(key);
                }
            }
        }
        return setOfMissingRequiredFieds;
    },
})