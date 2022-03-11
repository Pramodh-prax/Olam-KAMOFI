import { LightningElement,api,track,wire } from 'lwc';
import F1 from '@salesforce/schema/TCB__c.CTN_20FT__c';
import F2 from '@salesforce/schema/TCB__c.CTN_40FT__c';
import F3 from '@salesforce/schema/TCB__c.CTN_40FT_HC__c';
import F4 from '@salesforce/schema/TCB__c.Pack_20FT_FL__c';
import F5 from '@salesforce/schema/TCB__c.Pack_40FT_FL__c';
import F6 from '@salesforce/schema/TCB__c.Pack_40FT_HC_FL__c';
import F7 from '@salesforce/schema/TCB__c.MT_20FT_FL__c';
import F8 from '@salesforce/schema/TCB__c.MT_40FT_FL__c';
import F9 from '@salesforce/schema/TCB__c.MT_40FT_HC_FL__c';
import F10 from '@salesforce/schema/TCB__c.CBM_20FT_FL__c';
import F11 from '@salesforce/schema/TCB__c.CBM_40FT_FL__c';
import F12 from '@salesforce/schema/TCB__c.CBM_40HC_FL__c';
import F13 from '@salesforce/schema/TCB__c.Gross_MT_20FT_FL__c';
import F14 from '@salesforce/schema/TCB__c.Gross_MT_40FT_FL__c';
import F15 from '@salesforce/schema/TCB__c.Gross_MT_40FT_HC_FL__c';
import F16 from '@salesforce/schema/TCB__c.Utilization_20DC_FL__c';
import F17 from '@salesforce/schema/TCB__c.Utilization_40DC_FL__c';
import F18 from '@salesforce/schema/TCB__c.Utilization_40HC_FL__c';
import getTCBId from '@salesforce/apex/PLBSComponentController.getTCBId';

export default class PLBSFloorLoadComponent extends LightningElement {

     // The record page provides recordId and objectApiName
     @api recordId;
     @track TCBId;
     @track objectApiName='TCB__c';
 
     fields = [F1, F2, F3,F4,F5, F6, F7,F8, F9, F10, F11,
        F12, F13, F14,F15, F16, F17,F18];
 
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