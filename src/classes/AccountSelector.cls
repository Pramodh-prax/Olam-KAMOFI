public inherited sharing class AccountSelector {
    
    public static List<Account> getAccountsByCustomerGroup (String customerGroup) {
       
        return [SELECT  Id, Name, Description, Customer_Group__c, Account_Type__c 
                                        FROM Account  
                                        WHERE Customer_Group__c LIKE :customerGroup
                                        LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows()) ];
    } 
   
public static List<Account> getAccountsByCustomerGroupforoverview (String customerGroup,String BuisnessUnit) {
    List<Account> acc=new list<Account>();
    acc= [SELECT  Id, Name, Description, Customer_Group__c, Account_Type__c 
     FROM Account where id IN(select Account__c from Teams__c where Is_Primary__c=true AND  BU__c=:BuisnessUnit And Account__r.Customer_Group__c LIKE :customerGroup   ) LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())];
    return acc;

}
}