({
    doInit : function(component, event) {
        let sectionData = component.get ('v.sectionData');
        component.set ('v.isLoading', true);

        let params = {
            overViewMetadata : JSON.stringify (sectionData.compDetail), 
            data : JSON.stringify ({
                customerGroup : sectionData.accountPlan.Customer_Group__c,
                BU_Identifier__c:sectionData.accountPlan.BU_Identifier__c
            })
        }
        let self = this;
        this.invokeApex (component, 'c.getDetails', params)
        .then(
            $A.getCallback(result => {
                const allPromises = new Array();
                if (result && typeof result !== 'undefined' && result !== null) {
                    
                    component.set ('v.accounts', JSON.parse (result));
                    
                    JSON.parse (result).forEach (ele => {
                        allPromises.push(self.invokeApex (component, 'c.getContactsByAccountId', {accountId : ele.Id}));
                    });
                }
                return Promise.all(allPromises);
            })
        ).then (
            $A.getCallback(contacts => {
                let allContacts = [];
                if (contacts) {
                    contacts.forEach (ele => {
                        if (ele && ele.length > 0) {
                            allContacts = allContacts.concat (ele);
                        }
                    })
                }
                component.set ('v.allContacts', allContacts);
                component.set ('v.isLoading', false);
                component.set ('v.isContactsLoaded', true);
            })
        ).catch (
            $A.getCallback(error => {
                component.set ('v.isLoading', false);
                component.set ('v.isContactsLoaded', true);
                this.showErrorToast(component, 'Error', JSON.stringify (error), 'error', '5000');
                console.log('Promise was rejected: ', error);                    
            })
        );
    }
})