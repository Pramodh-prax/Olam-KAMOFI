public class OpportunityShareService {
    //Commented as part of OFI as it is no more valid
    
    /*public static void recalculateSharingForOpportunities(Id oppId, Id accId, String businessUnit, Id oppOwnerId){
    	List<Teams__c> teamsList = new List<Teams__c>();
        teamsList = getTeams(accId, businessUnit);
        
        Set<String> oppShareUserIdSet = new Set<String>();
        oppShareUserIdSet = getExistingOppShare(oppId);
        
        List<OpportunityShare> oppShareToInsert = new List<OpportunityShare>();
        for(Teams__c team :teamsList){
            if(team.User__c != oppOwnerId && !oppShareUserIdSet.contains(team.User__c)){
                oppShareToInsert.add(
                	new OpportunityShare(
                        OpportunityId = oppId,
                    	OpportunityAccessLevel = 'Read',
                        UserOrGroupId = team.User__c,
                        RowCause = 'Manual'
                    )
                );
            }
        }
        
        if(oppShareToInsert.size() > 0){
            insert oppShareToInsert;
        }
    }*/
    
    //Commented as part of OFI as it is no more valid
    /*public static List<Teams__c> getTeams(Id accId, String businessUnit){
        List<Teams__c> teamsList = new List<Teams__c>();
        teamsList = [SELECT Id, User__c FROM Teams__c WHERE Account__c = :accId AND BU__c = :businessUnit AND User__r.IsActive = true];
        return teamsList;
    }*/
    
    //Commented as part of OFI as it is no more valid
    /*public static Set<String> getExistingOppShare(Id oppId){
        Set<String> userIdSet = new Set<String>();
        
        for(OpportunityShare oppShare :[SELECT Id, UserOrGroupId FROM OpportunityShare WHERE OpportunityId =:oppId AND RowCause = 'Manual']){
            userIdSet.add(oppShare.UserOrGroupId);
        }
        
        return userIdSet;
    }*/
}