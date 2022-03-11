/**
* @description       : 
* @author            : Bharatesh Shetty
* @group             : 
* @last modified on  : 08-29-2021
* @last modified by  : Bharatesh Shetty
**/
public class UploadCSVonOpp {
    
    /**
* @description : for import data into sobject and insert data from csv file
* @author Bharatesh Shetty | 08-25-2021 
* @param strfromle 
* @param OppId 
* @return string 
**/
    Public static String errorColumnName;
    @AuraEnabled
    public static ReturnResponseWrapper insertData(String strfromle, String OppId){
        String returnresponse ='ERROR';
        ReturnResponseWrapper returnWrapper = new ReturnResponseWrapper();
        returnWrapper.isSuccess = False;
        
        Boolean hasError = False;
        //Map<String,String> returnResponseMap = new Map<String,String>();
        Savepoint sp = Database.setSavepoint();
        try{
            system.debug('strfromle:'+strfromle);
            
            //code for dynamic
            Map<string,TenderTemplateConfig__mdt> columnToObjectMapping = new Map<string,TenderTemplateConfig__mdt>();
            
            List<Object> jsonMap = new List<Object>();
            
            List<Product2> listOfProductsToInsert = new List<Product2>();
            List<Opportunity_Log__c> listOfOppLogToInsert = new List<Opportunity_Log__c>();
            //List<PriceBookEntry> listOfPriceBookEntryToInsert = new List<PriceBookEntry>();
            List<OpportunityLineItem> listOfOppLineItemToInsert = new List<OpportunityLineItem>();
            RelationshipUtiltiy relUtil = new RelationshipUtiltiy();
            Map<String,Object> mapOfProdExtCodeWithJsonObject = new Map<String,Object>();
            
            if(String.isNotBlank(OppId) && String.isNotBlank(strfromle)){
                
                //Use OpportunitySelector to Query the Opportunity
                Opportunity opp =[select id,Pricebook2Id, CurrencyIsoCode, name from Opportunity where Id =:OppId];
                
                
                List<Pricebook2> listOfStdPB = new List<Pricebook2>();
                Pricebook2 standardPB = new Pricebook2();
                listOfStdPB = [select id from Pricebook2 where isStandard=true];
                if(!listOfStdPB.isEmpty()){
                    standardPB = listOfStdPB[0]; 
                }
                //Contains the mapping of sheet column name to that of the field API name.
                for(TenderTemplateConfig__mdt tender: [select id,TenderTemplate_column_Name__c,Field_API_Name__c,Datatype__c,Is_Required__c,Object__c from TenderTemplateConfig__mdt]){
                    columnToObjectMapping.put(tender.TenderTemplate_column_Name__c,tender);
                }
                
                //To Store the product family picklist Fied Label and API name
                Map<String,String> mapOfProdFamilyLabelWithAPIName = new Map<String,String>();
                Schema.DescribeFieldResult fieldResultFamily = Product2.Family.getDescribe();
                List<Schema.PicklistEntry> pleFamily = fieldResultFamily.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : pleFamily){
                    mapOfProdFamilyLabelWithAPIName.put(pickListVal.getLabel(),pickListVal.getValue());
                } 
                System.debug('mapOfProdFamilyLabelWithAPIName: '+mapOfProdFamilyLabelWithAPIName);
                
                //To Store the product family picklist Fied Label and API name
                Map<String,String> mapOfCountryLabelWithAPIName = new Map<String,String>();
                Schema.DescribeFieldResult fieldResultCountry = OpportunityLineItem.Country__c.getDescribe();
                List<Schema.PicklistEntry> pleCountry = fieldResultCountry.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : pleCountry){
                    mapOfCountryLabelWithAPIName.put(pickListVal.getLabel(),pickListVal.getValue());
                } 
                System.debug('mapOfCountryLabelWithAPIName: '+mapOfCountryLabelWithAPIName);
                
                if(!mapOfProdFamilyLabelWithAPIName.isEmpty()){
                    //Contains each row in the sheet as an element in a list of object after deserialization.
                    //jsonMap = (List<Object>) JSON.deserializeUntyped(strfromle);
                    Map<String, Object> eachRowObjMap = new Map<String, Object>();
                    eachRowObjMap = (Map<String, Object>) JSON.deserializeUntyped(strfromle);
                    jsonMap.add(eachRowObjMap);
                    System.debug('jsonMap: '+jsonMap);
                    System.debug('columnToObjectMapping: '+columnToObjectMapping);
                    if(!columnToObjectMapping.isEmpty() && !jsonMap.isEmpty()){
                        boolean isValidProductFamily = false;
                        for(Object obj : jsonMap){
                            
                            //Map of column name and Value for each coulumn of each row in the sheet.
                            Map<String, Object> myMaps = (Map<String, Object>)obj;
                            
                            String olamMaterialCode = ''; 
                            //If the 'Not Offered By OLAM' column is blank then it will be treated as false which means that it is being offered by OLAM.
                            Boolean isOfferedByOlam = true;
                            
                            if(myMaps.get(Label.Product_Family)!=null && myMaps.get(Label.Product_Family)!=''){
                                if(mapOfProdFamilyLabelWithAPIName.containsKey(String.valueOf(myMaps.get(Label.Product_Family)))){
                                    isValidProductFamily = true;
                                }
                                else{
                                    break;
                                }
                            }
                            else{
                                break;
                            }
                            if(myMaps.get(Label.Olam_Material_Code)!=null){ //'OLAM Material Code'
                                //get the olam material code if not null.
                                olamMaterialCode = String.valueOf(myMaps.get(Label.Olam_Material_Code));
                            }
                            if(!String.isBlank(olamMaterialCode)){
                                //olamMaterialCode present so product already present. Create only Opportunity Line Item.
                                //Appended with  zeroes for now. Subect to change later.
                                
                                //If the Product family is cocoa then append 6 zeroes to olamMaterialCode in the beginning else use the same.
                                if(myMaps.get(Label.Product_Family)!=null){
                                    if(String.valueOf(myMaps.get(Label.Product_Family)).equals(Label.Cocoa_Product_Family)){
                                        olamMaterialCode = '000000'+olamMaterialCode;
                                    }
                                }
                                mapOfProdExtCodeWithJsonObject.put(olamMaterialCode,obj);
                            }
                            else{
                                //if olamMaterial code is not present then Check if offered by olam or not
                                if(myMaps.get(Label.Is_offered_by_Olam)!=null){ //'Is offered by Olam?'
                                    //get the isOfferedByOlam value if not null.
                                    //notOfferedByOlam = Boolean.valueOf(myMaps.get(Label.Not_Offered_By_OLAM));
                                    if(String.valueOf(myMaps.get(Label.Is_offered_by_Olam)).equalsIgnoreCase('NO')){
                                        isOfferedByOlam = false;
                                    }
                                }
                                if(!isOfferedByOlam){
                                    //If not offered by olam, Create a product and Opportunity Log
                                    Product2 prod = new Product2();
                                    prod = createProduct(prod,columnToObjectMapping, myMaps);
                                    if(prod != Null){
                                        // Hard coded now during unit testing since it is a controlling field for product category and giving error as it's not in the sheet.
                                        //prod.Product_Category__C = Null;
                                        //prod.Product_Sub_Category__C = Null;
                                        Prod.Family = mapOfProdFamilyLabelWithAPIName.get(Prod.Family);
                                        System.debug('Prod.Family: '+Prod.Family);
                                        
                                        System.debug('prod: '+prod);
                                        listOfProductsToInsert.add(prod);
                                        Opportunity_Log__c oppLog = createOpportunityLog(prod,opp.Id,columnToObjectMapping, myMaps) ;
                                        System.debug('oppLog: '+oppLog);
                                        relUtil.registerRelationship(oppLog, prod, Opportunity_Log__c.Product2Id__c);
                                        listOfOppLogToInsert.add(oppLog);
                                    }
                                    
                                }
                                else{
                                    //If offered by olam, Create a product, PriceBookEntry and OpportunityineItem
                                    Product2 prod = new Product2();
                                    prod = createProduct(prod,columnToObjectMapping, myMaps);
                                    if(prod != Null){
                                        // Hard coded now during unit testing since it is a controlling field for product category and giving error as it's not in the sheet.
                                        //prod.Product_Category__C = Null;
                                        //prod.Product_Sub_Category__C = Null;
                                        Prod.Family = mapOfProdFamilyLabelWithAPIName.get(Prod.Family);
                                        System.debug('Prod.Family: '+Prod.Family);
                                        
                                        System.debug('prod: '+prod);
                                        listOfProductsToInsert.add(prod);
                                        
                                        //Should be created ony if the Opp pricebook is not the standardPriceBook. If Check shoud be added
                                        /*if(opp.Pricebook2Id != standardPB.Id){
                                            PricebookEntry standardPBE = new PricebookEntry();
                                            standardPBE = createPriceBookEntry(standardPB.Id,prod.Id,columnToObjectMapping, myMaps);
                                            System.debug('standardPBE: '+standardPBE);
                                            relUtil.registerRelationship(standardPBE, prod, PricebookEntry.Product2Id);
                                            listOfPriceBookEntryToInsert.add(standardPBE);
                                        }
                                        
                                        PricebookEntry pBERec = new PricebookEntry();
                                        pBERec = createPriceBookEntry(opp.Pricebook2Id,prod.Id,columnToObjectMapping, myMaps);
                                        System.debug('pBERec: '+pBERec);
                                        relUtil.registerRelationship(pBERec, prod, PricebookEntry.Product2Id);
                                        listOfPriceBookEntryToInsert.add(pBERec);*/
                                        
                                        
                                        
                                        OpportunityLineItem OpLineItem =new  OpportunityLineItem();
                                        //OpLineItem = createOpportunityLineItem(pBERec.Id,prod.Id, opp.id,columnToObjectMapping, myMaps);
                                        OpLineItem = createOpportunityLineItem(prod.Id, opp.id,columnToObjectMapping, myMaps);
                                        System.debug('OpLineItem.Country__c: '+OpLineItem.Country__c);
                                        if( String.isNotBlank(OpLineItem.Country__c) && mapOfCountryLabelWithAPIName.ContainsKey(OpLineItem.Country__c)){
                                            OpLineItem.Country__c = mapOfCountryLabelWithAPIName.get(OpLineItem.Country__c);
                                        }
                                        System.debug('OpLineItem: '+OpLineItem);
                                        
                                        relUtil.registerRelationship(OpLineItem, prod, OpportunityLineItem.Product2Id);
                                        //relUtil.registerRelationship(OpLineItem, pBERec, OpportunityLineItem.PricebookEntryId);
                                        listOfOppLineItemToInsert.add(OpLineItem); 
                                    }
                                }
                            }
                            System.debug('isOfferedByOlam: '+isOfferedByOlam);
                            System.debug('olamMaterialCode: '+olamMaterialCode);
                        }
                        System.debug('isValidProductFamily: '+isValidProductFamily);
                        if(isValidProductFamily){
                            if(!mapOfProdExtCodeWithJsonObject.isEmpty()){
                                system.debug('mapOfProdExtCodeWithJsonObject.KeySet():'+mapOfProdExtCodeWithJsonObject.KeySet());
                                Map<String,Object> mapOfProdExtCodeWithJsonPBEMissing = new Map<String,Object>();
                                Map<String,PricebookEntry> PricebookEntryMap = new Map<String,PricebookEntry>();
                                
                                for(PricebookEntry priceBookEntry : [Select id,Pricebook2Id,IsActive,Product2Id,
                                                                     Product2.External_Product_Code__c,
                                                                     Product2.id from PricebookEntry
                                                                     where Pricebook2Id =:OPP.Pricebook2Id 
                                                                     AND CurrencyIsoCode = :opp.CurrencyIsoCode
                                                                     AND Product2.External_Product_Code__c =: mapOfProdExtCodeWithJsonObject.KeySet()]){
                                                                         
                                                                         PricebookEntryMap.put(priceBookEntry.Product2.External_Product_Code__c,priceBookEntry);
                                                                     }
                                system.debug('PricebookEntryMap:'+PricebookEntryMap);
                                if(!PricebookEntryMap.isEmpty()){
                                    for(String ExternalProductCode : mapOfProdExtCodeWithJsonObject.KeySet()){
                                        if(PricebookEntryMap.containskey(ExternalProductCode)){
                                            //Map of column name and Value for each coulumn of each row in the sheet.
                                            Map<String, Object> myMaps = (Map<String, Object>)mapOfProdExtCodeWithJsonObject.get(ExternalProductCode);
                                            //OpportunityLineItem will be created if the priceBookEntry present
                                            OpportunityLineItem OpLineItem =new  OpportunityLineItem();
                                            OpLineItem = createOpportunityLineItem(PricebookEntryMap.get(ExternalProductCode).Product2Id, OppId,columnToObjectMapping, myMaps);
                                            OpLineItem.PricebookEntryId = PricebookEntryMap.get(ExternalProductCode).id;
                                            System.debug('OpLineItem.Country__c: '+OpLineItem.Country__c);
                                            if( String.isNotBlank(OpLineItem.Country__c) && mapOfCountryLabelWithAPIName.ContainsKey(OpLineItem.Country__c)){
                                                OpLineItem.Country__c = mapOfCountryLabelWithAPIName.get(OpLineItem.Country__c);
                                            }
                                            relUtil.registerRelationship(OpLineItem, PricebookEntryMap.get(ExternalProductCode).product2, OpportunityLineItem.Product2Id);
                                            //relUtil.registerRelationship(OpLineItem, PricebookEntryMap.get(ExternalProductCode), OpportunityLineItem.PricebookEntryId);
                                            System.debug('OpLineItem: '+OpLineItem);
                                            listOfOppLineItemToInsert.add(OpLineItem); 
                                        } 
                                        else{
                                            // Few of the products with External product code might not have had a PricebookEntry.
                                            mapOfProdExtCodeWithJsonPBEMissing.put(ExternalProductCode,mapOfProdExtCodeWithJsonObject.get(ExternalProductCode));
                                            
                                        }
                                    }
                                }
                                else{
                                    //No PricebookEntry Returned for the set of External product code 
                                    //All the products with External product code might not have had a PricebookEntry
                                    mapOfProdExtCodeWithJsonPBEMissing = new Map<String,object>(mapOfProdExtCodeWithJsonObject);
                                    System.debug('mapOfProdExtCodeWithJsonPBEMissing: '+mapOfProdExtCodeWithJsonPBEMissing);
                                }
                                
                                if(!mapOfProdExtCodeWithJsonPBEMissing.isEmpty()){
                                    //Using the set of External product code query the products and create priceBookEntries for those products and then Opp Line items.
                                    Map<String,Product2> mapOfProdExtCodeVsProduct = new Map<String,Product2>();
                                    Map<String,PricebookEntry> ProdCodeVsStandardPricebookEntryMap = new Map<String,PricebookEntry>();
                                    for(Product2 prod : [Select id, External_Product_Code__c 
                                                         from Product2
                                                         where External_Product_Code__c =:mapOfProdExtCodeWithJsonPBEMissing.keySet()]){
                                                             mapOfProdExtCodeVsProduct.put(prod.External_Product_Code__c,prod);
                                                         }
                                    for(PricebookEntry priceBookEntry : [Select id,Pricebook2Id,IsActive,Product2Id,
                                                                         Product2.External_Product_Code__c,
                                                                         Product2.id from PricebookEntry
                                                                         where Pricebook2Id =: standardPB.Id 
                                                                         AND CurrencyIsoCode = :opp.CurrencyIsoCode
                                                                         AND Product2.External_Product_Code__c =: mapOfProdExtCodeWithJsonPBEMissing.KeySet()]){
                                                                             
                                                                             ProdCodeVsStandardPricebookEntryMap.put(priceBookEntry.Product2.External_Product_Code__c,priceBookEntry);
                                                                         }
                                    if(!mapOfProdExtCodeVsProduct.isEmpty()){
                                        for(String ExternalProductCode: mapOfProdExtCodeWithJsonPBEMissing.keySet()){
                                            if(mapOfProdExtCodeVsProduct.containsKey(ExternalProductCode)){
                                                //Map of column name and Value for each coulumn of each row in the sheet.
                                                Map<String, Object> myMaps = (Map<String, Object>)mapOfProdExtCodeWithJsonPBEMissing.get(ExternalProductCode);
                                                //Create a priceBookEntry
                                                //Do we have to check If the product with External code is already part of Standard pricebook or not? 
                                                //In case if not, do we have to add it first to standard pricebook?
                                                //Should be created ony if the Opp pricebook is not the standardPriceBook. If Check shoud be added
                                                //Add to standard pricebook only if it's not added yet. Or else duplicate errors occurs. Should add that check.
                                                
                                                //If Opp pricebook is not standard Pricebook and if it's not part of standard pricebook then create a stanadrd pricebook entry.
                                                /*if(opp.Pricebook2Id != standardPB.Id && 
                                                   (ProdCodeVsStandardPricebookEntryMap.isEmpty() || (!ProdCodeVsStandardPricebookEntryMap.isEmpty() && !ProdCodeVsStandardPricebookEntryMap.containsKey(ExternalProductCode)))){
                                                       PricebookEntry standardPBE = new PricebookEntry();
                                                       standardPBE = createPriceBookEntry(standardPB.Id,mapOfProdExtCodeVsProduct.get(ExternalProductCode).Id,columnToObjectMapping, myMaps);
                                                       System.debug('standardPBE: '+standardPBE);
                                                       relUtil.registerRelationship(standardPBE, mapOfProdExtCodeVsProduct.get(ExternalProductCode), PricebookEntry.Product2Id);
                                                       listOfPriceBookEntryToInsert.add(standardPBE);
                                                   }
                                                PricebookEntry pBERec = new PricebookEntry();
                                                pBERec = createPriceBookEntry(opp.Pricebook2Id,mapOfProdExtCodeVsProduct.get(ExternalProductCode).Id,columnToObjectMapping, myMaps);
                                                System.debug('pBERec: '+pBERec);
                                                relUtil.registerRelationship(pBERec, mapOfProdExtCodeVsProduct.get(ExternalProductCode), PricebookEntry.Product2Id);
                                                listOfPriceBookEntryToInsert.add(pBERec);
                                                */
                                                
                                                //Create an OpportunityineItem 
                                                OpportunityLineItem OpLineItem =new  OpportunityLineItem();
                                                //OpLineItem = createOpportunityLineItem(pBERec.Id,mapOfProdExtCodeVsProduct.get(ExternalProductCode).Id, opp.id,columnToObjectMapping, myMaps);
                                                OpLineItem = createOpportunityLineItem(mapOfProdExtCodeVsProduct.get(ExternalProductCode).Id, opp.id,columnToObjectMapping, myMaps);
                                                System.debug('OpLineItem.Country__c: '+OpLineItem.Country__c);
                                                if( String.isNotBlank(OpLineItem.Country__c) && mapOfCountryLabelWithAPIName.ContainsKey(OpLineItem.Country__c)){
                                                    OpLineItem.Country__c = mapOfCountryLabelWithAPIName.get(OpLineItem.Country__c);
                                                }
                                                System.debug('OpLineItem: '+OpLineItem);
                                                
                                                relUtil.registerRelationship(OpLineItem, mapOfProdExtCodeVsProduct.get(ExternalProductCode), OpportunityLineItem.Product2Id);
                                                //relUtil.registerRelationship(OpLineItem, pBERec, OpportunityLineItem.PricebookEntryId);
                                                listOfOppLineItemToInsert.add(OpLineItem); 
                                            }
                                            else{
                                                //Some items with External product code are missing from Pricebook entry as well as product query.
                                                //It means that there's no product with that external code.
                                                //Add this line item(row) to to error list.
                                                returnresponse = 'Product not found with the given OLAM Material Code';
                                                hasError = true;
                                            }
                                        }
                                    }
                                    else{
                                        //All items with External product code are missing from Pricebook entry as well as product query.
                                        //It means that there's no product with that external code.
                                        //Add all these line items(rows) to to error list.
                                        returnresponse = 'Product not found with the given OLAM Material Code';
                                        hasError = true;
                                    }
                                }
                            }
                            List<PricebookEntry> listOfPBE = new List<PricebookEntry>();
                            if(!listOfProductsToInsert.IsEmpty()){
                                insert listOfProductsToInsert;
                                System.debug('listOfProductsToInsert: '+listOfProductsToInsert);
                                System.debug('opp.Pricebook2Id: '+opp.Pricebook2Id);
                                System.debug('listOfProductsToInsert[0].id: '+listOfProductsToInsert[0].id);
                                listOfPBE = [Select id FROM PricebookEntry where Pricebook2id=:opp.Pricebook2Id and CurrencyIsoCode = :opp.CurrencyIsoCode AND Product2Id =:listOfProductsToInsert[0].id order by createdDate desc limit 1];
                          
                            }
                            if(!listOfOppLineItemToInsert.IsEmpty()){
                                relUtil.resolve('OpportunityLineItem');
                                if(!listOfPBE.isEmpty() && listOfOppLineItemToInsert[0].PricebookEntryId == NULL){
                                    listOfOppLineItemToInsert[0].PricebookEntryId = listOfPBE[0].id;
                                }
                                insert listOfOppLineItemToInsert;
                                System.debug('listOfOppLineItemToInsert: '+listOfOppLineItemToInsert);
                            }
                            if(!listOfOppLogToInsert.IsEmpty()){
                                relUtil.resolve('Opportunity_Log__c');
                                insert listOfOppLogToInsert;
                                System.debug('listOfOppLogToInsert: '+listOfOppLogToInsert);
                            }
                            /*if(!listOfPriceBookEntryToInsert.IsEmpty()){
                                relUtil.resolve('PricebookEntry');
                                insert listOfPriceBookEntryToInsert;
                                System.debug('listOfPriceBookEntryToInsert: '+listOfPriceBookEntryToInsert);
                            }*/
                            if(!hasError){
                                returnresponse = 'SUCCESS';
                                returnWrapper.isSuccess = True;
                            }
                        }
                        else{
                            returnresponse = 'Product Family is either blank or not a valid value.';
                        }
                    }
                    else{
                        // Log columnToObjectMapping or jsonMap empty which ideally shouldnt be.
                        returnresponse = 'Log columnToObjectMapping or jsonMap is blank.';
                    }
                }
                else{
                    returnresponse = 'There are no active product family values avaiable in the system.';
                }
            }
            else{
                //OppId or strfromle is Blank
                returnresponse = 'Opportunity ID is blank or row data is blank.';
            }
        }
        catch(Exception e){
            System.debug('Exception Message: '+e.getMessage());
            System.debug('Exception StacktraceSTring: '+e.getStackTraceString());
            returnresponse = e.getMessage();
            if(returnresponse.contains('Invalid date')){
                returnresponse = returnresponse +'. Column : '+errorColumnName +'. The correct format is dd/mm/yyyy.';
            }
            else if(returnresponse.contains('Invalid ')){
                returnresponse = returnresponse +'. Column : '+errorColumnName;
            }
            Database.rollback(sp);
        }
        returnWrapper.message = returnresponse;
        strfromle = strfromle.substring(0,strfromle.Length()-1) +',"Is Success":"'+returnWrapper.isSuccess+'","Message":"'+returnresponse+'"}';
        returnWrapper.eachRowAsString = strfromle;
        return returnWrapper;
    }
    /**
* @description : Check PriceBook is selected or not when clicking Upload Products Button.
* @author Bharatesh Shetty | 08-25-2021 
* @param OppId 
* @return string 
**/
    @AuraEnabled
    public static string CheckPriceBook(String OppId){
        /*String Returnvalue = '';
if(opp.Pricebook2Id == null ){
system.debug('opp.Pricebook2Id == null');
Returnvalue = 'ERROR';
}
else{
system.debug('SUCCESS');
Returnvalue = 'SUCCESS';
}*/
        String Returnvalue = 'ERROR';
        try{
            Opportunity opp =[select id,Pricebook2Id,name,Business_Unit__c from Opportunity where Id =:OppId];
            if(opp.Pricebook2Id == null ){
                String priceBookName;
                if(opp.Business_Unit__c == OpportunityConstants.OPPORTUNITY_BU_SPICES){
                    priceBookName = OpportunityConstants.OPPORTUNITY_BU_SPICES_PRICEBOOK_NAME;
                }
                else if(opp.Business_Unit__c == OpportunityConstants.OPPORTUNITY_BU_COCOA){
                    priceBookName = OpportunityConstants.OPPORTUNITY_BU_COCOA_PRICEBOOK_NAME;
                }
                else if(opp.Business_Unit__c == OpportunityConstants.OPPORTUNITY_BU_DAIRY){
                    priceBookName = OpportunityConstants.OPPORTUNITY_BU_DAIRY_PRICEBOOK_NAME;
                }
                else if(opp.Business_Unit__c == OpportunityConstants.OPPORTUNITY_BU_EDIBLE_NUTS){
                    priceBookName = OpportunityConstants.OPPORTUNITY_BU_EDIBLE_NUTS_PRICEBOOK_NAME;
                }
                else{
                    priceBookName = OpportunityConstants.OPPORTUNITY_BU_STANDARD_PRICEBOOK_NAME;
                }
                if(String.isNotBlank(priceBookName)){
                    List<Pricebook2> listOfPB = new List<Pricebook2>();
                    listOfPB = [Select id,Name FROM PriceBook2 where Name =: priceBookName limit 1];
                    if(!listOfPB.isEmpty()){
                        opp.Pricebook2Id = listOfPB[0].Id;
                        update opp;
                        Returnvalue = 'SUCCESS';
                    } 
                }
            }
            else{
                Returnvalue = 'SUCCESS';
            }
        }
        catch(Exception e){
            Returnvalue = 'ERROR';
        }
        system.debug('Returnvalue:'+Returnvalue);
        return Returnvalue;
    }
    /**
* @description : To check the required fields
* @author Bharatesh Shetty | 08-25-2021 
* @param headers 
* @return string 
**/
    /*@AuraEnabled
    public static string checkrequiredfields(){
        //system.debug('headers:'+headers);
        String Returnvalue = '';
        boolean contains = false;
        boolean isFailed = false;
        
        for(TenderTemplateConfig__mdt t:[select TenderTemplate_column_Name__c from TenderTemplateConfig__mdt where Is_Required__c = true] ){
            
            Returnvalue += t.TenderTemplate_column_Name__c+', ';
        }
        
        
        system.debug('Returnvalue:'+Returnvalue);
        return Returnvalue;
    }*/
    
    @AuraEnabled
    public static Map<String,TenderTemplateConfig__mdt> getTenderMetadatDetails(){
        
        Map<String,TenderTemplateConfig__mdt> returnMap = new Map<String,TenderTemplateConfig__mdt>();
        for(TenderTemplateConfig__mdt mdtRec:[select id,TenderTemplate_column_Name__c,Is_Required__c from TenderTemplateConfig__mdt] ){
            returnMap.put(mdtRec.TenderTemplate_column_Name__c,mdtRec);
        }
        
        system.debug('returnMap:'+returnMap);
        return returnMap;
    }
    
    /**
* @description : To create a Product instance
* @author Bharatesh Shetty | 08-25-2021 
* @param returnProduct 
* @param columnToObjectMapping 
* @param myMaps 
* @return Product2 
**/
    Public static Product2 createProduct(Product2 returnProduct,Map<string,TenderTemplateConfig__mdt> columnToObjectMapping,Map<String, Object> myMaps){
        //Product2 returnProduct;
        Boolean isProductInstanceNull = True;
        if(!columnToObjectMapping.isEmpty() && !myMaps.isEmpty()){
            for(String columnName :columnToObjectMapping.KeySet()){
                if(columnToObjectMapping.get(columnName).Object__C.equalsIgnoreCase('PRODUCT')){//Use a Custom Label
                    if(myMaps.ContainsKey(columnName)){
                        if(myMaps.get(columnName) != Null && myMaps.get(columnName) !=''){
                            if(isProductInstanceNull){
                                isProductInstanceNull = false;
                            }
                            errorColumnName = columnName;
                            if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('STRING') || columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('RELATIONSHIP') ){
                                returnProduct.put(columnToObjectMapping.get(columnName).Field_API_Name__c,STRING.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('INTEGER')){
                                returnProduct.put(columnToObjectMapping.get(columnName).Field_API_Name__c,INTEGER.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DOUBLE')){
                                returnProduct.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DOUBLE.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DATETIME')){
                                if(STRING.valueOf(myMaps.get(columnName))!=Null && STRING.valueOf(myMaps.get(columnName))!=''){
                                    returnProduct.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DATETIME.parse(STRING.valueOf(myMaps.get(columnName))));
                                }
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DATE')){
                                if(STRING.valueOf(myMaps.get(columnName))!=Null && STRING.valueOf(myMaps.get(columnName))!=''){
                                    returnProduct.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DATE.parse(STRING.valueOf(myMaps.get(columnName))));
                                }
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('BOOLEAN')){
                                returnProduct.put(columnToObjectMapping.get(columnName).Field_API_Name__c,BOOLEAN.valueOf(myMaps.get(columnName)));
                            }
                        }
                    }
                }
            }
        }
        if(isProductInstanceNull){
            returnProduct = Null;
        }
        if(returnProduct !=Null && !String.isBlank(returnProduct.Name) && returnProduct.Name.Length()>80){
            returnProduct.Name = returnProduct.Name.substring(0, 80);
        }
        return returnProduct;
    }
    /**
* @description :To create a PriceBookEntry instance
* @author Bharatesh Shetty | 08-25-2021 
* @param Pricebook2Id 
* @param productId 
* @param columnToObjectMapping 
* @param myMaps 
* @return PriceBookEntry 
**/
    /*Public static PriceBookEntry createPriceBookEntry(Id Pricebook2Id,Id productId,Map<string,TenderTemplateConfig__mdt> columnToObjectMapping,Map<String, Object> myMaps){
        PriceBookEntry returnPBE = new PriceBookEntry();
        returnPBE.Pricebook2Id = Pricebook2Id;
        returnPBE.UnitPrice = 1; //Hardcoded for now
        returnPBE.IsActive = true; //Hardcoded for now
        returnPBE.UseStandardPrice = false; //Hardcoded for now
        returnPBE.Product2Id = productId;
        if(!columnToObjectMapping.isEmpty() && !myMaps.isEmpty()){
            for(String columnName :columnToObjectMapping.KeySet()){
                if(columnToObjectMapping.get(columnName).Object__C.equalsIgnoreCase('PRICEBOOKENTRY')){//Use a Custom Label
                    if(myMaps.ContainsKey(columnName)){
                        if(myMaps.get(columnName) != Null && myMaps.get(columnName) !=''){
                            errorColumnName = columnName;
                            if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('STRING') || columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('RELATIONSHIP') ){
                                returnPBE.put(columnToObjectMapping.get(columnName).Field_API_Name__c,STRING.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('INTEGER')){
                                returnPBE.put(columnToObjectMapping.get(columnName).Field_API_Name__c,INTEGER.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DOUBLE')){
                                returnPBE.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DOUBLE.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DATETIME')){
                                if(STRING.valueOf(myMaps.get(columnName))!=Null && STRING.valueOf(myMaps.get(columnName))!=''){
                                    returnPBE.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DATETIME.parse(STRING.valueOf(myMaps.get(columnName))));
                                }
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DATE')){
                                if(STRING.valueOf(myMaps.get(columnName))!=Null && STRING.valueOf(myMaps.get(columnName))!=''){
                                    returnPBE.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DATE.parse(STRING.valueOf(myMaps.get(columnName))));
                                }
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('BOOLEAN')){
                                returnPBE.put(columnToObjectMapping.get(columnName).Field_API_Name__c,BOOLEAN.valueOf(myMaps.get(columnName)));
                            }
                        }
                    }
                }
            }
        }
        return returnPBE;
    }*/
    /**
* @description :To create an Opportunity Line Item instance
* @author Bharatesh Shetty | 08-25-2021 
* @param PricebookEntryId 
* @param productId 
* @param OpportunityId 
* @param columnToObjectMapping 
* @param myMaps 
* @return OpportunityLineItem 
**/
    Public static OpportunityLineItem createOpportunityLineItem(/*Id PricebookEntryId, */Id productId, Id OpportunityId,Map<string,TenderTemplateConfig__mdt> columnToObjectMapping,Map<String, Object> myMaps){
        System.debug('myMaps : '+myMaps);
        OpportunityLineItem returnOppLineItem = new OpportunityLineItem();
        //returnOppLineItem.PricebookEntryId = PricebookEntryId;
        returnOppLineItem.OpportunityId = OpportunityId;
        returnOppLineItem.Product2Id = productId;
        returnOppLineItem.Quantity = 1; //Hardcoded for now 
        //returnOppLineItem.UnitPrice = 100; //Hardcoded for now 
        if(!columnToObjectMapping.isEmpty() && !myMaps.isEmpty()){
            for(String columnName :columnToObjectMapping.KeySet()){
                if(columnToObjectMapping.get(columnName).Object__C.equalsIgnoreCase('OPPORTUNITYLINEITEM')){//Use a Custom Label
                    if(myMaps.ContainsKey(columnName)){
                        if(myMaps.get(columnName) != Null && myMaps.get(columnName) !=''){
                            System.debug('columnName :'+columnName);
                            System.debug('myMaps.get(columnName) :'+myMaps.get(columnName));
                            errorColumnName = columnName;
                            if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('STRING') || columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('RELATIONSHIP') ){
                                returnOppLineItem.put(columnToObjectMapping.get(columnName).Field_API_Name__c,STRING.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('INTEGER')){
                                returnOppLineItem.put(columnToObjectMapping.get(columnName).Field_API_Name__c,INTEGER.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DOUBLE')){
                                returnOppLineItem.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DOUBLE.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DATETIME')){
                                if(STRING.valueOf(myMaps.get(columnName))!=Null && STRING.valueOf(myMaps.get(columnName))!=''){
                                    returnOppLineItem.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DATETIME.parse(STRING.valueOf(myMaps.get(columnName))));
                                }
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DATE')){
                                if(STRING.valueOf(myMaps.get(columnName))!=Null && STRING.valueOf(myMaps.get(columnName))!=''){
                                    returnOppLineItem.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DATE.parse(STRING.valueOf(myMaps.get(columnName))));
                                }
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('BOOLEAN')){
                                returnOppLineItem.put(columnToObjectMapping.get(columnName).Field_API_Name__c,BOOLEAN.valueOf(myMaps.get(columnName)));
                            }
                        }
                    }
                }
            }
        }
        return returnOppLineItem;
    }
    /**
* @description : To create an Opportunity Log instance
* @author Bharatesh Shetty | 08-25-2021 
* @param productId 
* @param OpportunityId 
* @param columnToObjectMapping 
* @param myMaps 
* @return Opportunity_Log__C 
**/
    Public static Opportunity_Log__C createOpportunityLog(Product2 productRecord, id OpportunityId,Map<string,TenderTemplateConfig__mdt> columnToObjectMapping,Map<String, Object> myMaps){
        Opportunity_Log__C returnOppLog = new Opportunity_Log__C();
        returnOppLog.Name = productRecord.Name;
        returnOppLog.OpportunityID__c = OpportunityId;
        returnOppLog.Product2Id__c = productRecord.Id; 
        returnOppLog.Action__c = OpportunityLogConstants.ACTION_NOT_OFFERED_BY_OLAM ;
        if(!columnToObjectMapping.isEmpty() && !myMaps.isEmpty()){
            for(String columnName :columnToObjectMapping.KeySet()){
                if(columnToObjectMapping.get(columnName).Object__C.equalsIgnoreCase('OPPORTUNITY_LOG__C')){//Use a Custom Label
                    if(myMaps.ContainsKey(columnName)){
                        if(myMaps.get(columnName) != Null && myMaps.get(columnName) !=''){
                            errorColumnName = columnName;
                            if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('STRING') || columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('RELATIONSHIP') ){
                                returnOppLog.put(columnToObjectMapping.get(columnName).Field_API_Name__c,STRING.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('INTEGER')){
                                returnOppLog.put(columnToObjectMapping.get(columnName).Field_API_Name__c,INTEGER.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DOUBLE')){
                                returnOppLog.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DOUBLE.valueOf(myMaps.get(columnName)));
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DATETIME')){
                                if(STRING.valueOf(myMaps.get(columnName))!=Null && STRING.valueOf(myMaps.get(columnName))!=''){
                                    returnOppLog.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DATETIME.parse(STRING.valueOf(myMaps.get(columnName))));
                                }
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('DATE')){
                                if(STRING.valueOf(myMaps.get(columnName))!=Null && STRING.valueOf(myMaps.get(columnName))!=''){
                                    returnOppLog.put(columnToObjectMapping.get(columnName).Field_API_Name__c,DATE.parse(STRING.valueOf(myMaps.get(columnName))));
                                }
                            }
                            else if(columnToObjectMapping.get(columnName).DataType__C.equalsIgnoreCase('BOOLEAN')){
                                returnOppLog.put(columnToObjectMapping.get(columnName).Field_API_Name__c,BOOLEAN.valueOf(myMaps.get(columnName)));
                            }
                        }
                    }
                }
            }
        }
        return returnOppLog;
    }
    Public Class ReturnResponseWrapper{
        @AuraEnabled
        Public Boolean isSuccess {get;set;}
        @AuraEnabled
        Public String eachRowAsString{get;set;}
        @AuraEnabled
        Public String message {get;set;}
    }  
}