public with sharing class BudgetActualLineTriggerHandler extends TriggerHandlerBase {
    
    public override void handleAfterInsert() {
        updateConsumptions (Trigger.new);
    }

    public override void handleAfterUpdate () {
        
        List <Budget_vs_Actual_Line__c> budgetLines = identifyCatSubCatChanges (
                                                        (List<Budget_vs_Actual_Line__c>)Trigger.new,  
                                                        (Map<Id, Budget_vs_Actual_Line__c>)Trigger.oldMap
                                                    );
        if (!budgetLines.isEmpty ()) {

            // recalculate the consumption lookup field value
            updateOlderConsumptionsForLines (
                JSON.serialize(
                    [SELECT Id, Budget_vs_Actual_Line__c, Account__c, Business_Unit__c, Category__c, Sub_Category__c, Sub_Category_2__c 
                    FROM  Consumption__c WHERE Budget_vs_Actual_Line__c in: budgetLines]
                )
            );

            // update the consumption records line references to new line
            updateConsumptions (budgetLines);
        }
    }

    //@future
    public static void updateOlderConsumptionsForLines (String consumptionString) {
        if (String.isNotBlank(consumptionString)) {
            List<Consumption__c> consumptions = (List<Consumption__c>) JSON.deserialize (consumptionString, List<Consumption__c>.class);
            if (!consumptions.isEmpty ()) {
                new ConsumptionTriggerHandler ().updateConsumptionRefs (consumptions);
            }
        }
    }

    private List <Budget_vs_Actual_Line__c> identifyCatSubCatChanges (List<Budget_vs_Actual_Line__c> newList, Map<Id, Budget_vs_Actual_Line__c> oldMap) {

        List <Budget_vs_Actual_Line__c> oldBudActItems = new List<Budget_vs_Actual_Line__c> ();

        for (Budget_vs_Actual_Line__c eachLine : newList) {
            if (oldMap.containsKey (eachLine.Id)
                && 
                    (
                        eachLine.Category__c != oldMap.get (eachLine.Id).Category__c
                        || eachLine.Sub_Category__c != oldMap.get (eachLine.Id).Sub_Category__c
                        || eachLine.Sub_Category_2__c != oldMap.get (eachLine.Id).Sub_Category_2__c
                    )
            ) {
                oldBudActItems.add (eachLine);
            }
        }
        return oldBudActItems;
    }
 
    //Todo: error handling
    public void updateConsumptions (List<Budget_vs_Actual_Line__c> records) {
        Map<String, String> budgetActualLineIdMap   = new Map<String, String> (); 
        Set<String> buTypes                         = new Set<String> ();
        Set<String> categories                      = new Set<String> ();
        Set<String> subCategories                   = new Set<String> ();
        Set<String> subCategoriesTwo                = new Set<String> ();
        Set<Id> accountIds                          = new Set<Id> ();
        Set<String> years                         = new Set<String> ();

        for (Budget_vs_Actual_Line__c eachLine : [
            SELECT Id, Actuals__c, Budget_vs_Actuals__c, Category__c, Sub_Category__c, 
            Sub_Category_2__c, Total_Consumption__c, Volume__c, 
            Budget_vs_Actuals__r.Account__c, Budget_vs_Actuals__r.Business_Unit__c,
            Budget_vs_Actuals__r.Year__c    
            FROM Budget_vs_Actual_Line__c WHERE Id in: records
        ]) {
            String key = '';
            if (String.isNotBlank(eachLine.Budget_vs_Actuals__r.Account__c)) {
                key += eachLine.Budget_vs_Actuals__r.Account__c;
                accountIds.add(eachLine.Budget_vs_Actuals__r.Account__c);
            }
            if (String.isNotBlank(eachLine.Budget_vs_Actuals__r.Business_Unit__c)) {
                key += eachLine.Budget_vs_Actuals__r.Business_Unit__c;
                buTypes.add(eachLine.Budget_vs_Actuals__r.Business_Unit__c);
            }
            if (String.isNotBlank(eachLine.Budget_vs_Actuals__r.Year__c)) {
                key += eachLine.Budget_vs_Actuals__r.Year__c;
                years.add(eachLine.Budget_vs_Actuals__r.Year__c);
            }
            if (String.isNotBlank(eachLine.Category__c)) {
                key += eachLine.Category__c;
                categories.add (eachLine.Category__c);
            }
            if (String.isNotBlank(eachLine.Sub_Category__c)) {
                key += eachLine.Sub_Category__c;
                subCategories.add (eachLine.Sub_Category__c);
            }
            if (String.isNotBlank(eachLine.Sub_Category_2__c)) {
                key += eachLine.Sub_Category_2__c;
                subCategoriesTwo.add (eachLine.Sub_Category_2__c);
            }
            key = key.trim();

            budgetActualLineIdMap.put(key, eachLine.Id);
        }

        if (budgetActualLineIdMap.isEmpty()) {return;}


        List<Consumption__c> consumptionUpdateList = new List<Consumption__c> ();
        for (Consumption__c eachConsumption : [
            SELECT Id, Budget_vs_Actual_Line__c, Account__c, Business_Unit__c, Category__c, Sub_Category__c, Sub_Category_2__c, Year__c 
            FROM  Consumption__c
            WHERE Account__c IN : accountIds
            AND Business_Unit__c IN : buTypes
            AND Year__c IN : years
            //AND Category__c IN : categories
            //AND Sub_Category__c IN : subCategories
            //AND Sub_Category_2__c IN : subCategoriesTwo
            LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
        ]) {
            String key = '';
            if (String.isNotBlank(eachConsumption.Account__c)) {
                key += eachConsumption.Account__c;
            }
            if (String.isNotBlank(eachConsumption.Business_Unit__c)) {
                key += eachConsumption.Business_Unit__c;
            }
            if (String.isNotBlank(eachConsumption.Year__c)) {
                key += eachConsumption.Year__c;
            }
            if (String.isNotBlank(eachConsumption.Category__c)) {
                key += eachConsumption.Category__c;
            }
            if (String.isNotBlank(eachConsumption.Sub_Category__c)) {
                key += eachConsumption.Sub_Category__c;
            }
            if (String.isNotBlank(eachConsumption.Sub_Category_2__c)) {
                key += eachConsumption.Sub_Category_2__c;
            }
            key = key.trim();

            if (budgetActualLineIdMap.containsKey(key)) {
                eachConsumption.Budget_vs_Actual_Line__c = budgetActualLineIdMap.get(key);
                consumptionUpdateList.add (eachConsumption);
            }
        }

        if (consumptionUpdateList.isEmpty ()) {return;}
        Database.SaveResult [] results = Database.update(consumptionUpdateList, false);

        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                //todo: handle error
                System.debug('Errors :' + result.getErrors());
            }
        }

    }
}