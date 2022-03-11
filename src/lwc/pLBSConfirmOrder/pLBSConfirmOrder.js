import { LightningElement,api,track,wire } from 'lwc';
import F1 from '@salesforce/schema/Opportunity.StageName';
import F2 from '@salesforce/schema/Opportunity.Unit_Awarded__c';
import F3 from '@salesforce/schema/Opportunity.MT_Awarded__c';
import F4 from '@salesforce/schema/Opportunity.Awarded__c';
import F5 from '@salesforce/schema/Opportunity.Final_Price_Pack__c';
import F6 from '@salesforce/schema/Opportunity.Local_Currency__c';
import F7 from '@salesforce/schema/Opportunity.Final_Price_Per_Pack_USD__c';
import F8 from '@salesforce/schema/Opportunity.Shipment_Term__c';
import F9 from '@salesforce/schema/Opportunity.Shipped_Container_Type__c';
import F10 from '@salesforce/schema/Opportunity.Start_contract__c';
import F11 from '@salesforce/schema/Opportunity.End_contract__c';
import F12 from '@salesforce/schema/Opportunity.Final_Quote__c';
import F13 from '@salesforce/schema/Opportunity.Final_Margin_TCB__c';
import F14 from '@salesforce/schema/Opportunity.PLBS_Total_Revenue__c';
import F15 from '@salesforce/schema/Opportunity.PLBS_Total_Profit__c';

import getTCBId from '@salesforce/apex/PLBSComponentController.getTCBId';

export default class PLBSConfirmOrder extends LightningElement {

     // The record page provides recordId and objectApiName
     @api recordId;
     //@track TCBId;
     @api objectApiName;
 
     fields = [F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,
        F12,F13,F14,F15]; //F6,F13
 
    /* @wire(getTCBId, {
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
     */
     handleSubmit(event){
         event.preventDefault();
         const fields = event.detail.fields;
         this.template.querySelector('lightning-record-form').submit(fields);
     }
}