public class AccountTriggerHelper{
    
    // This method uses Regex to verify the Billing and Shipping postal code in Account object
    public static void validatePostalCode(List<Account> accList){
        Map<Id,Account> AccountMap= new Map<Id,Account>();
     	Set<String> countryCodeSet = new  Set<String>();
     	for (Account obj : accList){
         	countryCodeSet.add(obj.BillingCountryCode);
         	countryCodeSet.add(obj.shippingCountryCode);
     	} 
        List<PostalCodeValidation__c> PostalCodeValidationList = new list<PostalCodeValidation__c>([SELECT Name, Format__c, Error_Message__c FROM PostalCodeValidation__c WHERE Name IN :countryCodeSet]);
        Map<String, String> PostalCodeValidationMap = new Map<String, String>();
        Map<String, String> PostalCodeValidationErrorMap = new Map<String, String>();
        if(!PostalCodeValidationList.isEmpty()){
        	for(PostalCodeValidation__c item : PostalCodeValidationList){
            	PostalCodeValidationMap.put(item.Name, item.Format__c);
            	PostalCodeValidationErrorMap.put(item.Name, item.Error_Message__c);
        	}
        	for(Account obj : accList){
                if(String.IsNotEmpty(obj.BillingPostalCode)){
           			if(PostalCodeValidationMap.containsKey(obj.BillingCountryCode)){
           				String format = PostalCodeValidationMap.get(obj.BillingCountryCode);
						Boolean isValid = verifyRegex(format,obj.BillingPostalCode);            
                		if(!isValid){
                    		String errorMessage = PostalCodeValidationErrorMap.get(obj.BillingCountryCode);
                    		obj.BillingPostalCode.addError(errorMessage);
                		}            
            		}
                }
                if(String.IsNotEmpty(obj.ShippingPostalCode)){
            		if(PostalCodeValidationMap.containsKey(obj.shippingCountryCode)){
           				String format = PostalCodeValidationMap.get(obj.shippingCountryCode);
               			Boolean isValid = verifyRegex(format,obj.ShippingPostalCode); 
                		if(!isValid){
                    		String errorMessage = PostalCodeValidationErrorMap.get(obj.shippingCountryCode);
                    		obj.ShippingPostalCode.addError(errorMessage);
                		}
            		}
                }
     		}
        }
    }
    
    // This method is called from validatePostalCode to verify the Pincodes using Regex
    public static boolean verifyRegex(String format, String toVerifyString){
    	Boolean isValidFormat = Pattern.matches(format, toVerifyString);
        return isValidFormat;   	
    }
    
}