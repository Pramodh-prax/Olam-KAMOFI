public class QuoteLineItemTriggerHelper {
	
    public static void updateQuoteStatus(String QuoId)
    {
		List<QuoteLineItem> QuoteLineItemList = [Select Id,Approval_Status__c from QuoteLineItem where QuoteId =: QuoId];
        Integer TotalQuoteLineItemCount = QuoteLineItemList.size();
        
        //Quote Line Items Status Count
        Integer NotStartedCount = 0;
        Integer InProgressCount = 0;
        Integer AcceptedCount = 0;
        Integer RejectedCount = 0;
        Integer RecalledCount = 0;
        Integer NACount = 0;
        
        //Quote Line Item Status
        final String NA = 'N/A';
        final String NotStarted = 'Not Started';
        final String InProgress = 'In Progress';
        final String Accepted = 'Accepted';
        final String Rejected = 'Rejected';
        final String Recalled = 'Recalled';
        
        //Quote Status
        final String QuoNotStarted = 'Not Started';
        final String QuoInReview = 'In Review';
        final String QuoApproved = 'Approved';
        final String QuoPartiallyRejected = 'Partially Rejected';
        final String QuoRejected = 'Rejected';
        
        for(QuoteLineItem qLI : QuoteLineItemList)
        {
          
            if(qLI.Approval_Status__c == NA)
            {
                NACount++;
            }
            if(qLI.Approval_Status__c == NotStarted)
            {
                NotStartedCount++;
            }
            if(qLI.Approval_Status__c == InProgress)
            {
                InProgressCount++;
            }
            if(qLI.Approval_Status__c == Accepted)
            {
                AcceptedCount++;
            }
            if(qLI.Approval_Status__c == Rejected)
            {
                RejectedCount++;
            }
            if(qLI.Approval_Status__c == Recalled)
            {
                RecalledCount++;
            }
        }
        
        
        
        String QuoteStatus = '';
        Integer isAllAccepted =  TotalQuoteLineItemCount - RecalledCount - NACount;
        Integer isAllRejected = TotalQuoteLineItemCount - RecalledCount - NACount;
        
        if(AcceptedCount == TotalQuoteLineItemCount || TotalQuoteLineItemCount == NACount)
        {
            QuoteStatus = QuoApproved;
        }
        if(RejectedCount == TotalQuoteLineItemCount)
        {
            QuoteStatus = QuoRejected;
        }
        if(RejectedCount >= 1 && InProgressCount == 0)
        {
            QuoteStatus = QuoPartiallyRejected;
        }
        if(NotStartedCount >= 1)
        {
            QuoteStatus = QuoInReview;
        }
        if(InProgressCount >= 1)
        {
            QuoteStatus = QuoInReview;
        }
        
        Quote quo = new Quote();
        quo.Id = QuoId;
        quo.Status = QuoteStatus;
        
        update quo;
    }
}