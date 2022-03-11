trigger OpportunityTeamTrigger on OpportunityTeamMember (before insert,after insert, after update, after delete,before update) {
	
	new OpportunityTeamTriggerHandler().Handle();  
}