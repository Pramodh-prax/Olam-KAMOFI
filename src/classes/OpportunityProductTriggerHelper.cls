public class OpportunityProductTriggerHelper {
    public static boolean isIniatedFromOpportunityProduct = false;
    
    
    public static void UpdateSampleRequestLineItem(Map<Id,OpportunityLineItem> oppLineItemOldMap,List<OpportunityLineItem> oppLineItemList){  
        List<Sample_Request_Line_Item__c> srLineItemListToUpdate = new List<Sample_Request_Line_Item__c>();     
        set<id> opptyIdSet = new set<id>();
        
        Map<Id,OpportunityLineItem> mapOfOli = new Map <Id,OpportunityLineItem>();
        for(OpportunityLineItem opli : oppLineItemList){
            if(opli.Sampling_Status__c != oppLineItemOldMap.get(opli.Id).Sampling_Status__c ||
               opli.Quantity_of_Sample_Grams__c != oppLineItemOldMap.get(opli.Id).Quantity_of_Sample_Grams__c ||
               opli.Sample_with_Billing__c != oppLineItemOldMap.get(opli.Id).Sample_with_Billing__c ||
               opli.Sample_Feedback__c != oppLineItemOldMap.get(opli.Id).Sample_Feedback__c ||
               opli.UoM__c != oppLineItemOldMap.get(opli.Id).UoM__c ||//newly added
               opli.Followup_Date__c != oppLineItemOldMap.get(opli.Id).Followup_Date__c || //newly added
               opli.Reason_for_Resampling__c != oppLineItemOldMap.get(opli.Id).Reason_for_Resampling__c ||
               opli.Resampling_Quantity__c != oppLineItemOldMap.get(opli.Id).Resampling_Quantity__c ||
               opli.Bulk_Sample_Quantity__c != oppLineItemOldMap.get(opli.Id).Bulk_Sample_Quantity__c
              ){
                  mapOfOli.put(opli.Id,opli);
              }
        }
        
        List<Sample_Request_Line_Item__c> srLinItmlst = [SELECT Id,Opportunity_Product__c,Product__c,Sample_Sent_Date__c,Sample_Received_Date__c,Followup_Date__c,
                                                         Quantity_Dispatched__c,Sample_Acceptance_Rejection_Date__c,Product_Family__c,Quantity__c,Sample_Request__c,Sampling_Status__c,
                                                         Reason_for_Resampling__c, Resampling_Quantity__c, Bulk_Sample_Quantity__c
                                                         FROM Sample_Request_Line_Item__c 
                                                         WHERE Opportunity_Product__c IN :mapOfOli.keyset()];
        
        if(mapOfOli.size() > 0 && srLinItmlst.size() > 0){
            for(Sample_Request_Line_Item__c srLnItm : srLinItmlst){
                srLnItm.Sampling_Status__c = mapOfOli.get(srLnItm.Opportunity_Product__c).Sampling_Status__c;
                srLnItm.Sample_with_Billing__c = mapOfOli.get(srLnItm.Opportunity_Product__c).Sample_with_Billing__c;
                srLnItm.Sample_Feedback__c = mapOfOli.get(srLnItm.Opportunity_Product__c).Sample_Feedback__c;
                srLnItm.Quantity__c = mapOfOli.get(srLnItm.Opportunity_Product__c).Quantity_of_Sample_Grams__c;
                srLnItm.Unit_of_measure__c  = mapOfOli.get(srLnItm.Opportunity_Product__c).UoM__c; //newly added
                srLnItm.Followup_Date__c = mapOfOli.get(srLnItm.Opportunity_Product__c).Followup_Date__c; //newly added
                srLnItm.Reason_for_Resampling__c = mapOfOli.get(srLnItm.Opportunity_Product__c).Reason_for_Resampling__c;
                srLnItm.Resampling_Quantity__c = mapOfOli.get(srLnItm.Opportunity_Product__c).Resampling_Quantity__c;
                srLnItm.Bulk_Sample_Quantity__c = mapOfOli.get(srLnItm.Opportunity_Product__c).Bulk_Sample_Quantity__c;
                srLnItm.Integration_Status__c = 'update';
                srLineItemListToUpdate.add(srLnItm);
            }
        }
        
        if(!srLineItemListToUpdate.isEmpty() && srLineItemListToUpdate.size() > 0){
            isIniatedFromOpportunityProduct = true;
            UPDATE srLineItemListToUpdate;            
        }
    }
    
    
    public static void throwErrorForFileUpload(Map<Id,OpportunityLineItem> oppLineItemOldMap,List<OpportunityLineItem> oppLineItemList){
        system.debug('inside throwErrorForFileUpload method');
        Map<Id, List<ContentDocumentLink>> mapOfOpptyIdContentDocumentLinkList = new Map<Id, List<ContentDocumentLink>>();
        set<id> opptyIdSet = new set<id>();
        for(OpportunityLineItem opli : oppLineItemList){
            opptyIdSet.add(opli.OpportunityId);
        }
        
        List<ContentDocumentLink> listOfFiles = [SELECT ContentDocumentId,LinkedEntityId,ContentDocument.createdDate 
                                                 FROM ContentDocumentLink 
                                                 WHERE LinkedEntityId IN :opptyIdSet AND ContentDocument.createdDate = TODAY
                                                ];
        system.debug('listOfFiles==>'+listOfFiles);
        
        if(!listOfFiles.isEmpty() && listOfFiles.size() > 0){
            for(ContentDocumentLink cd : listOfFiles) {
                if(String.isNotBlank(cd.LinkedEntityId)){
                    if(!mapOfOpptyIdContentDocumentLinkList.containsKey(cd.LinkedEntityId)) {
                        mapOfOpptyIdContentDocumentLinkList.put(cd.LinkedEntityId, new List<ContentDocumentLink>());
                    }
                    mapOfOpptyIdContentDocumentLinkList.get(cd.LinkedEntityId).add(cd);
                }
                
            }
        }
        
        for(OpportunityLineItem opli : oppLineItemList){
            if(
                (opli.Sampling_Status__c != oppLineItemOldMap.get(opli.Id).Sampling_Status__c) &&
                (opli.Sampling_Status__c == OpportunityConstants.sampleStatus_Resampling) &&
                (opli.Reason_for_Resampling__c == 'Change in Sample Spec' || opli.Reason_for_Resampling__c == 'Change in Quantity & Sample Spec')    
            ){
                system.debug('conditions met');
                system.debug('opportunity id = ' + opli.OpportunityId);                    
                if(mapOfOpptyIdContentDocumentLinkList.containsKey(opli.OpportunityId)){
                    integer numberOfFiles = mapOfOpptyIdContentDocumentLinkList.get(opli.OpportunityId).size();
                    system.debug('number of files = '+numberOfFiles);
                }else{
                    opli.adderror(system.label.FileUploadValidation);
                } 
            }
        }
    }
    
    
    public static void captureFieldChangeHistory(Map<Id,OpportunityLineItem> oppLineItemOldMap,List<OpportunityLineItem> oppLineItemList){
        Set<String> fieldNamesToTrackHistory = new Set<String>();
        Map<String, OpportunityProductFieldHistory__mdt> fieldHistoryMap = OpportunityProductFieldHistory__mdt.getAll();
        Map<String, String> sampleStatusMap = new Map<String, String>{'1'=>'New', '5'=>'Samples Sent', '12'=>'Pending Feedback', '10'=>'Resampling', '7'=>'Sample Accepted', '8'=>'Sample Rejected', '6'=>'Resample Sent to the Customer', '9'=>'Sample Approved, asking for bulk sample', '13'=>'Kept on Hold', '14'=>'No Response', '16'=>'Project Dropped'};
        
        List<Opportunity_Product_History__c> fieldHistoryListToInsert = new List<Opportunity_Product_History__c>();
        for(OpportunityLineItem oppLine :oppLineItemList){
            for(OpportunityProductFieldHistory__mdt fieldHistory :fieldHistoryMap.values()){
                if(oppLine.get(fieldHistory.FieldAPIName__c) != oppLineItemOldMap.get(oppLine.Id).get(fieldHistory.FieldAPIName__c)){
                    String oldValue = String.valueOf(oppLineItemOldMap.get(oppLine.Id).get(fieldHistory.FieldAPIName__c));
                    String newValue = String.valueOf(oppLine.get(fieldHistory.FieldAPIName__c));
                    
                    fieldHistoryListToInsert.add(
                        new Opportunity_Product_History__c(
                            New_Value__c = fieldHistory.FieldAPIName__c == 'Sampling_Status__c' ? sampleStatusMap.get(newValue) : newValue,
                            Old_Value__c = fieldHistory.FieldAPIName__c == 'Sampling_Status__c' ? sampleStatusMap.get(oldValue) : oldValue,
                            Opportunity_Product__c = oppLine.Id,
                            Name = fieldHistory.Label
                        )
                    );
                }
            }
        }
        
        if(fieldHistoryListToInsert.size() > 0){
            insert fieldHistoryListToInsert;
        }
    }
    
    
    public static void updateProductNameOnOpportunity(List<OpportunityLineItem> oppLineItemList){
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        
        for(OpportunityLineItem oppli :oppLineItemList){
            opportunityIdSet.add(oppli.OpportunityId);
            productIdSet.add(oppli.Product2Id);
        }
        
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        opportunityMap = new Map<Id, Opportunity>([SELECT Id, Product__c FROM Opportunity WHERE Id IN :opportunityIdSet]);
        
        Map<Id, Product2> productsMap = new Map<Id, Product2>();
        productsMap = new Map<Id, Product2>([SELECT Id, Name FROM Product2 WHERE Id IN :productIdSet]);
            
        for(OpportunityLineItem oppli :oppLineItemList){
            if(opportunityMap.containsKey(oppli.OpportunityId) && productsMap.containsKey(oppli.Product2Id)){
                if(opportunityMap.get(oppli.OpportunityId).Product__c == null){
                    opportunityMap.get(oppli.OpportunityId).Product__c = productsMap.get(oppli.Product2Id).Name + '; ';
                }
                else{
                    opportunityMap.get(oppli.OpportunityId).Product__c = opportunityMap.get(oppli.OpportunityId).Product__c + productsMap.get(oppli.Product2Id).Name + '; ';
                }
            }
        }
        
        if(opportunityMap.size() > 0){
            update opportunityMap.values();
        }
    }
    
    
    public static void handleOpportunityLogUpdates(List<OpportunityLineItem> newListOfLineItems,Map<Id,OpportunityLineItem> oldMapOfLineItems){
        if(!newListOfLineItems.isEmpty() && !oldMapOfLineItems.isEmpty()){
            Set<Id> setOfProductIds = new Set<Id>();
            Set<Id> setOfOppIds = new Set<Id>();
            //Map<>
            for(OpportunityLineItem opLineItem : newListOfLineItems){
                //When an opportunity line items updated check if the Volume or the unitprice has been changed
                if(opLineItem.Volume__c != oldMapOfLineItems.get(opLineItem.Id).Volume__C || opLineItem.UnitPrice != oldMapOfLineItems.get(opLineItem.Id).UnitPrice){
                    //If it has changed then take the productId and Opp Id of the line item in the sets
                    setOfProductIds.add(opLineItem.Product2Id);
                    setOfOppIds.add(opLineItem.OpportunityId);
                }
            }
            if(!setOfProductIds.isEmpty() && !setOfOppIds.isEmpty()){
                // Use the ID sets to query for the Opportunity Log records
                Map<String, Opportunity_Log__C> mapOfParentIdsWithOpportunityLogRec = new Map<String, Opportunity_Log__C>();
                List<Opportunity_Log__C> listOfOppLogsToInsert = new List<Opportunity_Log__C>();
                Map<Id, Opportunity_Log__C> mapOfOppLogIDWithRecToUpdate = new Map<Id, Opportunity_Log__C>();
                
                for(Opportunity_Log__C oppLog : [SELECT id,OpportunityID__c,Product2Id__c,Original_Volume_MT__c,Original_Olam_Offer_per_MT__c,Volume__c,UnitPrice__c 
                                                 FROM Opportunity_Log__C 
                                                 WHERE OpportunityID__c =: setOfOppIds AND Product2Id__c =: setOfProductIds]){
                                                     //Construct a map of two parentIds as key and Child
                    mapOfParentIdsWithOpportunityLogRec.put(oppLog.OpportunityID__c+''+oppLog.Product2Id__c,oppLog);
                }
                if(!mapOfParentIdsWithOpportunityLogRec.isEmpty()){
                    for(OpportunityLineItem opLineItem : newListOfLineItems){
                        //Check if there's already an Opp Log with the same parent records as that of the changed Opp line Item
                        if(mapOfParentIdsWithOpportunityLogRec.containsKey(opLineItem.OpportunityId+''+opLineItem.Product2Id)){
                            //If yes, take the record and update the newly updated values in Opp line item to the opp log 
                            Opportunity_Log__c oppLogToUpdate = new Opportunity_Log__c();
                            oppLogToUpdate.id = mapOfParentIdsWithOpportunityLogRec.get(opLineItem.OpportunityId+''+opLineItem.Product2Id).Id;
                            oppLogToUpdate.Volume__c = opLineItem.Volume__C;
                            oppLogToUpdate.UnitPrice__c = opLineItem.Unitprice;
                            //oppLogToUpdate.Action__c = 'Line Item Value Changed';//Use a constant Class
                            
                            //and add it to the map to update
                            mapOfOppLogIDWithRecToUpdate.put(oppLogToUpdate.id, oppLogToUpdate);
                        }
                        else{
                            //if there's no Opp Log with the same parent records as that of the changed Opp line Item
                            //Create Opportunity_Log__c instance with all the necessary values and add it to the list
                            Opportunity_Log__c oppLogToInsert = new Opportunity_Log__c();
                            oppLogToInsert.Name = opLineItem.Name;
                            oppLogToInsert.Product2Id__c = opLineItem.Product2Id;
                            oppLogToInsert.OpportunityID__c = opLineItem.OpportunityId;
                            oppLogToInsert.Original_Volume_MT__c = oldMapOfLineItems.get(opLineItem.id).Volume__C;
                            oppLogToInsert.Original_Olam_Offer_per_MT__c = oldMapOfLineItems.get(opLineItem.id).Unitprice;
                            oppLogToInsert.Volume__c = opLineItem.Volume__C;
                            oppLogToInsert.UnitPrice__c = opLineItem.Unitprice;
                            oppLogToInsert.Action__c = 'Line Item Value Changed';//Use a constant Class
                            
                            //Add it to the list to insert
                            listOfOppLogsToInsert.add(oppLogToInsert);
                        }
                    }
                }
                else{
                    //There are no Opp Log with the same parent records as changed Opp line Items
                    //Create and insert new Opp Log record and populate the Old values in the original fields and newly updated values in the other fields
                    for(OpportunityLineItem opLineItem : newListOfLineItems){
                        
                        //Create Opportunity_Log__c instance with all the necessary values and add it to the list
                        Opportunity_Log__c oppLogToInsert = new Opportunity_Log__c();
                        oppLogToInsert.Name = opLineItem.Name;
                        oppLogToInsert.Product2Id__c = opLineItem.Product2Id;
                        oppLogToInsert.OpportunityID__c = opLineItem.OpportunityId;
                        oppLogToInsert.Original_Volume_MT__c = oldMapOfLineItems.get(opLineItem.id).Volume__C;
                        oppLogToInsert.Original_Olam_Offer_per_MT__c = oldMapOfLineItems.get(opLineItem.id).Unitprice;
                        oppLogToInsert.Volume__c = opLineItem.Volume__C;
                        oppLogToInsert.UnitPrice__c = opLineItem.Unitprice;
                        oppLogToInsert.Action__c = OpportunityLogConstants.ACTION_LINE_ITEM_VALUE_CHANGED;//Use a constant Class
                        
                        //Add it to the list to insert
                        listOfOppLogsToInsert.add(oppLogToInsert);
                    }
                }
                
                if(!listOfOppLogsToInsert.isEmpty()){
                    insert listOfOppLogsToInsert;
                }
                if(!mapOfOppLogIDWithRecToUpdate.isEmpty()){
                    update mapOfOppLogIDWithRecToUpdate.values();
                }
            }
        } 
    }
}