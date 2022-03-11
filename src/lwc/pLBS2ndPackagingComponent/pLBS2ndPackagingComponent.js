import { LightningElement,api,wire,track } from 'lwc';

import F1 from '@salesforce/schema/TCB__c.PM_Type_2nd__c';
import F2 from '@salesforce/schema/TCB__c.X2nd_PM_Carton__c';
import F3 from '@salesforce/schema/TCB__c.MOQ_Packaging_2nd__c';
import F4 from '@salesforce/schema/TCB__c.Structure_2nd__c';
import F5 from '@salesforce/schema/TCB__c.Printing_2nd__c';
import F6 from '@salesforce/schema/TCB__c.Tare_Weight_g_2nd__c';
import F7 from '@salesforce/schema/TCB__c.Length_Depth_mm__c';
import F8 from '@salesforce/schema/TCB__c.Width_mm_2nd__c';
import F9 from '@salesforce/schema/TCB__c.Height_mm__c';
import F10 from '@salesforce/schema/TCB__c.Gross_Case_Weight_kg_2nd__c';
import F11 from '@salesforce/schema/TCB__c.Case_CBM_m3__c';
import F12 from '@salesforce/schema/TCB__c.Nut_Density_g_ml__c';
import F13 from '@salesforce/schema/TCB__c.Relative_Carton_Efficiency__c';
//import F12 from '@salesforce/schema/TCB__c.ChangeSetSpace__c';
import getTCBId from '@salesforce/apex/PLBSComponentController.getTCBId';

export default class PLBS2ndPackagingComponent extends LightningElement {

    // The record page provides recordId and objectApiName
    @api recordId;
    @track TCBId;
    @track objectApiName='TCB__c';

    fields = [F1, F2, F3,F4,F5, F6, F7,F8, F9, F10, F11,F12,F13];

    @wire(getTCBId,{
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