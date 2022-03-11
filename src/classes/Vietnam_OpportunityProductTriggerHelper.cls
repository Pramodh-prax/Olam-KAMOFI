public class Vietnam_OpportunityProductTriggerHelper {
	public static void OpportunityProductHistoryUpdate(List<OpportunityLineItem> OPHList)
    {
        List<Opportunity_Product_History__c > lstOLIH = new List<Opportunity_Product_History__c >();
  
    for (OpportunityLineItem objOLI : OPHList){
        
        Opportunity_Product_History__c  objOLIH = new Opportunity_Product_History__c ();
         
        objOLIH.List_Price__c = objOLI.ListPrice;
        objOLIH.Quantity__c = objOLI.Quantity;
        objOLIH.Ratio__c = objOLI.Ratio__c;
        objOLIH.Unit_Price__c = objOLI.UnitPrice;
        objOLIH.Opportunity_Product__c  = objOLI.Id;
        objOLIH.Last_Recorded_Date__c = System.now();
        objOLIH.Opportunity__c = objOLI.OpportunityId;
        lstOLIH.add(objOLIH);
    }
    insert lstOLIH;
    system.debug('History'+ lstOLIH.size());
    }
}