public class AccessSetTriggerHelper {
    public static void populateUniqueId(List<Access_Set__c> listOfAccessSet){
        for(Access_Set__c accessSet : listOfAccessSet){
            String uniqueId = '';
            uniqueId = String.isNotBlank(accessSet.Regions__c) ? uniqueId+accessSet.Regions__c: uniqueId;
            uniqueId = String.isNotBlank(accessSet.Country__c) ? uniqueId+accessSet.Country__c: uniqueId;
            uniqueId = String.isNotBlank(accessSet.Customer_Group__c) ? uniqueId+accessSet.Customer_Group__c: uniqueId;
            uniqueId = String.isNotBlank(accessSet.Channel__c) ? uniqueId+accessSet.Channel__c: uniqueId;
            uniqueId = String.isNotBlank(accessSet.BU__c) ? uniqueId+accessSet.BU__c: uniqueId;
            uniqueId = String.isNotBlank(accessSet.Product_Category__c) ? uniqueId+accessSet.Product_Category__c: uniqueId;
            //+String.isNotBlank(accessSet.Country__c)+String.isNotBlank(accessSet.Customer_Group__c)+String.isNotBlank(accessSet.Channel__c)+String.isNotBlank(accessSet.BU__c)+String.isNotBlank(accessSet.Product_Category__c);
            accessSet.Unique_Key__c = uniqueId;
        }
    }
    
}