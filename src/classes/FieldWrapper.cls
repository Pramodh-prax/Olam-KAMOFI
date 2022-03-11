public class FieldWrapper {
    @AuraEnabled public String label {get;set;}
    @AuraEnabled public String apiName {get;set;}
    
    public FieldWrapper (String label, String apiName) {
        this.label = label;
        this.apiName = apiName;
    }
}