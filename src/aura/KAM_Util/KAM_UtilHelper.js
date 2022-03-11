({
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
    createComponent: function (component, componentName, sectionData) {
        let promise = new Promise((resolve, reject) => {
            $A.createComponent(
                componentName, 
                sectionData,
                (infoSubPanel, status, errorMessage) => {
                    if (status === 'SUCCESS') {
                        resolve(infoSubPanel);
                    } else if (status === 'INCOMPLETE') {
                        reject('No response from server or client is offline.');
                    } else if (status === 'ERROR') {
                        reject(errorMessage);
                    }
                }
            );
        });
        return promise;
    },
    getErrorMsg: function (response) {
        if (response.getState() === "ERROR") {
            var errors = response.getError();
            if (errors) {
                let errorMessage = ' ';
                for (let index = 0; index < errors.length; index++) {
                    const ele = errors[index];
                    errorMessage += '  ' + (ele.message ? ele.message : '');
                }
                return errorMessage;
            }
        }
        return 'Failed with State - ' + state + ' --- ' + JSON.stringify(errors);
    },
    console: { //credits stackoverflow
        debug: true,
        log: function () {
            if (this.debug) {
                var args = Array.prototype.slice.call(arguments);
                console.trace.apply(console, args);
            }
        }
    },
    string: {
        format : function () {
            //https://stackoverflow.com/questions/2534803/use-of-string-format-in-javascript
            let s = arguments[0];
            for (let i = 0; i < arguments.length - 1; i++) {       
                let reg = new RegExp("\\{" + i + "\\}", "gm");             
                s = s.replace(reg, arguments[i + 1]);
            }
            return s;
            
            //https://coderwall.com/p/flonoa/simple-string-format-in-javascript
            // let a = this;
            // for (let k in arguments) {
            //     a = a.replace("{" + k + "}", arguments[k])
            // }
            // return a
        }
    },
    getUrlParameter : function (sParam) {
        let sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
    
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
    
            if (sParameterName[0] === sParam) {
                return sParameterName[1] === undefined ? true : sParameterName[1];
            }
        }
        return null;
    },
    showToast : function(component,title, message, type, duration) {
        let toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title : title,
                message: message,
                duration: duration ? duration :'3000',
                key: 'info_alt',
                type: type,
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    showErrorToast : function(component,title, message, type, duration) {
        let toastEvent = $A.get("e.force:showToast");
        let showDevToastEnabled = $A.get('$Label.c.KAM_IS_DEV_ERROR_TOAST_ENABLED');
        if (showDevToastEnabled && showDevToastEnabled.toLowerCase () === 'yes') {
            console.log(
                ("%c"+"Dev Ref :" + message),
                "color: fuchsia; font-weight: bold ; font-size: 14px ; font-style: italic ; "
            );    
            if (toastEvent) {
                toastEvent.setParams({
                    title : title,
                    message: message,
                    duration: duration ? duration :'3000',
                    key: 'info_alt',
                    type: type,
                    mode: 'pester'
                });
                toastEvent.fire();
            } else {
                alert (message);
            }
        }
    },
    localSort : function(cmp, data, sortBy, sortDir, type) {
    	
    	let sortedArray = data.sort(function(a, b) {
            var attrA = a[sortBy],
                attrB = b[sortBy];

            //check for numbers disguised as strings
            var attrACopy = attrA;
            var attrBCopy = attrB;

            //check for null values	
            if(attrA == null || attrA == undefined){
      			return 1;
    		}
    		if(attrB == null || attrB == undefined){
      			return -1;
            }
            
            if (type && type === 'date') {
                if (sortDir == "asc") {
                    return (new Date(attrA) - new Date(attrB));
                } else if (sortDir == "desc") {
                    return (new Date(attrB) - new Date(attrA));
                }
            }
            
            if(typeof attrACopy == 'string'){
                attrACopy = attrACopy.replace(',','');
            }
            
            if(typeof attrBCopy == 'string'){
                attrBCopy = attrBCopy.replace(',','');
            }

            if($.isNumeric(attrACopy) && $.isNumeric(attrBCopy)){
                attrA = Number(attrACopy);
                attrB = Number(attrBCopy);
            }
   
            if(!$.isNumeric(attrA)) { //make sort case-insensitive for strings
            	attrA = attrA.toUpperCase();
                attrB = attrB.toUpperCase();
            }
            if (attrA < attrB)
    			return sortDir == 'asc' ? -1 : 1;
  			if (attrA > attrB)
    			return sortDir == 'asc' ? 1 : -1;
            return 0;
        });
        
        //console.log('sortedArray',sortedArray);
        return sortedArray;
    },
    //https://stackoverflow.com/questions/63378749
    invertColor : function (hex, bw) {
        if (hex.indexOf('#') === 0) {
           hex = hex.slice(1);
        }
        // convert 3-digit hex to 6-digits.
        if (hex.length === 3) {
           hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
        }
        if (hex.length !== 6) {
           throw new Error('Invalid HEX color.');
        }
        var r = parseInt(hex.slice(0, 2), 16),
            g = parseInt(hex.slice(2, 4), 16),
            b = parseInt(hex.slice(4, 6), 16);
        if (bw) {
            // http://stackoverflow.com/a/3943023/112731
            return (r * 0.299 + g * 0.587 + b * 0.114) > 186
              ? '#000000'
              : '#FFFFFF';
        }
        // invert color components
        r = (255 - r).toString(16);
        g = (255 - g).toString(16);
        b = (255 - b).toString(16);
        // pad each with zeros and return
        return "#" + this.padZero(r) + this.padZero(g) + padZero(b);
    },
      
    padZero : function(str, len) {
        len = len || 2;
        var zeros = new Array(len).join('0');
        return (zeros + str).slice(-len);
    },

    //https://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
    componentToHex : function(c) {
        var hex = c.toString(16);
        return hex.length == 1 ? "0" + hex : hex;
    },
      
    rgbToHex : function(r, g, b) {
        return "#" + this.componentToHex(r) + this.componentToHex(g) + this.componentToHex(b);
    },

    getRandomBG : function() {
        let x = Math.floor(Math.random() * 256);
        let y = Math.floor(Math.random() * 256);
        let z = Math.floor(Math.random() * 256);
        let bgColor = "rgb(" + x + "," + y + "," + z + ")";

        return this.rgbToHex (x, y, z);
    },
    //https://dev.to/dcodeyt/build-a-user-profile-avatar-generator-with-javascript-436m
    generateAvatar : function(text, foregroundColor, backgroundColor) {
        const canvas = document.createElement("canvas");
        const context = canvas.getContext("2d");
    
        canvas.width = 200;
        canvas.height = 200;
    
        // Draw background
        context.fillStyle = backgroundColor;
        context.fillRect(0, 0, canvas.width, canvas.height);
    
        // Draw text
        context.font = "100px Helvetica, Arial, sans-serif";
        context.fillStyle = foregroundColor;
        context.textAlign = "center";
        context.textBaseline = "middle";
        context.fillText(text, canvas.width / 2, canvas.height / 2);
    
        return canvas.toDataURL("image/png");
    },

    getAvatar : function (name) {
        let nameArray = name.split (' ');
        let text = '#$';
        if (nameArray && nameArray.length > 0) {
            text = ((nameArray.length > 1) 
                    ? (nameArray[0].substr (0,1) + nameArray[1].substr (0,1))
                    : nameArray[0].substr (0, 2)).toUpperCase ();
        }

        const bg = this.getRandomBG ();
        return this.generateAvatar (text, this.invertColor (bg, true), bg);
    },
    normalizeError : function (errors) {
        let message = 'Error';
        if (errors && Array.isArray (errors) && errors.length > 0 ) {
            for (let index = 0; index < errors.length; index ++) {
                let error = errors[index];
                if (error && error.message) {
                    message += (' : ' + error.message);  
                } else if (error && error.fieldErrors && Object.keys(error.fieldErrors).length > 0) {
                    Object.keys(error.fieldErrors).forEach (eachKey => {
                        if (error.fieldErrors[eachKey] && Array.isArray (error.fieldErrors[eachKey]) && error.fieldErrors[eachKey].length > 0) {
                            error.fieldErrors[eachKey].forEach (ele => {
                                message += (' : ' + ele.message);
                            })
                        }
                    });
                } else if (error && error.duplicateResults ) {
                    message += ' : ' + JSON.stringify(error.duplicateResults);    
                } else if (error && error.pageErrors  ) {
                    message += ' : ' + JSON.stringify(error.pageErrors);    
                }
            }
        } else if (errors && errors.message) {
            message += errors.message;
        }
        return message;
    },
    /** 
     * dev note: Assumption that the incoming val is always be in unit of Metric ton.
    */
    recalculateVoume : function (compnent, val, targetUnitOfMeasure) {
        if (!val || typeof val === 'undefined' || val === null) {
            return 0;
        }
        let retVal;
        switch (targetUnitOfMeasure) {
            case 'kg' :
                retVal = (val / 0.0010000);
                break;
            case 'lb' :
                retVal = (val * 2204.6);
                break;
            default:
                retVal = val;
        }
        return retVal;
    },
    DEFAULT_UNIT_OF_MEASURE : 'mt',
    UNIT_OF_MEASURE_OPTIONS : [
        {
            label: 'MT', value: 'mt'
        },
        {
            label: 'KG', value: 'kg'
        },
        {
            label: 'LBS', value: 'lb'
        }
    ]
    
})