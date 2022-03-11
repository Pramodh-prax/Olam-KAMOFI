public class BatchToShareContactsWithAccountTeams implements Database.Batchable<sObject>,Database.stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString = 'Select id,AccountId,OwnerId from Contact';
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext bc, List<Contact> conList){
        //Commented as part of OFI as it is no more valid
        
        /*system.debug('inside execute method');
        Set<Id> acctIdSet = new Set<Id>();
        List<ContactShare> conShareList = new List<ContactShare>();
        
        for(Contact c : conList){
            if(c.AccountId != null){
                acctIdSet.add(c.AccountId);
            }
        }
        
        Map<id,List<Teams__c>> teamsMap = new Map<id,List<Teams__c>>();
        List<Teams__c> teamList = [SELECT id, User__c, Account__c
                                   FROM Teams__c 
                                   WHERE Account__c IN :acctIdSet AND User__r.IsActive = true                                         
                                  ];
        
        for(Teams__c teams : teamList){
            if(teamsMap.containsKey(teams.Account__c)){
                teamsMap.get(teams.Account__c).add(teams);
            }else{
                teamsMap.put(teams.Account__c,new List<Teams__c>{teams});
            }
        }
        
        for(Contact con : conList){
            if(teamsMap.containskey(con.AccountId)){
                for(Teams__c team : teamsMap.get(con.AccountId)){
                    if(con.OwnerId != team.User__c){
                        ContactShare csObj = new ContactShare();
                        csObj.contactId = con.Id;
                        csObj.UserOrGroupId = team.User__c;
                        csObj.ContactAccessLevel = 'edit';
                        conShareList.add(csObj);
                    }
                }
            }
        }
        
      if(!conShareList.isEmpty() && conShareList.size() > 0){
            INSERT conShareList;
        }*/
  
    }
    public void finish(Database.BatchableContext bc){
        system.debug('finish method called from batch');
    }
}