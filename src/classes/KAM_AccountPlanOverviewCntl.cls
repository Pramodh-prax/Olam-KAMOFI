public with sharing class KAM_AccountPlanOverviewCntl {

    @AuraEnabled(cacheable=true)
    public static string getAccountPlanSections(String planType){
        try {
            return JSON.serialize([SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c	 
            FROM Account_Plan_Overview_Component__mdt 
            WHERE Is_Active__c = true AND Type__c =: planType
            ORDER BY Order__c
            LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static string getDetails (String overViewMetadata, String data){
        try {
            Account_Plan_Overview_Component__mdt overViewMetaObj = (Account_Plan_Overview_Component__mdt) JSON.deserialize (overViewMetadata, Account_Plan_Overview_Component__mdt.class);
            Type handlerType = Type.forName(overViewMetaObj.ApexClass__c);
            KAM_AccountPlan accountPlanOverViewInstance = (KAM_AccountPlan) handlerType.newInstance();
            return accountPlanOverViewInstance.getDetails(data);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}