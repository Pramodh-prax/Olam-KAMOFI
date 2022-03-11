public class OlamObjectSharing {

    private Map<Id, List<SObject>> accountObjectMap;
    private List<SObject> objectList;
    private string accountIdFieldName;
    private string objectName;
    private ObjectSharingFieldMap objFieldMap;
    
    public OlamObjectSharing(String objName, List<SObject> inputs) {
        objectList = inputs;
        OlamLogger.logPretty('OlamObjectSharing for ' + objName, inputs);
        objFieldMap = new ObjectSharingFieldMap(objName);
        objectName = objName;
        accountIdFieldName = objFieldMap.objectAccountId;
        accountObjectMap = new Map<Id, List<SObject>>();
        for(SObject obj : inputs) {
            Id accountId = (Id)obj.get(accountIdFieldName);
            if(!accountObjectMap.containsKey(accountId)) {
                accountObjectMap.put(accountId, new List<SObject>());
            }
            accountObjectMap.get(accountId).add(obj);
        }
    }

    private List<SObject> getNewObjectShareList() {
        List<SObject> objShareList = new List<SObject>();
        Set<Id> accountIdList = accountObjectMap.keySet();
        
        for(Teams__c team: [Select Id, User__c , Account__c, Role_Name__c  
                                            from Teams__c 
                                            where Account__c in :accountIdList]) {
            for(SObject obj: accountObjectMap.get(team.Account__c)) {
                OlamLogger.log('getNewObjectShareList ' + team.User__c + ', ' + (Id)obj.get('OwnerId') + ', ' + team.Role_Name__c + ', ' + (String)obj.get('Business_Unit__c'));
                if(team.User__c <> (Id)obj.get('OwnerId') && 
                   OlamSharingHelper.isTeamMatchWithBU(team.Role_Name__c, (String)obj.get(objFieldMap.objectBU))) {
                    objShareList.add(OlamSharingHelper.createObjectShare(objectName, (Id)obj.get('Id'), team.User__c));
                }
            }
        }
        OlamLogger.logPretty('getNewObjectShareList return', objShareList);
        return objShareList;
    }
    
    public void addSharing() {
        List<SObject> objShareList = getNewObjectShareList();
        objShareList = OlamSharingHelper.filterDuplicateObjectShare(objectName, objShareList);
        insert objShareList;
    }

}