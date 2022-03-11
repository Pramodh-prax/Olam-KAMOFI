public class Vietnam_OpportunityTeamTriggerHelper {
    
    public static void UpdateOppTeamOnProductOpp(List<OpportunityTeamMember> oppTeamList)
    {
        System.debug('oppTeamList>>'+oppTeamList);
        Set<Id> oppId = new Set<Id>();
        
        if(!oppTeamList.isEmpty())
        {
            System.debug('If Cond');
            for(OpportunityTeamMember oppTeamMem : oppTeamList)
            {	
                oppId.add(oppTeamMem.OpportunityId);
            }    
        }
        //find child opp with opp set
        System.debug('oppID >>>'+oppId);
        Map<Id,Opportunity> mapOfChildOpp = new Map<Id, Opportunity>([Select Id,Parent_Opportunity__c from Opportunity where Parent_Opportunity__c IN:oppId AND RecordTypeId =:OpportunityConstants.PLBS_TENDERING_PRODUCT_RECORD_TYPE_ID]);
        System.debug('mapOfChild >>>'+mapOfChildOpp);
        List<OpportunityTeamMember> oppTeamMemListToInsert = new List<OpportunityTeamMember>();
        
        if(!mapOfChildOpp.isEmpty())
        {
            for(OpportunityTeamMember oppTeamMem : oppTeamList) 
            {
                for( Id key : mapOfChildOpp.keySet())
                {
                    if(mapOfChildOpp.get(key).Parent_Opportunity__c == oppTeamMem.OpportunityId)
                    {
                        OpportunityTeamMember oppTM = oppTeamMem.clone();
                        oppTM.OpportunityId = key;
                        oppTeamMemListToInsert.add(oppTM);
                    }
                }
            }            
        }
        
        
        System.debug('oppTeamMemListToInsert>>>'+oppTeamMemListToInsert);
        if(!oppTeamMemListToInsert.isEmpty())
        {
            insert oppTeamMemListToInsert;
        }
    }
}