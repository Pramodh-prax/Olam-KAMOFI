import { LightningElement,api,track,wire } from 'lwc';
import F1 from '@salesforce/schema/TCB__c.FOB_USD_Pack_Pallet__c';
import F2 from '@salesforce/schema/TCB__c.FOB_USD_Pack_Floor_Load__c';
import F3 from '@salesforce/schema/TCB__c.CFR_USD_Pack_Pallet__c';
import F4 from '@salesforce/schema/TCB__c.CFR_USD_Pack_Floor_Load__c';
import F5 from '@salesforce/schema/TCB__c.DDP_USD_Pack_Pallet__c';
import F6 from '@salesforce/schema/TCB__c.DDP_USD_Pack_Floor_Load__c';
import F7 from '@salesforce/schema/TCB__c.FOB_to_DDP_USD_Pack_Pallet__c';
import F8 from '@salesforce/schema/TCB__c.FOB_to_DDP_USD_Pack_Floor_Load__c';
import getTCBId from '@salesforce/apex/PLBSComponentController.getTCBId';

export default class PLBSFOBUsdPackNew extends LightningElement {

    @api recordId;
    @track TCBId;
    @track objectApiName='TCB__c';

 fields = [F1, F2, F3, F4, F5, F6, F7, F8];

     @wire(getTCBId, {
        OppId: '$recordId'
    })
    wiredgetTCBId({
        error,
        data
    }) {
        if(data){
            console.log('data ',data);
            this.TCBId=data;
        }else{
            console.log('error ',error);
        }
    }

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields);
    }
}