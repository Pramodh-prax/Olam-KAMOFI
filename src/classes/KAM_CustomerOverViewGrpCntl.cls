public class KAM_CustomerOverViewGrpCntl implements KAM_AccountPlan{
public static String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getCustomerOverviewGrp ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class)));
        }
        return null;
    }
    public static List<Account> getCustomerOverviewGrp(Account_Plans__c accountPlan){
        if (accountPlan == null || String.isBlank(accountPlan.Customer_Group__c)) {
            NullPointerException e = new NullPointerException ();
            e.setMessage(Label.KAM_Invalid_Account_Plan_Detail_Error_Message);
            throw e;
        }
        return AccountSelector.getAccountsByCustomerGroupforoverview(accountPlan.Customer_Group__c,accountPlan.BU_Identifier__c);
      
    }
}