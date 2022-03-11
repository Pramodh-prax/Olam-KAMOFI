public without sharing class KAM_StakeHoldersCntl implements KAM_AccountPlan{
    
    public String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey('accountId')) {
            return JSON.serialize(getContactsByAccountId (String.valueOf(requestMap.get('accountId'))));
        }
        return null;
    }

    @AuraEnabled
    public static List<Contact> getContactsByAccountId(String accountId){
        try {
            if (String.isBlank(accountId)) {
                return null;
            }
            return [SELECT Id, Title, Name, FirstName, LastName, Email, ReportsToId, Description, Phone,
                    ReportsTo.Name, OwnerId, Owner.Name, AccountId, Account.Name
                    From Contact WHERE AccountId =: accountId
                    LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
                ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}