import { LightningElement, api } from 'lwc';

import F1 from '@salesforce/schema/Opportunity.PLBS_Product__c';
import F2 from '@salesforce/schema/Opportunity.Product_Family__c';
import F3 from '@salesforce/schema/Opportunity.Sub_Category__c';
import F4 from '@salesforce/schema/Opportunity.Plbs_Weight_G__c';
import F5 from '@salesforce/schema/Opportunity.Case_Mix__c';
import F6 from '@salesforce/schema/Opportunity.Plbs_Shelf_Price__c';
import F7 from '@salesforce/schema/Opportunity.Plbs_Annual_Unit__c';
import F8 from '@salesforce/schema/Opportunity.Annual_MT__c';
import F9 from '@salesforce/schema/Opportunity.Plbs_Est_Award__c';
import F10 from '@salesforce/schema/Opportunity.Plbs_Manufacturing_Facility__c';
import F11 from '@salesforce/schema/Opportunity.Description';

export default class PLBSProductInfo extends LightningElement {
    @api recordId;
    @api objectApiName;

    fields = [F1,F2, F3,F4,F5, F6, F7,F8, F9, F10, F11 ];// 
    //PM_Type_1st__c = F1;why?they are using this field

    handleSubmit(event){
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-form').submit(fields);
     }
}