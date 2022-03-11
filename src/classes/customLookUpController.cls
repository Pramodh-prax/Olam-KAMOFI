public class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String priceBookId, string currencyisocode) {
        set<Id> setOfProductIds = new set<Id>();
        system.debug('currencyisocode:'+currencyisocode);
        for(PricebookEntry tempPBE : [SELECT Id, Product2Id FROM PricebookEntry where Pricebook2Id =: priceBookId AND currencyisocode =:currencyisocode]){
        	setOfProductIds.add(tempPBE.Product2Id);
        }
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Id IN: setOfProductIds and Name LIKE: searchKey order by createdDate DESC limit 20';
        system.debug('sQuery:'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}