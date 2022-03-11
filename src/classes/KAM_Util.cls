public inherited sharing class KAM_Util {
    public static List<PicklistEntry> getPickListValues (String objectApiName, 
                                                        String fieldApiName, 
                                                        Boolean discardInactiveValue, 
                                                        Boolean shouldIncludeNone ) {
        
        List<PicklistEntry> returnList = new List<PicklistEntry> ();

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldApiName).getDescribe().getPickListValues();       
        if(shouldIncludeNone){
            returnList.add(new PicklistEntry ('--None--', ''));
        }       
        for (Schema.PicklistEntry eachEntry : picklistValues) {
            if ( (discardInactiveValue && eachEntry.isActive()) ||  !discardInactiveValue) {
                returnList.add (new PicklistEntry (eachEntry.getLabel(), eachEntry.getValue()));
            }
        }
        return returnList;
    }

    public class PicklistEntry {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}

        public PicklistEntry (String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}