public with sharing class KAM_ConsumptionCntl implements KAM_AccountPlan{
    public static String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountId')&&requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getConsumptions (String.valueOf(requestMap.get('accountId')),(Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class)));
        } 
        return null;
    }
    @AuraEnabled
     public static String getGroupDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
           return JSON.serialize(getGroupConsumptions ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class)));
        }
        return null;
    }
    @AuraEnabled
    public static List<Consumption__c> getConsumptions(String accountId,Account_Plans__c accountPlan){
       
		try {        
        List<Consumption__c>listOfConsumption = [Select  Category__c, Sub_Category_2__c, Sub_Category__c,Application__c, Brands__c, Business_Unit__c,
                                                 Volume_MT__c, Share__c, Strength__c 
                                                 From Consumption__c 
                                                 where Account__c=:accountId 
                                                 AND Business_Unit__c=:accountPlan.BU_Identifier__c 
                                                 AND Start_Date__c =: accountPlan.StartDate__c 
                                                 AND End_Date__c =: accountPlan.EndDate__c];
        
        System.debug(listOfConsumption);
        return listOfConsumption;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Consumption__c> getGroupConsumptions(Account_Plans__c accountPlan){
        try {
            if (accountPlan == null || String.isBlank(accountPlan.Customer_Group__c)) {
                NullPointerException e = new NullPointerException ();
                e.setMessage(Label.KAM_Invalid_Account_Plan_Detail_Error_Message);
                throw e;
            }
            List<Consumption__c>listOfConsumption = [Select  Category__c, Sub_Category_2__c, Sub_Category__c,Application__c, Brands__c, Business_Unit__c,
                                                    Volume_MT__c, Share__c, Strength__c,Account__r.Name,Account__c
                                                    From Consumption__c 
                                                    where  Account__r.Customer_Group__c=:accountPlan.Customer_Group__c AND Business_Unit__c=:accountPlan.BU_Identifier__c AND Start_Date__c>=:accountPlan.StartDate__c AND End_Date__c>=:accountPlan.EndDate__c];
            return listOfConsumption;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }
}