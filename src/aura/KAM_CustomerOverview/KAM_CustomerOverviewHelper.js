({
    doInit : function(component, event) {
        let sectionData = component.get ('v.sectionData');
        let params = {
            overViewMetadata : JSON.stringify (sectionData.compDetail), 
            data : JSON.stringify ({
                accountId : sectionData.accountId
            })
        }
        let self = this;
        this.invokeApex (component, 'c.getDetails', params)
        .then(
            $A.getCallback(result => {
                result = JSON.parse (result);
                if (result && typeof result !== 'undefined' && result !== null) {
                    let tempArray = [];
                    result.fields.forEach (ele => {
                        if (ele && ele.apiName) {
                            tempArray.push (ele.apiName)
                        }
                    })
                    component.set ('v.fieldApiNames', tempArray);
                    component.set ('v.fields', result.fields);
                }
                component.set ('v.isLoading', false);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                this.console.log('Promise was rejected: ', error);                    
            })
        );

        component.addValueProvider(
            'filedValueProvider',
            {
                get: function(key, comp) {
                    let fields = component.get("v."+key); 
                    let accountRecord = component.get ('v.accountRecord');
                    if (accountRecord) {
                        fields.forEach (ele => {
                            if (ele  && ele.apiName) {
                                ele = Object.assign (ele, {
                                    value :  accountRecord[ele.apiName] ? accountRecord[ele.apiName] : ''
                                })
                            }
                        })
                    }
                    return fields;
                },
            }
        );
    }
})