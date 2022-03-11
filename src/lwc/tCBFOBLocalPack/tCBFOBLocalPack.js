import { LightningElement,api,track,wire } from 'lwc';
import F1 from '@salesforce/schema/TCB__c.FOB_LC_Pack_Pallet__c';
import F2 from '@salesforce/schema/TCB__c.FOB_LC_Pack_Floor_Load__c';
import F3 from '@salesforce/schema/TCB__c.CFR_LC_Pack_Pallet__c';
import F4 from '@salesforce/schema/TCB__c.CFR_LC_Pack_Floor_Load__c';
import F5 from '@salesforce/schema/TCB__c.DDP_LC_Pack_Pallet__c';
import F6 from '@salesforce/schema/TCB__c.DDP_LC_Pack_Floor_Load__c';


export default class TCBFOBLocalPack extends LightningElement {
    @api recordId;
    @api objectApiName;


    fields = [F1, F2, F3,F4,F5,F6];

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields);
    }
}