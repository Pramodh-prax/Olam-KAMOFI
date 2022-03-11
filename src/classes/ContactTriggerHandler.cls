public class ContactTriggerHandler {
    

    /*public static void shareContactRecordWithAccountTeamMembers(List<Contact> contactList){
        system.debug('after insert: shareContactRecordWithAccountTeamMembers method');
        List<ContactShare> conShareList = new List<ContactShare>();
        Set<Id> acctIdSet = new Set<Id>();
        for(Contact c : contactList){
            if(c.AccountId != null){
                acctIdSet.add(c.AccountId); 
            }
        } 
        
        Map<id,List<Teams__c>> teamsMap = new Map<id,List<Teams__c>>();
        
        List<Teams__c> teamList = new List<Teams__c>();
        //Old BU__c (formula) field changed to Business_Unit__c (Picklist)
        teamList = [SELECT id,Business_Unit__c,Account__c,Is_Primary__c,User__c,OwnerId 
                                   FROM Teams__c 
                                   WHERE Account__c IN :acctIdSet                                            
                                  ];
        for(Teams__c teams : teamList){
            if(teamsMap.containsKey(teams.Account__c)){
                teamsMap.get(teams.Account__c).add(teams);
            }else{
                teamsMap.put(teams.Account__c,new List<Teams__c>{teams});
            }
        }
        
        
        for(Contact con : contactList){
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
        }
        
    }*/
    
    
    public static void onlyAccountTeamMembersCanAddContacts(List<Contact> contactList){
        list<string> profileIdList = System.label.ProfilesAllowedToCreateContacts.split(';');
        
        User loggedInUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        if(!profileIdList.contains(loggedInUser.Profile.Name)){
            Set<Id> acctIdSet = new Set<Id>();
            Set<Id> userIdSet = new Set<Id>(); 
            
            for(Contact c : contactList){
                if(c.AccountId != null){
                    acctIdSet.add(c.AccountId);
                }
            }
            List<Teams__c> teamList = new List<Teams__c>();
            //Old BU__c (formula) field changed to Business_Unit__c (Picklist)
            teamList = [SELECT id,Business_Unit__c,Account__c,Is_Primary__c,User__c,OwnerId 
                                       FROM Teams__c 
                                       WHERE Account__c IN :acctIdSet and User__c != null and Account__c != null                                        
                                      ];
            
            
            
            map<id,Set<id>> teamMemberMap = new map<id,Set<id>>();
            for(Teams__c team : teamList){
                if(teamMemberMap.containsKey(team.Account__c)){
                    teamMemberMap.get(team.Account__c).add(team.User__c);
                }else{
                    teamMemberMap.put(team.Account__c,new set<id>{team.User__c});
                }
            }
            
            
            for(Contact con : contactList){
                if(!teamMemberMap.containskey(con.AccountId) || (teamMemberMap.containskey(con.AccountId)  && !teamMemberMap.get(con.AccountId).contains(UserInfo.getUserId()) )  ){
                    con.adderror(System.Label.OnlyAccountTeamsCanAddContactErrorMessage); 
                }
            }
   
        }
        
    }
    //added by Rajat end - 05/08/21
}