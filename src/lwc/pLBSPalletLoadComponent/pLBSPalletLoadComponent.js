import { LightningElement,api,track,wire } from 'lwc';
import F1 from '@salesforce/schema/TCB__c.Unit_CTN__c';
import F2 from '@salesforce/schema/TCB__c.Case_Mix_PL__c';
import F3 from '@salesforce/schema/TCB__c.ChangeSetSpace__c';
import F4 from '@salesforce/schema/TCB__c.CTN_Layer__c';
import F5 from '@salesforce/schema/TCB__c.Layer_PL__c';
import F6 from '@salesforce/schema/TCB__c.Layer_PL_40HC__c';
import F7 from '@salesforce/schema/TCB__c.PL_20FT__c';
import F8 from '@salesforce/schema/TCB__c.PL_40FT__c';
import F9 from '@salesforce/schema/TCB__c.PL_40FT_HC__c';
import F10 from '@salesforce/schema/TCB__c.Pack_PL__c';
import F11 from '@salesforce/schema/TCB__c.Pack_40HC_PL__c';
import F12 from '@salesforce/schema/TCB__c.ChangeSetSpace__c';
import F13 from '@salesforce/schema/TCB__c.Pack_20FT_PL__c';
import F14 from '@salesforce/schema/TCB__c.Pack_40FT_PL__c';
import F15 from '@salesforce/schema/TCB__c.Pack_40FT_HC_PL__c';
import F16 from '@salesforce/schema/TCB__c.MT_20FT_PL__c';
import F17 from '@salesforce/schema/TCB__c.MT_40FT_PL__c';
import F18 from '@salesforce/schema/TCB__c.MT_40FT_HC_PL__c';
import F19 from '@salesforce/schema/TCB__c.CBM_20DC_PL__c';
import F20 from '@salesforce/schema/TCB__c.CBM_40DC_PL__c';
import F21 from '@salesforce/schema/TCB__c.CBM_40HC_PL__c';
import F22 from '@salesforce/schema/TCB__c.Gross_MT_20FT_PL__c';
import F23 from '@salesforce/schema/TCB__c.Gross_MT_40FT_PL__c';
import F24 from '@salesforce/schema/TCB__c.Gross_MT_40FT_HC_PL__c';
import F25 from '@salesforce/schema/TCB__c.Utilization_20DC_PL__c';
import F26 from '@salesforce/schema/TCB__c.Utilization_40DC_PL__c';
import F27 from '@salesforce/schema/TCB__c.Utilization_40HC_PL__c';
import F28 from '@salesforce/schema/TCB__c.Pallet_Height_mm__c';
import F29 from '@salesforce/schema/TCB__c.Gross_Pallet_Weight_kg__c';
import F30 from '@salesforce/schema/TCB__c.ChangeSetSpace__c';
import getTCBId from '@salesforce/apex/PLBSComponentController.getTCBId';

export default class pLBSPalletLoad extends LightningElement {

    // The record page provides recordId and objectApiName
    @api recordId;
    @track TCBId;
    @track objectApiName='TCB__c';

    fields = [F1, F2,F3,F4,F5, F6, F7,F8, F9, F10, F11,
        F12,F13, F14,F15, F16, F17,F18, F19, F20, F21,
        F22, F23,F24,F25, F26, F27,F28, F29,F30];

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