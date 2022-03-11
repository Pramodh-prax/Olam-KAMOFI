public class OpportunityTeamTriggerHandler extends TriggerHandlerBase{
    
	public override void handleAfterInsert()
    {
        System.debug('After Insert');
        Vietnam_OpportunityTeamTriggerHelper.UpdateOppTeamOnProductOpp(Trigger.new);
    }
    
    public override void handleAfterUpdate()
    {
        Map<Id,OpportunityTeamMember> oppTMMap = (Map<Id,OpportunityTeamMember>)Trigger.oldMap;
        List<OpportunityTeamMember> listofOppTM = Trigger.new;
        List<OpportunityTeamMember> listOfOppTMToUpdate = new List<OpportunityTeamMember>();
        
        if(!listofOppTM.isEmpty())
        {
            for(OpportunityTeamMember oppTM : listofOppTM)
            {
                if(oppTMMap.containskey(oppTM.Id))
                {
                    
                    if(oppTM.OpportunityAccessLevel != oppTMMap.get(oppTM.Id).OpportunityAccessLevel 
                       || oppTM.UserId != oppTMMap.get(oppTM.Id).UserId
                       || oppTM.TeamMemberRole != oppTMMap.get(oppTM.Id).TeamMemberRole)
                    {
                        listOfOppTMToUpdate.add(oppTMMap.get(oppTM.Id));
                    }
                }
            }
        }
        
        
        Vietnam_OpportunityTeamTriggerHelper.UpdateOppTeamOnProductOpp(listOfOppTMToUpdate);
    }
}