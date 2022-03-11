public class customLookUpGenericController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery ='';   
        if(ObjectName.equalsIgnoreCase('ACCOUNT')){
            sQuery = 'select id, Name from ' +ObjectName + ' where (Name LIKE: searchKey or SAP_Account_ID__c LIKE: searchKey) order by createdDate DESC limit 5';
        }
        else if(ObjectName.equalsIgnoreCase('USER')){
            sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey and IsActive = TRUE order by createdDate DESC limit 5';
        }
        else{
            sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        }
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}