public class QuoteLineApprovalTriggerHelper {
    public static void addPLMsToOpportunityTeams(List<Quote_Line_Approval__c> quoteLineApprovals){
        Map<Id, Set<Id>> opportunityPLMMap = new Map<Id, Set<Id>>();
        
        for(Quote_Line_Approval__c quoteLineApproval :[SELECT Id, Quote_Line_Item__r.Quote.OpportunityId, Approver_1__c, Approver_2__c, Approver_3__c FROM Quote_Line_Approval__c WHERE Id IN:quoteLineApprovals]){
            
            Set<Id> plmIdSet = new Set<Id>();
            if(quoteLineApproval.Approver_1__c != null){
                plmIdSet.add(quoteLineApproval.Approver_1__c);
            }
            if(quoteLineApproval.Approver_2__c != null){
                plmIdSet.add(quoteLineApproval.Approver_2__c);
            }
            if(quoteLineApproval.Approver_3__c != null){
                plmIdSet.add(quoteLineApproval.Approver_3__c);
            }
            
            if(opportunityPLMMap.containsKey(quoteLineApproval.Quote_Line_Item__r.Quote.OpportunityId) && plmIdSet.size() > 0){
                opportunityPLMMap.get(quoteLineApproval.Quote_Line_Item__r.Quote.OpportunityId).addAll(plmIdSet);
            }
            else{
                opportunityPLMMap.put(quoteLineApproval.Quote_Line_Item__r.Quote.OpportunityId, new Set<Id>());
                opportunityPLMMap.get(quoteLineApproval.Quote_Line_Item__r.Quote.OpportunityId).addAll(plmIdSet);
            }
        }
        
        if(opportunityPLMMap.size() > 0){
            List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
            for(Id oppId :opportunityPLMMap.keySet()){
                for(Id userId :opportunityPLMMap.get(oppId)){
                    oppTeamList.add(new OpportunityTeamMember(OpportunityId = oppId, UserId = userId, OpportunityAccessLevel = 'Edit', TeamMemberRole = 'PLM'));
                }
            } 
            insert oppTeamList;
        }
    }
    
    public static void addApproversComments(Map<ID,Quote_Line_Approval__c> mapOfIdWithQuoteLineApproval)
    {
        List<Quote_Line_Approval__c> quoteLineApprovalList =[Select c.Id,c.Quote_Line_Item__c, (Select Id, IsPending, ProcessInstanceId, 
                                                                           TargetObjectId, StepStatus, OriginalActorId, ActorId, RemindersSent, Comments, IsDeleted, CreatedDate, 
                                                                           CreatedById, SystemModstamp From ProcessSteps) 
                                                             From Quote_Line_Approval__c c where id IN :mapOfIdWithQuoteLineApproval.keySet()];
        
         
        List<QuoteLineItem> listOfQLIToUpdate = new List<QuoteLineItem>();
        Map<ID,String> mapOfQuoteLineItemIdWithComment = new Map<ID,String>(); 
        
        if (quoteLineApprovalList.size()>0)
        {
            
            for(Quote_Line_Approval__c qLA : quoteLineApprovalList)
            {
                String commentsStr='';
                for (ProcessInstanceHistory ps : qLA.ProcessSteps)
                {
                    if(ps.comments != null)
                    {
                        commentsStr += ps.comments+' ';   
                    }
                    //'\nComment from user ' + ps.ActorId + ' : ' + ps.comments;
                }
                System.debug('Comment str'+commentsStr);
                if(mapOfIdWithQuoteLineApproval.containsKey(qLA.Id))
                {
                    mapOfQuoteLineItemIdWithComment.put(qLA.Quote_Line_Item__c,commentsStr);
                }
                
            }            
        }
        
        for(Id QuoteLineItemID : mapOfQuoteLineItemIdWithComment.keySet())
        {
            QuoteLineItem qLI = new QuoteLineItem();
            qLI.Id = QuoteLineItemID;
            qLI.Approver_Comment__c = mapOfQuoteLineItemIdWithComment.get(QuoteLineItemID);
            listOfQLIToUpdate.add(qLI);
        }
        
        if(!listOfQLIToUpdate.isEmpty())
        {
            update listOfQLIToUpdate;
        }
        //qLI.Id = quoteLineApprovalToUpdateComment.Quote_Line_Item__c;
        

    }
}