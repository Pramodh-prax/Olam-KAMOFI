public with sharing class AddQuoteLineItemsController {
    Public static final String PRODCONFIGSOURCE_APPROVED_SKU = 'Approved SKU';
    Public static final String PRODCONFIGSOURCE_SAP_INTEGRATION = 'SAP Integration';
    Public static final String PRODCONFIGSOURCE_PRODUCT_CONFIG_MASTER = 'Product Config Master';
    
    public AddQuoteLineItemsController() {
        
    }
    @AuraEnabled 
    public static List<LineItemWrapper> fetchLineItemWrapper(Id QuoteId, String searchKey, String category, String subCategory, String subCategory2, String brand, String family){ 
        System.debug('QuoteId: '+QuoteId);
        List<LineItemWrapper> lstLineItemWrapper = new List<LineItemWrapper>();
        List<PricebookEntry> listOfPBEQueried = new List<PricebookEntry>();
        String queryString = getQueryString('PricebookEntry');
        
        Quote quote = [SELECT Id, AccountId,Account.SAP_Account_ID__c, Opportunity.CurrencyIsoCode FROM Quote WHERE Id = :QuoteId];
        String parentOppCurrencyISOCode = quote.Opportunity.CurrencyIsoCode;
            
        Set<Id> productIdSet = new Set<Id>();
        if(String.isNotBlank(searchKey)){
            searchKey = searchKey.trim();
            String customerMaterialCode = '%'+searchKey+'%';
            for(Asset asst: [SELECT Id, Product2Id, Customer_Material_Code__c FROM Asset WHERE AccountId = :quote.AccountId AND Customer_Material_Code__c LIKE :customerMaterialCode]){
                productIdSet.add(asst.Product2Id);
            }
        }
        
        queryString += ' ,Product2.Name,Product2.External_Product_Code__c,toLabel(Product2.Family),Product2.Product_Category__c,Product2.Product_Sub_Category__c,Product2.Product_Sub_Category_2__c,Product2.Brand__C,Product2.Is_Product_Config_Required__c From PricebookEntry';
        queryString += ' where Pricebook2Id IN (select Pricebook2Id from Quote where Id = :QuoteId) and IsActive = true and CurrencyISOCode =: parentOppCurrencyISOCode';
        
        if(String.isNotBlank(searchKey)){
            searchKey = '%'+searchKey+'%';
            if(productIdSet.size() > 0){
                queryString +=  ' AND (Product2.Name LIKE: searchKey OR Product2.External_Product_Code__c LIKE: searchKey OR Product2Id IN :productIdSet ) ';
            }
            else{
                queryString +=  ' AND (Product2.Name LIKE: searchKey OR Product2.External_Product_Code__c LIKE: searchKey ) ';
            }
        }
        
        if(String.isNotBlank(family)){
            queryString +=  ' AND Product2.Family = :family ';
        }
        
        if(String.isNotBlank(category)){
            queryString +=  ' AND Product2.Product_Category__c = :category ';
        }
        
        if(String.isNotBlank(subCategory)){
            queryString +=  ' AND Product2.Product_Sub_Category__c = :subCategory ';
        }
        
        if(String.isNotBlank(subCategory2)){
            queryString +=  ' AND Product2.Product_Sub_Category_2__c = :subCategory2 ';
        }
        
        if(String.isNotBlank(brand)){
            queryString +=  ' AND Product2.Brand__C = :brand ';
        }
        
        queryString += ' order by Product2.Name asc LIMIT 100';
        //FOR TEST. Will be commented later
        //queryString += ' order by CreatedDate asc LIMIT 100';
        
        System.debug('queryString: '+queryString);
        listOfPBEQueried = Database.query(queryString);
        
        Map<Id, Asset> assetsMap = new Map<Id, Asset>();
        for(Asset asst: [SELECT Id, Product2Id, Customer_Material_Code__c FROM Asset WHERE AccountId = :quote.AccountId]){
            assetsMap.put(asst.Product2Id, asst);
        }
        
        if(!listOfPBEQueried.isEmpty()){
            for(PricebookEntry pbe : listOfPBEQueried){
                String customerMaterialCode = assetsMap.containsKey(pbe.Product2Id) ? assetsMap.get(pbe.Product2Id).Customer_Material_Code__c : '';
                //List<ProductConfigWrapper> listOfProductConfigWrapper = new List<ProductConfigWrapper>();
                List<ProductConfigWrapperFinal> listOfProductConfigWrapperFinal = new List<ProductConfigWrapperFinal>();
                lstLineItemWrapper.add(new LineItemWrapper(false,pbe, customerMaterialCode,listOfProductConfigWrapperFinal,quote));
                
            }
        }
        return lstLineItemWrapper; 
    }
    @AuraEnabled 
    public static List<LineItemWrapper> fetchProductConfigForSelectedProducts(Id QuoteId, List<LineItemWrapper> lstLineItemWrapper, Boolean shouldFecthProductConfig){
        if(String.isNotBlank(QuoteId) && !lstLineItemWrapper.isEmpty()){
            
            Quote quote = [SELECT Id, AccountId,Account.SAP_Account_ID__c FROM Quote WHERE Id = :QuoteId];
            
            
            Set<ID> setOfProductIds = new Set<ID>();
            Map<String,ProductConfigMaster__c> mapOfProdIdVsProdConfigMaster = new Map<String,ProductConfigMaster__c>();
            Map<Id, Asset> assetsMap = new Map<Id, Asset>();
            
            //used for the API call to SAP to fetch product config where the config was not found in Approved SKU
            Map<String, LineItemWrapper> mapOfMaterialCodeVsWrapperToFetchSAPConfig = new Map<String, LineItemWrapper>();
            //
            Map<String, LineItemWrapper> mapOfProdIdVsWrapperToFetchMasterConfig = new Map<String, LineItemWrapper>();
            
            List<ProductConfigRequestWrapper> listOfProductConfigRequestWrapper = new List<ProductConfigRequestWrapper>();
            
            //Construct Set of product Ids to query only the asset records for the selected products where product config is not yet fetched
            for(LineItemWrapper wrapper: lstLineItemWrapper){
                //added as part of product config SAP integration changes
                if(wrapper.objPBE.Product2.Is_Product_Config_Required__c && !wrapper.isProdConfigFetched){
                    setOfProductIds.add(wrapper.objPBE.Product2Id);
                }
            }
            
            //Construct map of ProductConfigMaster__c for the selected products where product config is not yet fetched
            for(ProductConfigMaster__c prodConfigMaster : [Select id,Product__c,Product_Configuration__c from ProductConfigMaster__c where Product__c =: setOfProductIds]){
                if(String.isNotBlank(prodConfigMaster.Product__c)){
                    mapOfProdIdVsProdConfigMaster.put(prodConfigMaster.Product__c,prodConfigMaster);
                }
            }
            
            //Construct map of Asset (Approved SKU) for the selected products where product config is not yet fetched
            for(Asset assetRec: [SELECT Id, Product2Id, Customer_Material_Code__c,Product_Configuration__c FROM Asset WHERE AccountId = :quote.AccountId and Product2Id =: setOfProductIds]){
                assetsMap.put(assetRec.Product2Id, assetRec);
            }
            
            // Check for Fetching the product config from Approved SKU if available
            for(LineItemWrapper wrapper: lstLineItemWrapper){
                List<ProductConfigSAPWrapper> listOfProductConfigSAPWrapper = new List<ProductConfigSAPWrapper>();
                List<ProductConfigSAPWrapper.ProductConfigWrapper> listOfProductConfigWrapper = new List<ProductConfigSAPWrapper.ProductConfigWrapper>();
                List<ProductConfigWrapperFinal> listOfProductConfigWrapperFinal = new List<ProductConfigWrapperFinal>();
                
                if(setOfProductIds.contains(wrapper.objPBE.Product2Id)){
                    //If setOfProductIds contains the product id it means that the product config is needed and not yet fetched
                    if(mapOfProdIdVsProdConfigMaster.containsKey(wrapper.objPBE.Product2Id)){
                        //If it is required, then see if the product config is present in the Approved SKU
                        if(assetsMap.containsKey(wrapper.objPBE.Product2Id) && String.isNotBlank(assetsMap.get(wrapper.objPBE.Product2Id).Product_Configuration__c) && assetsMap.get(wrapper.objPBE.Product2Id).Product_Configuration__c != 'N/A'){
                            //Parse the json in approved SKU to List<ProductConfigSAPWrapper>
                            listOfProductConfigSAPWrapper = (List<ProductConfigSAPWrapper>) JSON.deserialize(assetsMap.get(wrapper.objPBE.Product2Id).Product_Configuration__c,List<ProductConfigSAPWrapper>.class);
                            if(!listOfProductConfigSAPWrapper.isEmpty()){
                                //Take the 1st elemet in the list as one product will have only one configuration in appoved SKU
                                ProductConfigSAPWrapper prodConfigSAPWrapper = listOfProductConfigSAPWrapper[0];
                                if(!prodConfigSAPWrapper.configurations.isEmpty()){
                                    //If the configurations (List of ProductConfigWrapper inner class) variabe of ProductConfigSAPWrapper is not empty
                                    //Iterate and construct the listOfProductConfigWrapperFinal to copy the customer range to new range
                                    for(ProductConfigSAPWrapper.ProductConfigWrapper prodConfigWrapper : prodConfigSAPWrapper.configurations){
                                        ProductConfigWrapperFinal prodConfigWrapperFinal = new ProductConfigWrapperFinal();
                                        
                                        prodConfigWrapperFinal.prodConfigFinal = prodConfigWrapper;
                                        //prodConfigWrapperFinal.new_range = prodConfigWrapper.customer_range;
                                        prodConfigWrapperFinal.new_range = String.isNotBlank(prodConfigWrapper.customer_range) ? prodConfigWrapper.customer_range : prodConfigWrapper.olam_range;
                                        
                                        listOfProductConfigWrapperFinal.add(prodConfigWrapperFinal);
                                        //System.debug('prodConfigWrapperFinal: '+prodConfigWrapperFinal);
                                    }
                                    
                                    //Once config is fetched mark it as fetched and add the list to the wrapper instance
                                    wrapper.listOfProductConfigWrapperFinal = listOfProductConfigWrapperFinal;
                                    wrapper.isProdConfigFetched = true;
                                    wrapper.prodConfigSource = PRODCONFIGSOURCE_APPROVED_SKU; //Constant variable
                                    
                                    //remove the current product's Id from the setOfProductIds once the product config is fetched and added for current product
                                    setOfProductIds.remove(wrapper.objPBE.Product2Id);
                                }
                            }
                        } 
                        
                        if(!wrapper.isProdConfigFetched && String.isNotBlank(wrapper.objPBE.Product2.External_Product_Code__c)){
                            mapOfMaterialCodeVsWrapperToFetchSAPConfig.put(wrapper.objPBE.Product2.External_Product_Code__c,wrapper);
                            
                            ProductConfigRequestWrapper reqWrapper = new ProductConfigRequestWrapper();
                            reqWrapper.customer_sap_id = String.isNotBlank(quote.Account.SAP_Account_ID__c) ? quote.Account.SAP_Account_ID__c :'';
                            reqWrapper.customer_material_code = String.isNotBlank(wrapper.customerMaterialCode) ? wrapper.customerMaterialCode : wrapper.customerMaterialCodeUserInput;
                            reqWrapper.olam_material_code = wrapper.objPBE.Product2.External_Product_Code__c;
                            
                            listOfProductConfigRequestWrapper.add(reqWrapper);
                        }
                    }
                }
            }
            
            //Check for fetching the product config from SAP by making an API callout if not avaialabe in Approved SKU
            if(!setOfProductIds.isEmpty() && !mapOfMaterialCodeVsWrapperToFetchSAPConfig.isEmpty() && !listOfProductConfigRequestWrapper.isEmpty()){
                Map<String, List<ProductConfigSAPWrapper.ProductConfigWrapper>> mapOfOlamMatCodeVsListOfProdConfigWrapperFromSAP = new Map<String, List<ProductConfigSAPWrapper.ProductConfigWrapper>>();
                //Make a callOut to SAP to fetch the product config for the products which does not have product config in approved SKU
                mapOfOlamMatCodeVsListOfProdConfigWrapperFromSAP = CallOutToSAPToFetchProductConfig(Json.serialize(listOfProductConfigRequestWrapper));
                
                //if(!mapOfOlamMatCodeVsListOfProdConfigWrapperFromSAP.isEmpty()){
                for(String olamMaterialCode : mapOfMaterialCodeVsWrapperToFetchSAPConfig.keySet()){
                    
                    LineItemWrapper wrapper = mapOfMaterialCodeVsWrapperToFetchSAPConfig.get(olamMaterialCode);
                    List<ProductConfigSAPWrapper.ProductConfigWrapper> listOfProductConfigWrapper = new List<ProductConfigSAPWrapper.ProductConfigWrapper>();
                    List<ProductConfigWrapperFinal> listOfProductConfigWrapperFinal = new List<ProductConfigWrapperFinal>();
                    
                    if(!mapOfOlamMatCodeVsListOfProdConfigWrapperFromSAP.isEmpty()){
                        if(mapOfOlamMatCodeVsListOfProdConfigWrapperFromSAP.containsKey(olamMaterialCode)){
                            if(!mapOfOlamMatCodeVsListOfProdConfigWrapperFromSAP.get(olamMaterialCode).isEmpty()){
                                //If the configurations (List of ProductConfigWrapper inner class) variabe of ProductConfigSAPWrapper is not empty
                                //Iterate and construct the listOfProductConfigWrapperFinal to copy the customer range to new range
                                for(ProductConfigSAPWrapper.ProductConfigWrapper prodConfigWrapper : mapOfOlamMatCodeVsListOfProdConfigWrapperFromSAP.get(olamMaterialCode)){
                                    ProductConfigWrapperFinal prodConfigWrapperFinal = new ProductConfigWrapperFinal();
                                    
                                    prodConfigWrapperFinal.prodConfigFinal = prodConfigWrapper;
                                    //prodConfigWrapperFinal.new_range = prodConfigWrapper.customer_range;
                                    prodConfigWrapperFinal.new_range = String.isNotBlank(prodConfigWrapper.customer_range) ? prodConfigWrapper.customer_range : prodConfigWrapper.olam_range;
                                    
                                    listOfProductConfigWrapperFinal.add(prodConfigWrapperFinal);
                                    //System.debug('prodConfigWrapperFinal: '+prodConfigWrapperFinal);
                                }
                                
                                //Once config is fetched mark it as fetched and add the list to the wrapper instance
                                wrapper.listOfProductConfigWrapperFinal = listOfProductConfigWrapperFinal;
                                wrapper.isProdConfigFetched = true;
                                wrapper.prodConfigSource = PRODCONFIGSOURCE_SAP_INTEGRATION; //Constant variable
                                
                                //remove the current product's Id from the setOfProductIds once the product config is fetched and added for current product
                                setOfProductIds.remove(wrapper.objPBE.Product2Id);
                            }
                        }
                    }
                    if(!wrapper.isProdConfigFetched){
                        mapOfProdIdVsWrapperToFetchMasterConfig.put(wrapper.objPBE.Product2Id,wrapper);
                    }
                }
            }
            
            //Check for fetching the product config from Product Config Master table if not available in Approved SKU as well as in Product Config Master
            if(!setOfProductIds.isEmpty() && !mapOfProdIdVsWrapperToFetchMasterConfig.isEmpty() ){
                for(LineItemWrapper wrapper: mapOfProdIdVsWrapperToFetchMasterConfig.Values()){
                    List<ProductConfigSAPWrapper> listOfProductConfigSAPWrapper = new List<ProductConfigSAPWrapper>();
                    List<ProductConfigSAPWrapper.ProductConfigWrapper> listOfProductConfigWrapper = new List<ProductConfigSAPWrapper.ProductConfigWrapper>();
                    List<ProductConfigWrapperFinal> listOfProductConfigWrapperFinal = new List<ProductConfigWrapperFinal>();
                    if(mapOfProdIdVsProdConfigMaster.containsKey(wrapper.objPBE.Product2Id)){
                        if(String.isNotBlank(mapOfProdIdVsProdConfigMaster.get(wrapper.objPBE.Product2Id).Product_Configuration__c)){
                            //Parse the json in Product config master to List<ProductConfigSAPWrapper>
                            listOfProductConfigSAPWrapper = (List<ProductConfigSAPWrapper>) JSON.deserialize(mapOfProdIdVsProdConfigMaster.get(wrapper.objPBE.Product2Id).Product_Configuration__c,List<ProductConfigSAPWrapper>.class);
                            if(!listOfProductConfigSAPWrapper.isEmpty()){
                                //Take the 1st elemet in the list as one product will have only one configuration in Product config master
                                ProductConfigSAPWrapper prodConfigSAPWrapper = listOfProductConfigSAPWrapper[0];
                                if(!prodConfigSAPWrapper.configurations.isEmpty()){
                                    //If the configurations (List of ProductConfigWrapper inner class) variabe of ProductConfigSAPWrapper is not empty
                                    //Iterate and construct the listOfProductConfigWrapperFinal to copy the customer range to new range
                                    for(ProductConfigSAPWrapper.ProductConfigWrapper prodConfigWrapper : prodConfigSAPWrapper.configurations){
                                        ProductConfigWrapperFinal prodConfigWrapperFinal = new ProductConfigWrapperFinal();
                                        
                                        prodConfigWrapperFinal.prodConfigFinal = prodConfigWrapper;
                                        //prodConfigWrapperFinal.new_range = prodConfigWrapper.customer_range;
                                        prodConfigWrapperFinal.new_range = String.isNotBlank(prodConfigWrapper.customer_range) ? prodConfigWrapper.customer_range : prodConfigWrapper.olam_range;
                                        
                                        listOfProductConfigWrapperFinal.add(prodConfigWrapperFinal);
                                        //System.debug('prodConfigWrapperFinal: '+prodConfigWrapperFinal);
                                    }
                                    
                                    //Once config is fetched mark it as fetched and add the list to the wrapper instance
                                    wrapper.listOfProductConfigWrapperFinal = listOfProductConfigWrapperFinal;
                                    wrapper.isProdConfigFetched = true;
                                    wrapper.prodConfigSource = PRODCONFIGSOURCE_PRODUCT_CONFIG_MASTER; //Constant variable
                                }
                            }
                        }
                    }
                }
            }
        }
        //System.debug('lstLineItemWrapper * fetchProductConfigForSelectedProducts: '+lstLineItemWrapper);
        return lstLineItemWrapper;
    }
    
    //Old method Commented as part of product config SAP integration changes
    /*@AuraEnabled 
    public static List<LineItemWrapper> fetchProductConfigForSelectedProducts(Id QuoteId, List<LineItemWrapper> lstLineItemWrapper, Boolean shouldFecthProductConfig){
        if(String.isNotBlank(QuoteId) && !lstLineItemWrapper.isEmpty()){
            
            Quote quote = [SELECT Id, AccountId FROM Quote WHERE Id = :QuoteId];
            
            //Construct Set of product Ids to query only the asset records for the selected products
            Set<ID> setOfProductIds = new Set<ID>();
            Set<String> setOfProdCategory = new Set<String>();
            Set<String> setOfProdSubCategory = new Set<String>();
            Set<String> setOfProdSubCategory2 = new Set<String>();
            //setOfProdSubCategory2.add('');
            for(LineItemWrapper wrapper: lstLineItemWrapper){
                setOfProductIds.add(wrapper.objPBE.Product2Id);
                setOfProdCategory.add(wrapper.objPBE.Product2.Product_Category__c);
                setOfProdSubCategory.add(wrapper.objPBE.Product2.Product_Sub_Category__c);
                setOfProdSubCategory2.add(wrapper.objPBE.Product2.Product_Sub_Category_2__c);
            }
            
            String queryString = getQueryString('ProductConfigMaster__c');
            queryString += ' From ProductConfigMaster__c where Id != Null';
            if(!setOfProdCategory.isEmpty()){
                //System.debug('setOfProdCategory: '+setOfProdCategory);
                queryString += ' and Product_Category__c =: setOfProdCategory';
            }
            if(!setOfProdSubCategory.isEmpty()){
                //System.debug('setOfProdSubCategory: '+setOfProdSubCategory);
                queryString += ' and Product_Sub_Category__c =: setOfProdSubCategory';
            }
            if(!setOfProdSubCategory2.isEmpty()){
                //System.debug('setOfProdSubCategory2: '+setOfProdSubCategory2);
                queryString += ' and Product_Sub_Category_2__c =: setOfProdSubCategory2';
            }
            
            Map<String,ProductConfigMaster__c> mapOfConcatStringVsProdConfigMaster = new Map<String,ProductConfigMaster__c>();
            
            for(ProductConfigMaster__c prodConfigMaster : Database.query(queryString)){
                System.debug('prodConfigMaster: '+prodConfigMaster);
                String concatenatedKey ='';
                
                if(String.isNotBlank(prodConfigMaster.Product_Category__c)){
                    concatenatedKey += prodConfigMaster.Product_Category__c;
                }
                
                if(String.isNotBlank(prodConfigMaster.Product_Sub_Category__c)){
                    concatenatedKey += prodConfigMaster.Product_Sub_Category__c;
                }
                
                if(String.isNotBlank(prodConfigMaster.Product_Sub_Category_2__c)){
                    concatenatedKey += prodConfigMaster.Product_Sub_Category_2__c;
                }
                //System.debug('concatenatedKey1: '+concatenatedKey);
                if(String.isNotBlank(concatenatedKey)){
                    mapOfConcatStringVsProdConfigMaster.put(concatenatedKey,prodConfigMaster);
                    //System.debug('mapOfConcatStringVsProdConfigMaster: '+mapOfConcatStringVsProdConfigMaster);
                }
            }
            
            Map<Id, Asset> assetsMap = new Map<Id, Asset>();
            for(Asset assetRec: [SELECT Id, Product2Id, Customer_Material_Code__c,Product_Configuration__c FROM Asset WHERE AccountId = :quote.AccountId and Product2Id =: setOfProductIds]){
                assetsMap.put(assetRec.Product2Id, assetRec);
            }
            
            for(LineItemWrapper wrapper: lstLineItemWrapper){
                List<ProductConfigWrapper> listOfProductConfigWrapper = new List<ProductConfigWrapper>();
                List<ProductConfigWrapperFinal> listOfProductConfigWrapperFinal = new List<ProductConfigWrapperFinal>();
                String concatenatedKey ='';
                
                if(String.isNotBlank(wrapper.objPBE.Product2.Product_Category__c)){
                    concatenatedKey += wrapper.objPBE.Product2.Product_Category__c;
                }
                if(String.isNotBlank(wrapper.objPBE.Product2.Product_Sub_Category__c)){
                    concatenatedKey += wrapper.objPBE.Product2.Product_Sub_Category__c;
                }
                if(String.isNotBlank(wrapper.objPBE.Product2.Product_Sub_Category_2__c)){
                    concatenatedKey += wrapper.objPBE.Product2.Product_Sub_Category_2__c;
                }
                
                //System.debug('concatenatedKey2: '+concatenatedKey);
                if(String.isNotBlank(concatenatedKey)){
                    //If the combination of Product category,sub category and sub category2 is found in the config that means it is required
                    if(mapOfConcatStringVsProdConfigMaster.containsKey(concatenatedKey)){
                        wrapper.isProductConfigRequired = true;
                        if(shouldFecthProductConfig){
                            //If it is required, then see if the product config is present in the Approved SKU
                            if(assetsMap.containsKey(wrapper.objPBE.Product2Id) && String.isNotBlank(assetsMap.get(wrapper.objPBE.Product2Id).Product_Configuration__c)){
                                listOfProductConfigWrapper = (List<ProductConfigWrapper>) JSON.deserialize(assetsMap.get(wrapper.objPBE.Product2Id).Product_Configuration__c,List<ProductConfigWrapper>.class);
                            } 
                            //If not found in the Approved SKU then get the default product config from the product config master record
                            else if(String.isNotBlank(mapOfConcatStringVsProdConfigMaster.get(concatenatedKey).Product_Configuration__c)){
                                listOfProductConfigWrapper = (List<ProductConfigWrapper>) JSON.deserialize(mapOfConcatStringVsProdConfigMaster.get(concatenatedKey).Product_Configuration__c,List<ProductConfigWrapper>.class);
                            }
                            if(!listOfProductConfigWrapper.isEmpty()){
                                for(ProductConfigWrapper prodConfigWrapper : listOfProductConfigWrapper){
                                    ProductConfigWrapperFinal prodConfigWrapperFinal = new ProductConfigWrapperFinal();
                                    
                                    prodConfigWrapperFinal.prodConfigFinal = prodConfigWrapper;
                                    prodConfigWrapperFinal.new_range = prodConfigWrapper.customer_range;
                                    
                                    listOfProductConfigWrapperFinal.add(prodConfigWrapperFinal);
                                    //System.debug('prodConfigWrapperFinal: '+prodConfigWrapperFinal);
                                }
                            }
                        }
                    }
                }
                //wrapper.listOfProductConfigWrapper = listOfProductConfigWrapper;
                if(shouldFecthProductConfig){
                    wrapper.listOfProductConfigWrapperFinal = listOfProductConfigWrapperFinal;
                    wrapper.isProdConfigFetched = true; 
                }
            }
        }
        //System.debug('lstLineItemWrapper * fetchProductConfigForSelectedProducts: '+lstLineItemWrapper);
        return lstLineItemWrapper;
    }*/
    
    @AuraEnabled
    public static String createQuoteLineItem(Id QuoteId, List<LineItemWrapper> lstLineItemWrapper)
    {
        User systeAdmin = [select id,email from User where  Profile.name = 'System Administrator' and IsActive=True limit 1];
        String returnResponse = 'OOOPS! Some error occurred. Please Contact System Admin. SYSTEM ADMIN EMAIL : '+systeAdmin.Email ;
        Savepoint sp = Database.setSavepoint();
        try{
            if(!lstLineItemWrapper.isEmpty() && QuoteId != Null){
                List<QuoteLineItem> listOfQuoteLineItemToInsert = new List<QuoteLineItem>();
                for(LineItemWrapper wrapper: lstLineItemWrapper){
                    //For each selected line item create a quote line item record under the parent quote record
                    QuoteLineItem qtLineItem = new QuoteLineItem();
                    
                    qtLineItem.QuoteId = QuoteId;
                    qtLineItem.PricebookEntryId = wrapper.objPBE.Id;
                    qtLineItem.Quantity = 1;
                    qtLineItem.unitPrice = wrapper.unitPrice;
                    qtLineItem.Volume__c = wrapper.volume;
                    qtLineItem.Unit_Of_Measure__c = wrapper.unitOfMeasure;
                    qtLineItem.Approval_Required__c = wrapper.isPLMApprovalRequired;
                    qtLineItem.Is_File_Uploaded__c = wrapper.isFileUploaded;
                    //Newly added as part of 
                    qtLineItem.Customer_Material_Code__c = String.isNotBlank(wrapper.customerMaterialCode) ? wrapper.customerMaterialCode : wrapper.customerMaterialCodeUserInput;
                    qtLineItem.Product_Config_Source__c =  wrapper.prodConfigSource;
                    
                    if(!wrapper.listOfProductConfigWrapperFinal.isEmpty()){
                        List<ProductConfigSAPWrapper> listOfProductConfigSAPWrapper = new List<ProductConfigSAPWrapper> ();
                        List<ProductConfigSAPWrapper.ProductConfigWrapper> listOfProductConfigWrapper = new List<ProductConfigSAPWrapper.ProductConfigWrapper>();
                        
                        for(ProductConfigWrapperFinal prodConfigWrapperFinal : wrapper.listOfProductConfigWrapperFinal){
                            ProductConfigSAPWrapper.ProductConfigWrapper prodConfigWrapper = new ProductConfigSAPWrapper.ProductConfigWrapper();
                            
                            prodConfigWrapper = prodConfigWrapperFinal.prodConfigFinal;
                            prodConfigWrapper.customer_range = prodConfigWrapperFinal.new_range;
                            
                            listOfProductConfigWrapper.add(prodConfigWrapper);
                        }
                        
                        ProductConfigSAPWrapper sapWrapper = new ProductConfigSAPWrapper();
                        sapWrapper.customer_sap_id = wrapper.accountSAPId;
                        sapWrapper.customer_material_code = String.isNotBlank(wrapper.customerMaterialCode) ? wrapper.customerMaterialCode : wrapper.customerMaterialCodeUserInput ;
                        sapWrapper.olam_material_code = wrapper.objPBE.Product2.External_Product_Code__c;
                        sapWrapper.configurations = listOfProductConfigWrapper;
                        
                        listOfProductConfigSAPWrapper.add(sapWrapper);
                        
                        qtLineItem.Product_Configuration__c = JSON.serialize(listOfProductConfigSAPWrapper);
                    }
                    
                    listOfQuoteLineItemToInsert.add(qtLineItem);
                }
                if(!listOfQuoteLineItemToInsert.isEmpty()){
                    System.debug('listOfQuoteLineItemToInsert: '+listOfQuoteLineItemToInsert);
                    insert listOfQuoteLineItemToInsert;
                    returnResponse = 'SUCCESS';
                }
            }
        }
        catch(Exception e){
            System.debug('Exception Message: '+e.getMessage());
            System.debug('Exception StacktraceSTring: '+e.getStackTraceString());
            String exceptionMessage = '';
            if(e.getMessage().containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') && e.getMessage().containsIgnoreCase(': [')){
                exceptionMessage = e.getMessage().subStringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': [');
            }
            else{
                exceptionMessage = e.getMessage();
            }
            returnresponse = exceptionMessage;
            //returnresponse ='Divided by zero. Error';
            Database.rollback(sp);
        }
        System.debug('returnResponse: '+returnResponse);
        return returnResponse;
    }
    
    @AuraEnabled
    public static List<PriceBook2> getPriceBooks(Id QuoteId)
    {
        Boolean quoteAlreadyHasPricebook = False;
        List<PriceBook2> returnList = new List<PriceBook2>();
        List<Quote> listOfQuote = new List<Quote>();
        listOfQuote = [Select id,PriceBook2Id,Opportunity.Business_Unit__c 
                       from Quote 
                       where id=: QuoteId];
        if(!listOfQuote.isEmpty()){
            if(listOfQuote[0].PriceBook2Id != Null){
                quoteAlreadyHasPricebook = true;
            }
        }
        if(!quoteAlreadyHasPricebook){
            //returnList = [SELECT Id, Name from PriceBook2 ORDER BY Name];
            String priceBookName;
            if(listOfQuote[0].Opportunity.Business_Unit__c == OpportunityConstants.OPPORTUNITY_BU_SPICES){
                priceBookName = OpportunityConstants.OPPORTUNITY_BU_SPICES_PRICEBOOK_NAME;
            }
            else if(listOfQuote[0].Opportunity.Business_Unit__c == OpportunityConstants.OPPORTUNITY_BU_COCOA){
                priceBookName = OpportunityConstants.OPPORTUNITY_BU_COCOA_PRICEBOOK_NAME;
            }
            else if(listOfQuote[0].Opportunity.Business_Unit__c == OpportunityConstants.OPPORTUNITY_BU_DAIRY){
                priceBookName = OpportunityConstants.OPPORTUNITY_BU_DAIRY_PRICEBOOK_NAME;
            }
            else if(listOfQuote[0].Opportunity.Business_Unit__c == OpportunityConstants.OPPORTUNITY_BU_EDIBLE_NUTS){
                priceBookName = OpportunityConstants.OPPORTUNITY_BU_EDIBLE_NUTS_PRICEBOOK_NAME;
            }
            else{
                priceBookName = OpportunityConstants.OPPORTUNITY_BU_STANDARD_PRICEBOOK_NAME;
            }
            if(String.isNotBlank(priceBookName)){
                returnList = [Select id,Name FROM PriceBook2 where Name =: priceBookName limit 1];
            }
        }
        return returnList;
    }
    @AuraEnabled
    public static Boolean updateQuotePriceBook(Id QuoteId, String priceBookId)
    {
        Boolean isPricebookUpdated = false;
        try{
            Quote quoteToUpdate = new Quote(id = QuoteId, PriceBook2Id = priceBookId);
            update quoteToUpdate;
            isPricebookUpdated = true;
        }
        catch(Exception e){
            
        }
        return isPricebookUpdated;
    }
    
    
    @AuraEnabled
    public static List<String> getIsApprovalRequiredValues(Id QuoteId)
    {
        //Boolean quoteAlreadyHasPricebook = False;
        List<String> returnList = new List<String>();
        List<Quote> listOfQuote = new List<Quote>();
        listOfQuote = [Select id,Bussiness_Unit__c,Opportunity.Account.Regions__C,OpportunityId from Quote where id=: QuoteId];
        if(!listOfQuote.isEmpty()){
            if(String.isNotBlank(listOfQuote[0].Bussiness_Unit__c) && String.isNotBlank(listOfQuote[0].Opportunity.Account.Regions__C)){
                List<ApprovalRequiredControl__mdt> listOfApprovalRequiredControlMtdt = new List<ApprovalRequiredControl__mdt>();
                listOfApprovalRequiredControlMtdt = [Select id,Business_Unit__c,Region__c,Required__c 
                                                     From ApprovalRequiredControl__mdt
                                                     Where Business_Unit__c =: listOfQuote[0].Bussiness_Unit__c and Region__c =: listOfQuote[0].Opportunity.Account.Regions__C and Required__c = True];
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
    
    
    public static String getQueryString(String objectName){
        Map<String, Schema.SObjectType> objMap = new Map<String, Schema.SObjectType>();
        objMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = objMap.get(objectName).getDescribe().fields.getMap();
        string queryString = 'SELECT ';
        for(Schema.SObjectField field :fieldMap.values()){
            queryString = queryString + field.getDescribe().getName() + ', ';
        }
        queryString = queryString.substring(0,queryString.length() - 2);
        return queryString;
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
    
    public class LineItemWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public PricebookEntry objPBE{get;set;}
        @AuraEnabled public String customerMaterialCode{get;set;}
        @AuraEnabled public Double unitPrice{get;set;}
        @AuraEnabled public Double volume{get;set;}
        @AuraEnabled public String unitOfMeasure{get;set;}
        @AuraEnabled public String isPLMApprovalRequired{get;set;}
        @AuraEnabled public Boolean isProdConfigFetched{get;set;}
        @AuraEnabled public Boolean isFileUploaded{get;set;}
        @AuraEnabled public Boolean isProductConfigRequired{get;set;}
        @AuraEnabled public String customerMaterialCodeUserInput{get;set;}
        @AuraEnabled public String prodConfigSource{get;set;}
        @AuraEnabled public String accountSAPId{get;set;}
        //@AuraEnabled public String Name{get;set;}
        
        
        //@AuraEnabled public List<ProductConfigWrapper> listOfProductConfigWrapper{get;set;}
        @AuraEnabled public List<ProductConfigWrapperFinal> listOfProductConfigWrapperFinal{get;set;}
        @AuraEnabled public List<Id> listOfContentDocIds{get;set;}
        
        public LineItemWrapper(boolean isChecked, PricebookEntry objPBE, String customerMaterialCode, List<ProductConfigWrapperFinal> listOfProductConfigWrapperFinal, Quote quote){
            this.isChecked = isChecked;
            this.objPBE = objPBE;
            this.customerMaterialCode = customerMaterialCode;
            //this.listOfProductConfigWrapper = listOfProductConfigWrapper;
            this.listOfProductConfigWrapperFinal = listOfProductConfigWrapperFinal;
            //Commented as part of product config SAP integration changes (Added below)
            //this.isProdConfigFetched = false;
            this.isFileUploaded = false;
            this.listOfContentDocIds = new List<Id>();
            //Changed as a new field on product object as part of product config SAP integration changes
            //this.isProductConfigRequired = false;
            this.isProductConfigRequired = objPBE.Product2.Is_Product_Config_Required__c;
            //If the produt config is required then it will be fetched after UI clicks from user if not required them mark it as true so that unnecessary apex call is reduced
            this.isProdConfigFetched = objPBE.Product2.Is_Product_Config_Required__c ? false : true;
                
            this.customerMaterialCodeUserInput = '';
            this.accountSAPId = quote.Account.SAP_Account_ID__c;
            //this.Name = objPBE.Name;
        }
        public LineItemWrapper(){
        }
    }
    
    // Commented as part of product config SAP integration changes
    /*public class ProductConfigWrapper {
        @AuraEnabled public String mic {get;set;}
        @AuraEnabled public String varient_character_mapping {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String uom {get;set;}
        @AuraEnabled public String quantitative {get;set;}
        @AuraEnabled public String qualitative {get;set;}
        @AuraEnabled public String olam_range {get;set;}
        @AuraEnabled public String customer_range {get;set;}
        @AuraEnabled public String category {get;set;}
        //@AuraEnabled public String new_range {get;set;}
        
        public ProductConfigWrapper(){
        }
    }*/
    
    public class ProductConfigWrapperFinal {
         @AuraEnabled public ProductConfigSAPWrapper.ProductConfigWrapper prodConfigFinal {get;set;}
         @AuraEnabled public String new_range {get;set;}
    }
    
    public static Map<String, List<ProductConfigSAPWrapper.ProductConfigWrapper>> CallOutToSAPToFetchProductConfig(String requestBody) {
        System.debug('requestBody: '+requestBody);
        Map<String, List<ProductConfigSAPWrapper.ProductConfigWrapper>> mapOfOlamMatCodeVsListOfProdConfigWrapper = new Map<String, List<ProductConfigSAPWrapper.ProductConfigWrapper>>();
        try{
            if(String.isNotBlank(requestBody)){
                Map<String,Integration_Details__c> allEndPoint = Integration_Details__c.getAll();
                Integration_Details__c integrationDetail = allEndPoint.get('SAP Product Configuration');
                
                Blob headerValue = Blob.valueOf(integrationDetail.username__c + ':' + integrationDetail.password__c);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                
                
                Map<String,String> mapOfHeaders = new Map<String,String>();
                mapOfHeaders.put('authorization', authorizationHeader);
                mapOfHeaders.put('Content-Type', integrationDetail.content_Type__c);
                
                HttpResponse res = APICalloutsUtil.doAPICallOut(integrationDetail.Method__c, integrationDetail.Endpoint__c, mapOfHeaders, requestBody,Integer.valueOf(integrationDetail.timeOut__c));
                //boolean statusCode = false;
                if(res.getStatusCode() == 200)
                {
                    //Status code 200
                    System.debug('responsebody======>'+res.getBody());
                    String responseBody = '';
                    
                    //Commented now for testing purpose since API is not giving the response in proper format
                    responseBody = res.getBody();
                    
                    //Dummy response body added for testing purpose since API is not giving the response in proper format
                    //responseBody = '[{"customer_sap_id": "cust123","customer_material_code": "6642331","olam_material_code": "100000039073","configurations": [{"mic": "-U100","varient_character_mapping": "","description": "MOLD COUNT PER GRAM","uom": "%","quantitative": "Yes","qualitative": "","indicator": "Product","olam_range": "0,000 - 200,000","customer_range": ""}]}]';
                    if(String.isNotBlank(responseBody)){
                       System.debug('responseBody: '+responseBody);
                       String convertedResponseBody = productConfigIntermediateConvertor.sapJSONParse(responseBody);
                       System.debug('convertedResponseBody: '+convertedResponseBody);
                       List<ProductConfigSAPWrapper> listOfProductConfigSAPWrapper = new List<ProductConfigSAPWrapper>();
                       System.debug('listOfProductConfigSAPWrapper: '+listOfProductConfigSAPWrapper);
                       listOfProductConfigSAPWrapper = (List<ProductConfigSAPWrapper>) JSON.deserialize(convertedResponseBody,List<ProductConfigSAPWrapper>.class);
                        if(!listOfProductConfigSAPWrapper.isEmpty()){
                            for(ProductConfigSAPWrapper sapWrapper : listOfProductConfigSAPWrapper){
                                if(String.isNotBlank(sapWrapper.olam_material_code)){
                                    if(!sapWrapper.configurations.isEmpty()){
                                        mapOfOlamMatCodeVsListOfProdConfigWrapper.put(sapWrapper.olam_material_code,sapWrapper.configurations);
                                    }
                                }
                            }
                        }
                    }
                    else{
                        //Blank response Body
                    }
                }else{
                    //Status code not 200
                }
            }
        }
        catch(Exception e){
            System.debug('Exception Message: '+e.getMessage());
            System.debug('Exception StacktraceSTring: '+e.getStackTraceString());
        }
        System.debug('mapOfOlamMatCodeVsListOfProdConfigWrapper: '+mapOfOlamMatCodeVsListOfProdConfigWrapper);
        return mapOfOlamMatCodeVsListOfProdConfigWrapper;
        //Log the response/messages in error/else conditions
    }
    
    public class ProductConfigRequestWrapper {
        public String customer_sap_id {get;set;}
        public String customer_material_code {get;set;}
        public String olam_material_code {get;set;}
    }
    
    //Deserialize the prod config Json to List<ProductConfigWrapper>
    //Iterate over List<ProductConfigWrapper> and create ProductConfigWrapperFinal (prodConfig = each config in the list) with copying customer_range in ProductConfigWrapper to new_range of ProductConfigWrapperFinal
    //Add ProductConfigWrapperFinal to a list (List<ProductConfigWrapper>) and this will be used in UI to display and fetch the new range from UI
    //On save Iterate over List<ProductConfigWrapperFinal> and for each config copy the new range value to customer_range value of ProductConfigWrapper and add it to a new list<ProductConfigWrapper>
    //the new list<ProductConfigWrapper> will then be serialized and added in the quotelineItem as ProductConfig text field
}