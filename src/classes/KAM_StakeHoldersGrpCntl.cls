public without sharing class KAM_StakeHoldersGrpCntl implements KAM_AccountPlan{
    
    public String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey('customerGroup')) {
            return JSON.serialize(getAccountsByCustpmerGroup (String.valueOf(requestMap.get('customerGroup')),String.valueOf(requestMap.get('BU_Identifier__c'))));
        }
        return null;
    }
    private List<Account> getAccountsByCustpmerGroup(String customerGroup, String BuisnessUnit){
        if (String.isBlank(customerGroup)) {
            NullPointerException e = new NullPointerException ();
            e.setMessage(Label.KAM_Invalid_Account_Plan_Detail_Error_Message);
            throw e;
        }
        return AccountSelector.getAccountsByCustomerGroupforoverview(customerGroup,BuisnessUnit);
    }
    @AuraEnabled
    public static List<Contact> getContactsByAccountId(String accountId){
        return KAM_StakeHoldersCntl.getContactsByAccountId (accountId);
    }
}