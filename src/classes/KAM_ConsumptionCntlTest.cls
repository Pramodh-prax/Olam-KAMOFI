@isTest
public class KAM_ConsumptionCntlTest {

    static testMethod void testMethod1() {
        String cusdata='{"accountId":"0011s00000mml2yAAA","accountPlan":{"EndDate__c":"2021-12-31","Type__c":"Individual","BU_Identifier__c":"Cocoa","Year__c":"2021","Account__c":"0011s00000mml2yAAA","Customer_Group__c":"Mondelez","Id":"a0e1s000000CYqcAAG","StartDate__c":"2021-01-01","Name":"Plan-2021"}}';
        String accountPlan='{"accountPlan":{"EndDate__c":"2021-12-31","Type__c":"Group","BU_Identifier__c":"Dairy","Year__c":"2021","Account__c":"0011s00000mml2yAAA","Customer_Group__c":"Mondelez","Id":"a0e1s000001pbGtAAI","StartDate__c":"2021-01-01","Name":"Group Plan-2021"}}';
        KAM_ConsumptionCntl.getGroupDetails(accountPlan);
        KAM_ConsumptionCntl.getDetails(cusdata);
        
    }
     static testMethod void KAM_CustomerOverViewGrpCntlTest() {
          String accountPlan='{"accountPlan":{"EndDate__c":"2021-12-31","Type__c":"Group","BU_Identifier__c":"Dairy","Year__c":"2021","Account__c":"0011s00000mml2yAAA","Customer_Group__c":"Mondelez","Id":"a0e1s000001pbGtAAI","StartDate__c":"2021-01-01","Name":"Group Plan-2021"}}';
         KAM_CustomerOverViewGrpCntl.getDetails(accountPlan);
     }
}