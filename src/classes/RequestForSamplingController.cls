/**
* @description       : Controller for the RequestForSampling component that deletes selected product from an opportunity
* @author            : Bharatesh Shetty
* @group             : 
* @last modified on  : 09-06-2021
* @last modified by  : Bharatesh Shetty
**/
public class RequestForSamplingController{
    public RequestForSamplingController() {
        
    }
    /**
* @description : To fetch all the Opportunity Line Items for the currect opportunity
* @author Bharatesh Shetty | 09-01-2021 
* @param recordId 
* @return List<OpportunityLineItemWrapper> 
**/
    @AuraEnabled 
    public static List<OpportunityLineItemWrapper> fetchOpportunityLineItemWrapper(Id recordId ){     
        List<OpportunityLineItemWrapper> lstOpportunityLineItemWrapper = new List<OpportunityLineItemWrapper>();
        // query OpportunityLineItem records related to opportunity and create 'OpportunityLineItemWrapper' class instance for each record. 
        for(OpportunityLineItem opLineItem : [Select id,Name,OpportunityId,Product2Id,Region__c,Country__c,UoM__c,Quantity_of_Sample_Grams__c,Volume__c,UnitPrice,
                                              Opportunity.Name,Opportunity.PriceBook2Id,Opportunity.Estimated_Volume_MT__c,Opportunity.Target_Selling_Price__c,
                                              Opportunity.First_Sample_Due_Date__c,Opportunity.Key_Driver_to_Win_Project__c,Opportunity.Target_Margin__c,Opportunity.CloseDate,
                                              Product2.Name,Product2.Product_Category__c,Opportunity.CurrencyIsoCode
                                              from OpportunityLineItem 
                                              where OpportunityId =:recordId 
                                              order by Name]){
                                                  // by default checkbox should be false  
                                                  lstOpportunityLineItemWrapper.add(new OpportunityLineItemWrapper(false,opLineItem,opLineItem.Opportunity.Name+' '+opLineItem.Product2.Name));
                                              } 
        // return the 'lstOpportunityLineItemWrapper' list 
        return lstOpportunityLineItemWrapper; 
    }
    
    @AuraEnabled
    public static String processSampleRequests(List<OpportunityLineItemWrapper> listOfSelectedOppLineItemWrapper) { 
        System.debug('listOfSelectedOppLineItemWrapper: '+listOfSelectedOppLineItemWrapper);
        String returnResponse = 'SOME ERROR OCCURRED. PLEASE CONTACT SYSTEM ADMIN.' ;
        Savepoint sp = Database.setSavepoint();
        try{
            if(!listOfSelectedOppLineItemWrapper.isEmpty()){
                
                List<Opportunity> listOfOppsToCreate = new  List<Opportunity>();
                List<OpportunityLineItem> listOfOppLineItemsToCreate = new  List<OpportunityLineItem>();
                List<OpportunityTeamMember> listOfOppTeamMemberToCreate = new  List<OpportunityTeamMember>();
                Map<String,PriceBookEntry> mapOfProductIdVsPBE = new Map<String,PriceBookEntry>();
                RelationshipUtiltiy relUtil = new RelationshipUtiltiy();
                Set<Id> setOfProductIds = new Set<Id>();
                String parentOppPriceBookId;
                String parentOppCurrencyISOCode;
               //Query for map
                for(OpportunityLineItemWrapper  eachProductSamplingReq : listOfSelectedOppLineItemWrapper){
                    if(String.isBlank(parentOppPriceBookId)){
                        parentOppPriceBookId = eachProductSamplingReq.objOpportunityLineItem.Opportunity.PriceBook2Id;
                    }
                    if(String.isBlank(parentOppCurrencyISOCode)){
                        parentOppCurrencyISOCode = eachProductSamplingReq.objOpportunityLineItem.Opportunity.CurrencyIsoCode;
                   }
                    if(eachProductSamplingReq.objOpportunityLineItem.Product2Id != NULL){
                        setOfProductIds.add(eachProductSamplingReq.objOpportunityLineItem.Product2Id);
                    }
                }   
                
                if(!setOfProductIds.isEmpty()){
                    System.debug('setOfProductIds: '+setOfProductIds);
                    System.debug('parentOppPriceBookId: '+parentOppPriceBookId);
                    System.debug('parentOppCurrencyISOCode: '+parentOppCurrencyISOCode);
                    for(PriceBookEntry pbe : [Select id,Name,Product2Id, PriceBook2Id
                                              from PriceBookEntry
                                              where Product2Id =: setOfProductIds and PriceBook2Id =: parentOppPriceBookId AND CurrencyISOCode =: parentOppCurrencyISOCode]){
                                                  mapOfProductIdVsPBE.put(pbe.Product2Id,pbe); 
                                              }
                    if(!mapOfProductIdVsPBE.isEmpty()){
                        for(OpportunityLineItemWrapper  eachProductSamplingReq : listOfSelectedOppLineItemWrapper){
                            //For each Product Sampling requested, create a new Develop opportunity.
                            Opportunity opp = createOpportunity(eachProductSamplingReq);
                            listOfOppsToCreate.add(opp);
                            //Attach File captured as Sample spec for each opportunity
                            
                            //For each Product Sampling requested, create a new OpportunityTeamMember.
                            
                            Id pricebookEntryId;
                            if(mapOfProductIdVsPBE.containsKey(eachProductSamplingReq.objOpportunityLineItem.Product2Id)){
                                pricebookEntryId = mapOfProductIdVsPBE.get(eachProductSamplingReq.objOpportunityLineItem.Product2Id).Id;
                            }
                            OpportunityLineItem oppLineitem = createOpportunityLineItem(eachProductSamplingReq, opp, pricebookEntryId);
                            
                            //Register relationship between oppLineitem and opp instances
                            relUtil.registerRelationship(oppLineitem, opp, OpportunityLineItem.OpportunityId);
                            listOfOppLineItemsToCreate.add(oppLineitem);
                            
                            //For each Product Sampling requested, create a new OpportunityLineItem.
                            OpportunityTeamMember oppTeamMember = createOpportunityTeamMember(eachProductSamplingReq, opp);
                            
                            //Register relationship between oppTeamMember and opp instances
                            relUtil.registerRelationship(oppTeamMember, opp, OpportunityTeamMember.OpportunityId);
                            listOfOppTeamMemberToCreate.add(oppTeamMember);
                        }
                        if(!listOfOppsToCreate.isEmpty() && !listOfOppTeamMemberToCreate.isEmpty() && !listOfOppLineItemsToCreate.isEmpty()){
                            //insert Opportunity
                            insert listOfOppsToCreate;
                            System.debug('listOfOppsToCreate : '+listOfOppsToCreate);
                            
                            //resolve relationship and insert OpportunityTeamMember
                            relUtil.resolve('OpportunityTeamMember');
                            insert listOfOppTeamMemberToCreate;
                            System.debug('listOfOppTeamMemberToCreate : '+listOfOppTeamMemberToCreate);
                            
                            // resolve relationship andinsert OpportunnityLineItem
                            relUtil.resolve('OpportunityLineItem');
                            insert listOfOppLineItemsToCreate;
                            System.debug('listOfOppLineItemsToCreate : '+listOfOppLineItemsToCreate);
                            
                            returnResponse = 'SUCCESS';
                        }
                        else{
                            System.debug('listOfOppsToCreate or listOfOppTeamMemberToCreate or  listOfOppLineItemsToCreate is empty');
                        }
                    }
                    else{
                        System.debug('queried mapOfProductIdVsPBE is empty');
                    }
                }
                else{
                    System.debug('setOfProductIds is empty');
                }
            }
            else{
                System.System.debug('Selected list empty');
            }
        }
        catch(Exception e){
            System.debug('Exception Message: '+e.getMessage());
            System.debug('Exception StacktraceSTring: '+e.getStackTraceString());
            returnresponse = e.getMessage();
            //returnresponse ='Divided by zero. Error';
            Database.rollback(sp);
        }
        return returnresponse;
    }
    
    @AuraEnabled
    public static Map<String,List <String>> getSelectOptionsForFields(Map<String,sObject> mapOfPicklistFieldNameWithSobject) {
        Map<String,List <String>> mapOfFieldNameWithOptions = new Map<String,List <String>>();
        for(String fieldName : mapOfPicklistFieldNameWithSobject.keySet()){
            mapOfFieldNameWithOptions.put(fieldName,getselectOptions(mapOfPicklistFieldNameWithSobject.get(fieldName),fieldName));
        }
        return mapOfFieldNameWithOptions;
    }
    // method for fetch picklist values dynamic  
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
    
    public static Opportunity createOpportunity(OpportunityLineItemWrapper eachOpportunityLineItemWrapper){
        Opportunity opp = new Opportunity();
        opp.RecordTypeId = OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID;
        opp.Name = eachOpportunityLineItemWrapper.OppName;
        opp.Parent_Opportunity__c = eachOpportunityLineItemWrapper.objOpportunityLineItem.OpportunityId;
        opp.AccountId = eachOpportunityLineItemWrapper.accountId;
        opp.Estimated_Volume_MT__c = eachOpportunityLineItemWrapper.estimatedVolume;
        opp.Target_Selling_Price__c = eachOpportunityLineItemWrapper.taregtSellingPrice;
        opp.StageName = OpportunityConstants.OPPORTUNITY_STAGE_BRIEFING;
        opp.First_Sample_Due_Date__c = eachOpportunityLineItemWrapper.firstSampleDueDate;
        opp.Key_Driver_to_Win_Project__c = eachOpportunityLineItemWrapper.keyDriverToWinProject;
        opp.Target_Margin__c = eachOpportunityLineItemWrapper.targetMargin;
        opp.CloseDate = eachOpportunityLineItemWrapper.firstSampleDueDate;
        opp.Project_Type__c = 'Sample';
        opp.CurrencyIsoCode = eachOpportunityLineItemWrapper.objOpportunityLineItem.Opportunity.CurrencyIsoCode;
        return opp;
    }
    
    public static OpportunityTeamMember createOpportunityTeamMember(OpportunityLineItemWrapper eachOpportunityLineItemWrapper, Opportunity oppRecord){
        OpportunityTeamMember OppTeamMember = new OpportunityTeamMember();
        OppTeamMember.OpportunityId = oppRecord.Id;
        OppTeamMember.OpportunityAccessLevel = OpportunityConstants.OPPORTUNITY_TEAM_MEMBER_EDIT_ACCESS;
        OppTeamMember.UserId = eachOpportunityLineItemWrapper.PDandIUserId;
        OppTeamMember.TeamMemberRole = OpportunityConstants.OPPORTUNITY_TEAM_PDandI_MEMBER_ROLE;
        return OppTeamMember;
    }
    
    public static OpportunityLineItem createOpportunityLineItem(OpportunityLineItemWrapper eachOpportunityLineItemWrapper, Opportunity oppRecord, Id PBEId){
        OpportunityLineItem OppLineItem = new OpportunityLineItem();
        OppLineItem.OpportunityId = oppRecord.Id;
        OppLineItem.PricebookEntryId = PBEId;
        OppLineItem.Product2Id = eachOpportunityLineItemWrapper.objOpportunityLineItem.Product2Id;
        OppLineItem.Region__c = eachOpportunityLineItemWrapper.objOpportunityLineItem.Region__c;
        OppLineItem.Country__c = eachOpportunityLineItemWrapper.objOpportunityLineItem.Country__c;
        OppLineItem.Sampling_Status__c = OpportunityConstants.sampleStatus_New;
        //Sample Quantity
        OppLineItem.UoM__c = eachOpportunityLineItemWrapper.unitOfMeasure;
        OppLineItem.Quantity_of_Sample_Grams__c = eachOpportunityLineItemWrapper.quantityOfSample;
        
        return OppLineItem;
    }
    public class OpportunityLineItemWrapper {
        
        @AuraEnabled public String reasonForRemoval {get;set;}
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public Id accountId {get;set;}
        @AuraEnabled public Id PDandIUserId {get;set;}
        @AuraEnabled public String OppName {get;set;}
        @AuraEnabled public Decimal estimatedVolume {get;set;}
        @AuraEnabled public Decimal taregtSellingPrice {get;set;}
        @AuraEnabled public Date firstSampleDueDate{get;set;}
        @AuraEnabled public String keyDriverToWinProject {get;set;}
        @AuraEnabled public String targetMargin {get;set;}
        //Sample Quantity
        @AuraEnabled public String unitOfMeasure {get;set;}
        @AuraEnabled public Decimal quantityOfSample {get;set;}
        
        @AuraEnabled public OpportunityLineItem objOpportunityLineItem{get;set;}
        public OpportunityLineItemWrapper(boolean isChecked, OpportunityLineItem objOpportunityLineItem, String OppName){
            this.isChecked = isChecked;
            this.objOpportunityLineItem = objOpportunityLineItem;
            this.OppName = OppName;
        }
        public OpportunityLineItemWrapper(){
        }
    }
}