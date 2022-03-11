public class opportunityLineItemEdit {  
    // method for fetch OpportunityLineItem records list  
    @AuraEnabled
    public static List < OpportunityLineItem  > fetchOpportunityLineItem(string opportunityId) {
        List < OpportunityLineItem > returnList = new List < OpportunityLineItem > ();
        
        for (OpportunityLineItem opli: [select id,Product2.Name,UnitPrice,Customer_Bid__c,Unit_of_measure__c,Description,PricebookEntry.Pricebook2Id,PricebookEntry.currencyisocode,
                                                              Volume__c,Shipment_Month__c,Splits__c,Sampling_Status__c,Quantity_of_Sample_Grams__c,
                                                              Tracking_Number__c,Tracking_URL__c,Reason_for_Resampling__c,Resampling_Quantity__c,Bulk_Sample_Quantity__c,Sample_Feedback__c from OpportunityLineItem  where opportunityId =: opportunityId]) {
            returnList.add(opli);
        }
        system.debug('returnList:'+returnList);
        return returnList;
    }
    
  // method for update records after inline editing  
    @AuraEnabled
    public static List < OpportunityLineItem > saveOpportunityLineItem(string opportunityId, List<OpportunityLineItem> lstOpportunityLineItem) {
		List < OpportunityLineItem > deleteOppLineItem  = new List < OpportunityLineItem >();
        List < OpportunityLineItem > UpsertOppLineItem  = new List < OpportunityLineItem >();
        set<Id> setOfProductIds = new Set<Id>();
        Map<Id,Id> mapOfPBE = new Map<Id,Id>();
        Map<Id,OpportunityLineItem> mapOfOpportunityLineItem = new Map<Id,OpportunityLineItem>([select id,Product2.Name,UnitPrice,Customer_Bid__c,Unit_of_measure__c,Description,
                                                              Volume__c,Shipment_Month__c,Splits__c,Sampling_Status__c,Quantity_of_Sample_Grams__c,
                                                              Tracking_Number__c,Tracking_URL__c,Reason_for_Resampling__c,Resampling_Quantity__c,Bulk_Sample_Quantity__c,Sample_Feedback__c,Opportunity.PriceBook2Id from OpportunityLineItem  where opportunityId =: opportunityId]);
        
        Opportunity opp = [SELECT Id, CurrencyIsoCode, Pricebook2Id FROM Opportunity WHERE Id =:opportunityId];
        
        for(OpportunityLineItem tempOppLineItem : lstOpportunityLineItem){
            setOfProductIds.add(tempOppLineItem.Product2Id );
        }
        for(PricebookEntry tempPBE : [SELECT Id, Product2Id FROM PricebookEntry where Product2Id IN: setOfProductIds AND CurrencyIsoCode = :opp.CurrencyIsoCode AND Pricebook2Id =: opp.Pricebook2Id]){
            mapOfPBE.put(tempPBE.Product2Id,tempPBE.Id);
        }
        
        for(OpportunityLineItem tempOppLineItem : lstOpportunityLineItem){
           system.debug('New Product '+tempOppLineItem.Product2Id);
            system.debug('Opp Id '+tempOppLineItem);
            OpportunityLineItem temp = new OpportunityLineItem();
            system.debug('Old Product '+mapOfOpportunityLineItem.get(tempOppLineItem.Id).Product2Id);
            If(tempOppLineItem.Product2Id != mapOfOpportunityLineItem.get(tempOppLineItem.Id).Product2Id){
                
                temp.PricebookEntryId = mapOfPBE.get(tempOppLineItem.Product2Id);
                deleteOppLineItem.add(new OpportunityLineItem(Id = tempOppLineItem.Id));
                temp.Id = null;
                temp.OpportunityId = opportunityId;
                temp.UnitPrice = tempOppLineItem.UnitPrice;
                temp.Customer_Bid__c = tempOppLineItem.Customer_Bid__c;
                temp.Unit_of_measure__c = tempOppLineItem.Unit_of_measure__c;
                temp.Description = tempOppLineItem.Description;
                temp.Volume__c = tempOppLineItem.Volume__c;
                temp.Shipment_Month__c = tempOppLineItem.Shipment_Month__c;
                temp.Splits__c = tempOppLineItem.Splits__c;
                temp.Sampling_Status__c = tempOppLineItem.Sampling_Status__c;
                temp.Quantity_of_Sample_Grams__c = tempOppLineItem.Quantity_of_Sample_Grams__c;
                temp.Tracking_Number__c = tempOppLineItem.Tracking_Number__c;
                temp.Tracking_URL__c = tempOppLineItem.Tracking_URL__c;
                temp.Reason_for_Resampling__c = tempOppLineItem.Reason_for_Resampling__c;
                temp.Resampling_Quantity__c = tempOppLineItem.Resampling_Quantity__c;
                temp.Bulk_Sample_Quantity__c = tempOppLineItem.Bulk_Sample_Quantity__c;
                temp.Sample_Feedback__c = tempOppLineItem.Sample_Feedback__c;
            }
            else{
                temp = tempOppLineItem;
            }
            UpsertOppLineItem.add(temp);
        }
        system.debug('deleteOppLineItem:'+deleteOppLineItem);
        system.debug('deleteOppLineItem size:'+deleteOppLineItem.size());
        system.debug('InsertOppLineItem:'+UpsertOppLineItem);
        system.debug('InsertOppLineItem size:'+UpsertOppLineItem.size());
        
        if(deleteOppLineItem.size()>0)
        	Delete deleteOppLineItem;
        if(UpsertOppLineItem.size()>0)
        	upsert UpsertOppLineItem;
        //system.debug('Id ze:'+InsertOppLineItem[0].Id);
        return lstOpportunityLineItem;
    }
    
  /* method for fetch picklist values dynamic  
    @AuraEnabled
    public static List < PricebookEntry > getProductList(string opportunityId) {
        Opportunity opp = [select id,pricebook2id from Opportunity where id =:opportunityId];
         List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
        PricebookEntryList = ([Select id,Pricebook2Id,IsActive,Product2Id,
                                   Product2.name,
                                   Product2.id from PricebookEntry
                                   where Pricebook2Id =:OPP.Pricebook2Id 
                                   limit 20]);
        return PricebookEntryList;
    }*/
    // method for fetch picklist values dynamic  
    @AuraEnabled
    public static Map < String, String > getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        Map < String, String > allOpts = new Map < String, String > ();
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
            allOpts.put(a.getLabel(), a.getValue());
        }
        system.debug('*****allOpts***** ---->' + allOpts);
        //allOpts.sort();
        return allOpts;
    }
}