public with sharing class OpportunityVolumeRollUpPromise extends Promise {
    Opportunity oppObj;
  
    public OpportunityVolumeRollUpPromise(Opportunity oppObj){
      this.oppObj = oppObj;
    }
  
    public OpportunityVolumeRollUpPromise(Opportunity oppObj, Promise[] promises){
      this.oppObj = oppObj;
      this.promises = promises;
    }
  
    public override void execute(){
        Savepoint sp = Database.setSavePoint ();
        try {
            List<String> catSubCatBudgetFields = new List<String> {'Category__c', 'Sub_Category__c', 'Sub_Category_2__c'};
            List<String> catSubCatProductFields = new List<String> {'Product_Category__c', 'Product_Sub_Category__c', 'Product_Sub_Category_2__c'};

            Map<String, Budget_vs_Actual_Line__c> budgetLines = new Map < String, Budget_vs_Actual_Line__c> ();
            
            List<Budget_vs_Actuals__c> budgetObjects = BudgetSelector.getBudgetbyOpportunityDetails (oppObj);

            if (budgetObjects.isEmpty ()) {

                List<Teams__c> teams = [SELECT Id, Account__c, User__c, Is_Primary__c, BU__c 
                                FROM Teams__c 
                                WHERE Account__c =: oppObj.AccountId
                                AND BU__c =: oppObj.Business_Unit__c
                                AND Is_Primary__c = TRUE	
                                LIMIT 1];
                Id ownerId =  oppObj.OwnerId;

                if (teams != null && !teams.isEmpty () && String.isNotBlank(teams[0].User__c)) {
                    ownerId = teams[0].User__c;
                }

                //create budget;
                Budget_vs_Actuals__c budgetRecord = new Budget_vs_Actuals__c (
                    Account__c = oppObj.AccountId,
                    Name = (oppObj.Business_Unit__c + '-' + oppObj.CloseDate.year () ),
                    Business_Unit__c = oppObj.Business_Unit__c,
                    Start_date__c = Date.newInstance(oppObj.CloseDate.year (), 1, 1),
                    End_Date__c = Date.newInstance(oppObj.CloseDate.year (), 12, 31),
                    Year__c = String.valueOf (oppObj.CloseDate.year ()),
                    OwnerId = ownerId
                );

                insert budgetRecord;

                budgetObjects.add (budgetRecord);
            }

            for (Budget_vs_Actual_Line__c eachLine : budgetObjects[0].Budget_vs_Actual_Lines__r) {
                budgetLines.put (getCatSubCatKey (eachLine, catSubCatBudgetFields), eachLine);
            }
                            
            Map<String, Decimal> categoryVolumeMap = new Map<String,Decimal> ();

            for (OpportunityLineItem eachLine :OpportunityLineItemSelector.getOpportunityLines 
                                                    (
                                                        oppObj.AccountId, 
                                                        budgetObjects[0].Start_date__c, 
                                                        budgetObjects[0].End_Date__c, 
                                                        oppObj.Business_Unit__c)
                                                    ) 
            {
                String key = getCatSubCatKey (eachLine.Product2, catSubCatProductFields);

                if (!budgetLines.containsKey (key)) {
                    budgetLines.put (key, new Budget_vs_Actual_Line__c (
                        Budget_vs_Actuals__c = budgetObjects[0].Id,
                        Category__c	= eachLine.Product2.Product_Category__c,
                        Sub_Category__c = eachLine.Product2.Product_Sub_Category__c,
                        Sub_Category_2__c = eachLine.Product2.Product_Sub_Category_2__c
                    ));   
                }

                if (categoryVolumeMap.containsKey(key)) {
                    categoryVolumeMap.put (key, categoryVolumeMap.get(key) + (eachLine.Converted_Volume_in_MT__c != null ? eachLine.Converted_Volume_in_MT__c : 0));
                } else {
                    categoryVolumeMap.put (key, eachLine.Converted_Volume_in_MT__c != null ? eachLine.Converted_Volume_in_MT__c : 0);
                }
            }

            List<Budget_vs_Actual_Line__c> budgetLinesUpdateList = new List<Budget_vs_Actual_Line__c> ();
            List<Budget_vs_Actual_Line__c> budgetLinesInsertList = new List<Budget_vs_Actual_Line__c> ();

            for (String key : budgetLines.keySet ()) {
                if (categoryVolumeMap.containsKey(key)) {
                    Budget_vs_Actual_Line__c line = budgetLines.get (key);
                    if (String.isBlank(line.Id)) {
                        line.Actuals__c = categoryVolumeMap.get(key);
                        budgetLinesInsertList.add (line);
                    } else {
                        budgetLinesUpdateList.add (new Budget_vs_Actual_Line__c (Id = budgetLines.get (key).Id, Actuals__c = categoryVolumeMap.get(key)));
                    }
                }
            }

            if (budgetLinesUpdateList.isEmpty () && budgetLinesInsertList.isEmpty ()) {
                System.debug('Async Work Completed! : budgetLinesUpdateList is empty');
                return;
            }

            if (!budgetLinesUpdateList.isEmpty ()) {
                update budgetLinesUpdateList;
            }

            if (!budgetLinesInsertList.isEmpty ()) {
                insert budgetLinesInsertList;
            }

            // Database.SaveResult [] updateResults = Database.update(budgetLinesUpdateList, false);
            // for (Database.SaveResult result : updateResults) {
            //     if (!result.isSuccess()) {
            //         System.debug(result.getErrors() + ' -- Id :' + result.getId());
            //     }
            // }
            // Database.SaveResult [] insertResults = Database.insert(budgetLinesInsertList, false);
            // for (Database.SaveResult result : insertResults) {
            //     if (!result.isSuccess()) {
            //         System.debug(result.getErrors() + ' -- Id :' + result.getId());
            //     }
            // }
        } catch (Exception e) {
            Database.rollback(sp);
            Error_Event_Capture__e errorCaptureEvent = new Error_Event_Capture__e (
                Apex_Class__c ='OpportunityVolumeRollUpPromise',
                Error_Details__c = e.getMessage (),
                Record_Detail__c = JSON.serialize(oppObj)
            );
            Database.SaveResult result = Eventbus.publish(errorCaptureEvent);
            if (result.isSuccess()) {
                System.debug('Event published successfully !!');
            } else {
                System.debug('Event publish failed :' + e.getMessage () );
            }
        }
        System.debug('Async Work Completed!');
    }

    private String getCatSubCatKey (Sobject record,  List<String> catSubCatCombFields) {
       
        String catSubCatStr = '';
        for (String eachField : catSubCatCombFields) {
            if (record.getSobjectType().getDescribe().fields.getMap().keySet().contains(eachField.toLowerCase()) && record.get (eachField) != null && (String) record.get (eachField) != '' ) {
                catSubCatStr += '_' + (String)record.get(eachField);
            }
        }
        return catSubCatStr.trim ();
    }
}