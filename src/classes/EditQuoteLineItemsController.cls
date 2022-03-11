public class EditQuoteLineItemsController {
    
    @AuraEnabled 
    public static List<LineItemWrapper> fetchLineItemWrapper(List<QuoteLineItem> QuoLIList,Id QuoteId){ 
        
        List<LineItemWrapper> lstLineItemWrapper = new List<LineItemWrapper>();
        System.debug('QuoLIList: '+QuoLIList);
        for(QuoteLineItem quoLI : QuoLIList)
        {
            lstLineItemWrapper.add(new LineItemWrapper(quoLI));
        }
        System.debug('lstLineItemWrapper: '+lstLineItemWrapper);
        return lstLineItemWrapper; 
    }
	
    public class LineItemWrapper {
        @AuraEnabled public QuoteLineItem objPBE{get;set;}
        @AuraEnabled public String customerMaterialCode{get;set;}
        @AuraEnabled public Double unitPrice{get;set;}
        @AuraEnabled public Double volume{get;set;}
        @AuraEnabled public String unitOfMeasure{get;set;}
        @AuraEnabled public String isPLMApprovalRequired{get;set;}
        @AuraEnabled public Boolean isFileUploaded{get;set;}
			
        public LineItemWrapper(QuoteLineItem objQLI){
            this.objPBE = objQLI;
            this.unitPrice = objQLI.UnitPrice;
            this.volume = objQLI.Volume__c;
            //this.isFileUploaded = false;
            this.isFileUploaded = objQLI.Is_File_Uploaded__c;
            this.isPLMApprovalRequired = objQLI.Approval_Required__c;
            this.customerMaterialCode = objQLI.Customer_Material_Code__c;
        }
        public LineItemWrapper(){
        }
    }
    
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }
    
    @AuraEnabled
    public static List<String> getIsApprovalRequiredValues(Id QuoteId)
    {
        //Boolean quoteAlreadyHasPricebook = False;
        List<String> returnList = new List<String>();
        List<Quote> listOfQuote = new List<Quote>();
        listOfQuote = [Select id,Bussiness_Unit__c,Opportunity.Account.Regions__c,OpportunityId from Quote where id=: QuoteId];
        if(!listOfQuote.isEmpty()){
            if(String.isNotBlank(listOfQuote[0].Bussiness_Unit__c) && String.isNotBlank(listOfQuote[0].Opportunity.Account.Regions__c)){
                List<ApprovalRequiredControl__mdt> listOfApprovalRequiredControlMtdt = new List<ApprovalRequiredControl__mdt>();
                listOfApprovalRequiredControlMtdt = [Select id,Business_Unit__c,Region__c,Required__c 
                                                     From ApprovalRequiredControl__mdt
                                                     Where Business_Unit__c =: listOfQuote[0].Bussiness_Unit__c and Region__c =: listOfQuote[0].Opportunity.Account.Regions__c and Required__c = True];
                if(listOfApprovalRequiredControlMtdt.isEmpty()){
                    System.debug('listOfApprovalRequiredControlMtdt: '+listOfApprovalRequiredControlMtdt);
                    returnList.add('Yes');
                    returnList.add('No');
                    //System.debug('returnList1: '+returnList);
                }
                else{
                    returnList.add('Yes');
                    //System.debug('returnList2: '+returnList);
                }
            }
            else{
                returnList.add('Yes');
                returnList.add('No');
                //System.debug('returnList3: '+returnList);
            }
        }
        System.debug('returnList4: '+returnList);
        return returnList;
    }
    
     @AuraEnabled
    public static String updateQuoteLineItem(Id QuoteId, List<LineItemWrapper> lstLineItemWrapper)
    {
        String returnResponse = 'OOOPS! Some error occurred. Please Contact System Admin.';
        Savepoint sp = Database.setSavepoint();
        try{
            if(!lstLineItemWrapper.isEmpty() && QuoteId != Null){
                List<QuoteLineItem> listOfQuoteLineItemToInsert = new List<QuoteLineItem>();
                for(LineItemWrapper wrapper: lstLineItemWrapper){
                    //For each selected line item create a quote line item record under the parent quote record
                    QuoteLineItem qtLineItem = new QuoteLineItem();
                    qtLineItem.Id = wrapper.objPBE.Id;
                    //qtLineItem.QuoteId = QuoteId;
                    qtLineItem.unitPrice = wrapper.unitPrice;
                    qtLineItem.Volume__c = wrapper.volume;
                    qtLineItem.Unit_Of_Measure__c = wrapper.unitOfMeasure;
                    qtLineItem.Approval_Required__c = wrapper.isPLMApprovalRequired;
                    qtLineItem.Is_File_Uploaded__c = wrapper.isFileUploaded;
                    
                    listOfQuoteLineItemToInsert.add(qtLineItem);
                }
                if(!listOfQuoteLineItemToInsert.isEmpty()){
                    System.debug('listOfQuoteLineItemToInsert: '+listOfQuoteLineItemToInsert);
                    update listOfQuoteLineItemToInsert;
                    returnResponse = 'SUCCESS';
                }
            }
        }
        catch(Exception e){
            System.debug('Exception Message: '+e.getMessage());
            System.debug('Exception StacktraceSTring: '+e.getStackTraceString());
            returnresponse = 'OOOPS! Some error occurred. Please Contact System Admin. SYSTEM ADMIN EMAIL' +e.getMessage();
            //returnresponse ='Divided by zero. Error';
            Database.rollback(sp);
        }
        System.debug('returnResponse: '+returnResponse);
        return returnResponse;
    }
}