public class ConsumptionTriggerHandler extends TriggerHandlerBase {
    
    public override void handleAfterInsert() {
        //Commented by Bharatesh as part of OFI
        //new OlamObjectSharing('Consumption__c', Trigger.new).addSharing();
        
        //Added by Bharatesh as part of OFI
        
        SharingObjectRecordsHandler.shareConsumptionsWithAccountTeams((Map<Id,Consumption__c>)Trigger.newMap);
        
        
    }
    
    public override void handleBeforeInsert() {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if( hasCustomPermission){
            
        }else{
            ConsumptionTriggerHandler.userPrivilageCheck((List<Consumption__c>)Trigger.New);
            
        }
        updateBudgetLineRef ((List<Consumption__c>) Trigger.new);
        
    }
    public override void handleBeforeUpdate() {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if( hasCustomPermission){
            
        }else{
            ConsumptionTriggerHandler.userPrivilageCheck((List<Consumption__c>)Trigger.New);
            
        }
        
        List <Consumption__c> consumptions = identifyCatSubCatChanges (
            (List<Consumption__c>)Trigger.new,  
            (Map<Id, Consumption__c>)Trigger.oldMap
        );
        if (!consumptions.isEmpty ()) {
            updateBudgetLineRef (consumptions);
        }
    }
    
    public void updateConsumptionRefs (List <Consumption__c> consumptions) {
        
        List<Consumption__c> consumptionUpdateList = new List<Consumption__c> ();
        for (Consumption__c eachConsumption : updateBudgetLineRef (consumptions)) {
            consumptionUpdateList.add (new Consumption__c (Id = eachConsumption.Id, Budget_vs_Actual_Line__c = eachConsumption.Budget_vs_Actual_Line__c));
        }
        if (!consumptionUpdateList.isEmpty ()) {
            Database.SaveResult [] results = Database.update(consumptionUpdateList, false);
            
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    //todo: handle error
                    System.debug('Errors :' + result.getErrors());
                }
            }
        }
    }
    
    private List <Consumption__c> identifyCatSubCatChanges (List<Consumption__c> newList, Map<Id, Consumption__c> oldMap) {
        
        List <Consumption__c> changedItems = new List<Consumption__c> ();
        
        for (Consumption__c eachLine : newList) {
            if (oldMap.containsKey (eachLine.Id)
                && 
                (
                    eachLine.Category__c != oldMap.get (eachLine.Id).Category__c
                    || eachLine.Sub_Category__c != oldMap.get (eachLine.Id).Sub_Category__c
                    || eachLine.Sub_Category_2__c != oldMap.get (eachLine.Id).Sub_Category_2__c
                )
               ) {
                   changedItems.add (eachLine);
               }
        }
        return changedItems;
    }
    
    private List<Consumption__c> updateBudgetLineRef (List<Consumption__c> records) {
        Map<String, List<Consumption__c>> consumptionsMap   = new Map<String, List<Consumption__c>> (); 
        Set<String> buTypes                                 = new Set<String> ();
        Set<String> categories                              = new Set<String> ();
        Set<String> subCategories                           = new Set<String> ();
        Set<String> subCategoriesTwo                        = new Set<String> ();
        Set<Id> accountIds                                  = new Set<Id> ();
        Set<String> years                         = new Set<String> ();
        
        for (Consumption__c eachConsumption : records) {
            String key = '';
            if (String.isNotBlank(eachConsumption.Account__c)) {
                key += eachConsumption.Account__c;
                accountIds.add (eachConsumption.Account__c);
            }
            if (String.isNotBlank(eachConsumption.Business_Unit__c)) {
                key += eachConsumption.Business_Unit__c;
                buTypes.add (eachConsumption.Business_Unit__c);
            }
            if (String.isNotBlank(eachConsumption.Year__c)) {
                key += eachConsumption.Year__c;
                years.add (eachConsumption.Year__c);
            }
            if (String.isNotBlank(eachConsumption.Category__c)) {
                key += eachConsumption.Category__c;
                categories.add(eachConsumption.Category__c);
            }
            if (String.isNotBlank(eachConsumption.Sub_Category__c)) {
                key += eachConsumption.Sub_Category__c;
                subCategories.add (eachConsumption.Sub_Category__c);
            }
            if (String.isNotBlank(eachConsumption.Sub_Category_2__c)) {
                key += eachConsumption.Sub_Category_2__c;
                subCategoriesTwo.add (eachConsumption.Sub_Category_2__c);
            }
            key = key.trim();
            
            if (consumptionsMap.containsKey (key)) {
                consumptionsMap.get (key).add (eachConsumption);
            } else {
                consumptionsMap.put (key, new List<Consumption__c> {eachConsumption});
            }
        }
        
        //        if (consumptionsMap.isEmpty ()) { return; }
        
        for (Budget_vs_Actual_Line__c eachLine : [
            SELECT Id, Actuals__c, Budget_vs_Actuals__c, Category__c, Sub_Category__c, 
            Sub_Category_2__c, Total_Consumption__c, Volume__c, 
            Budget_vs_Actuals__r.Account__c, Budget_vs_Actuals__r.Business_Unit__c,
            Budget_vs_Actuals__r.Year__c    
            FROM Budget_vs_Actual_Line__c
            WHERE Budget_vs_Actuals__r.Account__c IN : accountIds
            AND Budget_vs_Actuals__r.Business_Unit__c IN : buTypes
            AND Budget_vs_Actuals__r.Year__c IN : years
            //AND Category__c IN : categories
            //AND Sub_Category__c IN : subCategories
            //AND Sub_Category_2__c IN : subCategoriesTwo
            LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
        ]) {
            
            String key = '';
            if (String.isNotBlank(eachLine.Budget_vs_Actuals__r.Account__c)) {
                key += eachLine.Budget_vs_Actuals__r.Account__c;
            }
            if (String.isNotBlank(eachLine.Budget_vs_Actuals__r.Business_Unit__c)) {
                key += eachLine.Budget_vs_Actuals__r.Business_Unit__c;
            }
            if (String.isNotBlank(eachLine.Budget_vs_Actuals__r.Year__c)) {
                key += eachLine.Budget_vs_Actuals__r.Year__c;
            }
            if (String.isNotBlank(eachLine.Category__c)) {
                key += eachLine.Category__c;
            }
            if (String.isNotBlank(eachLine.Sub_Category__c)) {
                key += eachLine.Sub_Category__c;
            }
            if (String.isNotBlank(eachLine.Sub_Category_2__c)) {
                key += eachLine.Sub_Category_2__c;
            }
            key = key.trim();
            
            if (consumptionsMap.containsKey (key)) {
                for (Consumption__c  eachConsumption : consumptionsMap.get (key)) {
                    eachConsumption.Budget_vs_Actual_Line__c = eachLine.Id;
                }
                //removed because we need to identify if any of the records doesn't have any matching budget line. 
                //during updation for the given key combination, 
                consumptionsMap.remove (key);
            }
        }
        // set the Budget_vs_Actual_Line__c references to null
        if (!consumptionsMap.isEmpty ()) {
            for (String key : consumptionsMap.keySet ()) {
                for (Consumption__c  eachConsumption : consumptionsMap.get (key)) {
                    eachConsumption.Budget_vs_Actual_Line__c = null;
                }
            }
        }
        
        return records;
    }
    //Pramodh Added for Validation Check
    
    public static void userPrivilageCheck(List<Consumption__c> listOfNewConsumptions ){
        set<Id> setOfAccountIds = new Set<Id>();
        Map<Id,Map<Id,String>> mapOfAccIdWithMapOfUserBus = new Map<Id,Map<Id,String>>();
        for(Consumption__c tempConsumption : listOfNewConsumptions){
            setOfAccountIds.add(tempConsumption.Account__c);
        }
        mapOfAccIdWithMapOfUserBus = SharingUtility.getAccountTeamsUserBUs(setOfAccountIds);
        for(Consumption__c tempConsumption : listOfNewConsumptions){
            boolean error = false;
            If(mapOfAccIdWithMapOfUserBus.containsKey(tempConsumption.Account__c)){
                If(mapOfAccIdWithMapOfUserBus.get(tempConsumption.Account__c).ContainsKey(userInfo.getUserId()) ){
                    If(mapOfAccIdWithMapOfUserBus.get(tempConsumption.Account__c).get(userInfo.getUserId()) == tempConsumption.Business_Unit__c ||
                       mapOfAccIdWithMapOfUserBus.get(tempConsumption.Account__c).get(userInfo.getUserId()) == 'All'){
                           
                       }else{
                           error = true;
                       }
                }else{
                    error = true;
                }
            }else{
                error = true;
            }
            if(error){
                tempConsumption.addError('You do not have enough permission to create/update this record');
            }
        }
    }
}