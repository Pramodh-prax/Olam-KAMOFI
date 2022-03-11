global class Batch_toUpdateProductFieldOnOpp Implements Schedulable, Database.Batchable<sObject>{
    global void execute(SchedulableContext sc) 
    {
        Database.executeBatch(this);
    }
    
    
    
    global database.queryLocator start(Database.BatchableContext BC) 
    {
        String query = 'select id,OpportunityId,product2.name from OpportunityLineItem where OpportunityId !=null';
        
        return database.getQueryLocator(query);
        
    } 
    
    global void execute(Database.BatchableContext BC, list <OpportunityLineItem> scope) {
        List<Opportunity> OpportunityList = new List<Opportunity>();
        system.debug('scope:'+scope);
        system.debug('scope.size():'+scope.size());
        Set<Id> OppIdSet = new Set<Id>();
        for(OpportunityLineItem opt : scope){
            OppIdSet.add(opt.OpportunityId);
        }
        system.debug('OppIdSet:'+OppIdSet);
        system.debug('OppIdSet.size():'+OppIdSet.size());
        
        for(String ids : OppIdSet){
            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
            oppLineItemList = [select id,OpportunityId,product2.name from OpportunityLineItem where OpportunityId =:ids ];
            System.debug('oppLineItemList:'+oppLineItemList);
            String Product='';
            for(OpportunityLineItem opt : oppLineItemList){
                Product+=opt.Product2.Name+'; ';
            }
            system.debug('product:'+product);
            Opportunity op = new Opportunity();
            op.Id =ids;
            op.Product__c = Product;
            OpportunityList.add(op);
        }
        system.debug('OpportunityList size:'+OpportunityList.size());
        system.debug('OpportunityList :'+OpportunityList);
        if(OpportunityList.size() >0){
            system.debug('Inside if Condition');
            update OpportunityList;
        }
    } 
    
    global void finish(Database.BatchableContext BC) {
        
        
    } 
}
/*
 Batch_toUpdateProductFieldOnOpp batch = new Batch_toUpdateProductFieldOnOpp();
Database.executeBatch(batch);
*/