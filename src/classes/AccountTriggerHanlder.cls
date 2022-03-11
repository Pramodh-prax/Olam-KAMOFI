public class AccountTriggerHanlder{
    public static void beforeInsert(List<Account> accList){
        //AccountTriggerHelper.validatePostalCode(accList);
    }
    
    
    public static void beforeUpdate(List<Account> accList, Map<Id, Account> accMap){
        //AccountTriggerHelper.validatePostalCode(accList);
    }
}