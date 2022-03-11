public class SalesAreaTriggerHandler extends TriggerHandlerBase {
    public override void handleBeforeInsert() {
        Map<Id, Map<String, Sales_Area__c>> newSalesAreaMap = new Map<Id, Map<String, Sales_Area__c>>();
        for(Sales_Area__c obj : (List<Sales_Area__c>)Trigger.new) {
            if(!newSalesAreaMap.containsKey(obj.Account_Name__c)) {
                newSalesAreaMap.put(obj.Account_Name__c, new Map<String, Sales_Area__c>());
            }
            newSalesAreaMap.get(obj.Account_Name__c).put(obj.Sales_Org__c + '_' + obj.Distribution_Channel__c + '_' + obj.Division__c, obj);
        }
        // OlamLogger.logPretty('newSalesAreaMap', newSalesAreaMap);
        
        // Select existing Sales areas for the accounts
        Set<Id> accIds = newSalesAreaMap.keySet();
        Map<Id, Map<String, Sales_Area__c>> existingSalesAreaMap = new Map<Id, Map<String, Sales_Area__c>>();
        for(Sales_Area__c obj : [Select Id, 
                                     Account_Name__r.Id, 
                                     Sales_Org__c, 
                                     Distribution_Channel__c, 
                                     Division__c, 
                                 	 Credit_Limit__c,
                                     Inco_Terms__c,  
                                     Shipping_Conditions__c, 
                                     Terms_of_Payment__c
                                 from Sales_Area__c 
                                 where Account_Name__r.Id in :accIds]) {
            if(!existingSalesAreaMap.containsKey(obj.Account_Name__r.Id)) {
                existingSalesAreaMap.put(obj.Account_Name__r.Id, new Map<String, Sales_Area__c>());
            }
            existingSalesAreaMap.get(obj.Account_Name__r.Id).put(obj.Sales_Org__c + '_' + obj.Distribution_Channel__c + '_' + obj.Division__c, obj);
        }
        // OlamLogger.logPretty('existingSalesAreaMap', existingSalesAreaMap);
        
        // Remove non match
        // Existing: 1 2 3
        // New:      2 3 4
        // Remove 1 here
        // List<Sales_Area__c> toDelete = new List<Sales_Area__c>();
        // for(Id accId : existingSalesAreaMap.keySet()) {
        //      for(String salesArea : existingSalesAreaMap.get(accId).keySet()) {
        //         if(!newSalesAreaMap.get(accId).containsKey(salesArea)) {
        //             toDelete.add(existingSalesAreaMap.get(accId).get(salesArea));
        //         } 
        //     }
        // }
        // if(!toDelete.isEmpty())
        //  delete toDelete;
        
        // Remove the duplicate one from the new list
        // If the value is changed then delete the existing one
        // Existing: 1 2 
        // New:      1 2(Changed) 3
        // Mark new 1 as delete and delete existing 2
        List<Sales_Area__c> toDelete = new List<Sales_Area__c>();
        for(Id accId : existingSalesAreaMap.keySet()) {
            for(String salesArea : existingSalesAreaMap.get(accId).keySet()) {
                if(newSalesAreaMap.get(accId).containsKey(salesArea)) {
                    // OlamLogger.log('!!!!!!!!! Set ' + salesArea + ' to delete');
                    Sales_Area__c existingSA = existingSalesAreaMap.get(accId).get(salesArea);
                    Sales_Area__c newSA = newSalesAreaMap.get(accId).get(salesArea);
                    if(newSA.To_Delete__c == true) {
                        toDelete.add(existingSA);
                    }
                    else if(newSA.Inco_Terms__c == existingSA.Inco_Terms__c && 
                       newSA.Shipping_Conditions__c == existingSA.Shipping_Conditions__c && 
                       newSA.Terms_of_Payment__c == existingSA.Terms_of_Payment__c &&
                       newSA.Credit_Limit__c == existingSA.Credit_Limit__c) {
                           
                        newSA.To_Delete__c = True;
                    }
                    else {
                        toDelete.add(existingSA);
                    }
                } 
            }
        } 
        if(!toDelete.isEmpty())
            delete toDelete;
    }
    
    public override void handleAfterInsert() {
        Set<Id> accIds = new Set<Id>();
        for(Sales_Area__c obj : (List<Sales_Area__c>)Trigger.new) {
            accIds.add(obj.Account_Name__c);
        }
        
        List<Sales_Area__c> toDelete = [Select Id from Sales_Area__c where Account_Name__c in :accIds and To_Delete__c = True];
        if(!toDelete.isEmpty())
            delete toDelete;
    }
    
}