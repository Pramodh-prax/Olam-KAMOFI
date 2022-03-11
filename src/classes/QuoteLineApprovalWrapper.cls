public class QuoteLineApprovalWrapper {
	@AuraEnabled public QuoteLineItem quoteLine;
    @AuraEnabled public Approval_Matrix__c approvalMatrix;
    
    public QuoteLineApprovalWrapper(QuoteLineItem quoteLine, Approval_Matrix__c approvalMatrix){
        this.quoteLine = quoteLine;
        this.approvalMatrix = approvalMatrix;
    }
}