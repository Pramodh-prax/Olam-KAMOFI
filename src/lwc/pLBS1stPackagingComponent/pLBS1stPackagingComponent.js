import { LightningElement,api,track,wire } from 'lwc';
import F1 from '@salesforce/schema/TCB__c.PM_Type_1st__c';
import F2 from '@salesforce/schema/TCB__c.X1st_PM_Pouch_jar__c';
import F3 from '@salesforce/schema/TCB__c.MOQ_Packaging_1st__c';
import F4 from '@salesforce/schema/TCB__c.X1st_Structure__c';
import F5 from '@salesforce/schema/TCB__c.X1st_Printing__c';
import F6 from '@salesforce/schema/TCB__c.Tare_Weight_g_1st__c';
import F11 from '@salesforce/schema/TCB__c.Length_mm_1st__c';
import F8 from '@salesforce/schema/TCB__c.Width_mm_1st__c';
import F9 from '@salesforce/schema/TCB__c.Depth_Gusset_Height_mm__c';
import F10 from '@salesforce/schema/TCB__c.Gross_Item_Weight_g_1st__c';
import getTCBId from '@salesforce/apex/PLBSComponentController.getTCBId';

export default class pLBS1stPackagingComponent extends LightningElement {

    // The record page provides recordId and objectApiName
    @api recordId;
    @track TCBId;
    @track objectApiName='TCB__c';

    fields = [F1, F2, F3,F4,F5, F6, F11,F8, F9, F10];

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