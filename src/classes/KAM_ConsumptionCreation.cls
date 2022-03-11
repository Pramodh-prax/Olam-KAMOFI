global class KAM_ConsumptionCreation implements Database.Batchable<sObject>, schedulable{
    
    global void execute(SchedulableContext SC) {
 	database.executebatch(new KAM_ConsumptionCreation());
    }
		global Database.QueryLocator start(Database.BatchableContext BC) {
            String lastYear=String.valueOf(System.Today().year()-1);
        String query = 'SELECT Id,Name,Account__c,Volume_MT__c,Application__c,Brands__c,Business_Unit__c,Category__c,Coverage__c,Review_Date__c,Share__c,Strength__c,Sub_Category__c,Sub_Category_2__c,User_Is_Account_Team_Member__c,Year__c FROM Consumption__c where Year__c=:lastYear';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Consumption__c> conList) {
        List<Brand_n_Comp__c>BnCCloneList = new List<Brand_n_Comp__c>();
        List<Consumption__c>conCloneList = new List<Consumption__c>();
        RelationshipUtiltiy relUtil = new RelationshipUtiltiy();
        for(Consumption__c con : conList) {        
           Consumption__c copyCon = con.clone(false, true, false, false);
            copyCon.Year__c= String.valueOf(System.Today().year());
            conCloneList.add(copyCon);
            for(Brand_n_Comp__c bnc:[Select Name,Brand_type__c,Brand__c,Share__c,Consumption__c From Brand_n_Comp__c where Consumption__c=:con.Id]){
              Brand_n_Comp__c BnCcopy  = bnc.clone(false, true, false, false);
                relUtil.registerRelationship(BnCcopy, copyCon, Brand_n_Comp__c.Consumption__c);
                BnCCloneList.add(BnCcopy);
            }

        }
        try {
            if(conCloneList.size()>0){
            insert conCloneList;
            }
            if(BnCCloneList.size()>0){
                relUtil.resolve('Brand_n_Comp__c');
                insert BnCCloneList;
            }
            
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        
    }
}