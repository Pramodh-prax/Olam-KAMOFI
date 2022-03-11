public class AccountMappingTriggerHandler extends TriggerHandlerBase {
    
    private final String SKIPPED = 'Skipped';
    private final String APPLIED = 'Applied';

    public override void handleBeforeInsert() {
        // Account_Name__c
        // SAP_Account_ID__c 
        // Status__c (Applied, Skipped ) 
        // Note__c 
        
        Map<String, Account_Mapping__c> accountMappings = new Map<String, Account_Mapping__c>();
        for(Account_Mapping__c toProcess : (List<Account_Mapping__c>)Trigger.New) {
            if(String.isBlank(toProcess.SAP_Account_ID__c)) {
                toProcess.Status__c = SKIPPED;
                toProcess.Note__c = 'SAP Account ID is null or empty';
            }
            else if(String.isBlank(toProcess.Account_Name__c)) {
                toProcess.Status__c = SKIPPED;
                toProcess.Note__c = 'Account name is null or empty';
            } 
            else if(accountMappings.containsKey(toProcess.Account_Name__c)) { 
                toProcess.Status__c = SKIPPED;
                toProcess.Note__c = 'Duplicate account name in the same batch'; 
                Account_Mapping__c dup = accountMappings.get(toProcess.Account_Name__c);
                if(dup != null) {
                    dup.Status__c = SKIPPED;
                	dup.Note__c = 'Duplicate account name in the same batch';
                }
                accountMappings.put(toProcess.Account_Name__c, null);
            }
            else
                accountMappings.put(toProcess.Account_Name__c, toProcess);
        }
        
        Set<String> accountNames = accountMappings.keySet();
        Map<String, Account> accounts = new Map<String, Account>();
        Map<String, Set<Id>> dupAccounts = new Map<String, Set<Id>>();
        for(Account acc : [Select Id, Name, SAP_Account_ID__c 
                           From Account 
                           where Name in :accountNames]) {
        	if(!dupAccounts.containsKey(acc.Name) && !accounts.containsKey(acc.Name)) {
            	accounts.put(acc.Name, acc);
            }
            else {
            	if(!dupAccounts.containsKey(acc.Name)) {
                    dupAccounts.put(acc.Name, new Set<Id>());
                }
                // Clear the one that was already added into a map
                if(accounts.get(acc.Name) != NULL) {
                    Account dupAcc = accounts.get(acc.Name);
                    dupAccounts.get(acc.Name).add(dupAcc.Id);
                    accounts.put(acc.Name, NULL);
                }
                // Add the new duplcate account to the list
            	dupAccounts.get(acc.Name).add(acc.Id);
            }
        }
        
        List<Account> accountToUpdate = new List<Account>();
        for(String accountName : accountMappings.keySet()) {
            Account_Mapping__c accountMapping = accountMappings.get(accountName);
            if(accountMapping == null) 
                continue;
            Account account = accounts.get(accountName);
            if(account == NULL && dupAccounts.containsKey(accountName)) {
                Set<Id> dupIdSet = dupAccounts.get(accountName);
                String dupIdString = String.join(new List<Id>(dupIdSet), ',');
                accountMapping.Status__c = SKIPPED;
                accountMapping.Note__c = 'Duplicate account name found in SF(' + dupIdString + ')';
            }
            else if(account == NULL) {
                accountMapping.Status__c = SKIPPED;
                accountMapping.Note__c = 'New account';
            }
            else if(String.isNotBlank(account.SAP_Account_ID__c)){
                accountMapping.Status__c = SKIPPED;
                accountMapping.Note__c = 'Id:' + account.Id + ', Already have SAP Account ID';
            }
            else {
                account.SAP_Account_ID__c = accountMapping.SAP_Account_ID__c;
                accountToUpdate.add(account);
                
                accountMapping.Status__c = APPLIED;
                accountMapping.Note__c = 'Id:' + account.Id;
            }
        }
        
        if(!accountToUpdate.isEmpty())
            update accountToUpdate;
    }
}