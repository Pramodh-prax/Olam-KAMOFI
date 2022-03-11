public class OlamTeamSharing {
    
    private Set<Id> accountList;
    private Map<Id, List<Teams__c>> accountTeamsMap;
    
    public OlamTeamSharing(List<Teams__c> inputs) {
        accountList = new Set<Id>();
        accountTeamsMap = new Map<Id, List<Teams__c>>();
        for(Teams__c team : inputs) {
            accountList.Add(team.Account__c);
            if(!accountTeamsMap.containsKey(team.Account__c)) {
                accountTeamsMap.put(team.Account__c, new List<Teams__c>());
            }
            accountTeamsMap.get(team.Account__c).add(team);
        }
        // OlamLogger.log('OlamTeamSharing - accountTeamsMap =' + JSON.serializePretty(accountTeamsMap));
    }
    
    private List<SObject> queryObject(String objName, String accountFieldName) {
        String query = 'SELECT Id, Business_Unit__c, ' + accountFieldName;
        query += ' FROM ' + objName;
		query += ' WHERE ' + accountFieldName + ' in :accountList';
        //OlamLogger.log('OlamTeamSharing - queryObject string = '  + query);
        List<SObject> ret = Database.query(query);
        //OlamLogger.logPretty('OlamTeamSharing - queryObject result', ret);
		return ret;
    }

    private List<SObject> getObjectShareList(String objName) {
        ObjectSharingFieldMap fieldMap = new ObjectSharingFieldMap(objName);
        String accountFieldName = fieldMap.objectAccountId;
        String businessUnitFieldName = fieldMap.objectBU;
        
        List<SObject> objShareList = new List<SObject>();
        for(SObject obj: queryObject(objName, accountFieldName)) {               
            for(Teams__c team: accountTeamsMap.get((Id)obj.get(accountFieldName))) {
                if(OlamSharingHelper.isTeamMatchWithBU(team.Role_Name__c, (String)obj.get(businessUnitFieldName))) {
                    SObject objShare = OlamSharingHelper.createObjectShare(objName, (Id)obj.get('Id'), team.User__c);
                    if(objShare != null)
                    	objShareList.add(objShare);
                }
            }
        }
        //OlamLogger.logPretty('OlamTeamSharing - getObjectShareList return', objShareList);
        return objShareList;
    }
    
    public void addSharing() {
        List<OpportunityShare> oppShareList = getObjectShareList('opportunity');
        oppShareList = OlamSharingHelper.filterDuplicateObjectShare('opportunity', oppShareList);
        insert oppShareList;
        
        List<Interactions__Share> interactionShareList = getObjectShareList('Interactions__c');
        interactionShareList = OlamSharingHelper.filterDuplicateObjectShare('Interactions__c', interactionShareList);
        insert interactionShareList;
        
        List<Consumption__Share> consumptionShareList = getObjectShareList('Consumption__c');
        consumptionShareList = OlamSharingHelper.filterDuplicateObjectShare('Consumption__c', consumptionShareList);
        insert consumptionShareList;
    }
    
    public void removeSharing() {
        List<OpportunityShare> oppShareExpectToDeleteList = getObjectShareList('opportunity');
        oppShareExpectToDeleteList = OlamSharingHelper.getObjectShareToDeleteList('opportunity', oppShareExpectToDeleteList);
        delete oppShareExpectToDeleteList;

        List<OpportunityShare> interactionShareExpectToDeleteList = getObjectShareList('Interactions__c');
        interactionShareExpectToDeleteList = OlamSharingHelper.getObjectShareToDeleteList('Interactions__c', interactionShareExpectToDeleteList);
        delete interactionShareExpectToDeleteList;
        
        List<OpportunityShare> consumptionShareExpectToDeleteList = getObjectShareList('Consumption__c');
        consumptionShareExpectToDeleteList = OlamSharingHelper.getObjectShareToDeleteList('Consumption__c', consumptionShareExpectToDeleteList);
        delete consumptionShareExpectToDeleteList;
    }
    
    public void clearAccountBUOwner() {
        List<Account> accToUpdate = new List<Account>();
        for(Account acc: [Select Id, Cocoa_Owner__c , Dairy_Owner_Id__c , Spice_Owner_Id__c, Edible_Nuts_Owner_Id__c
                                            from Account 
                                            where Id in :accountList]) {                                               
            for(Teams__c team: accountTeamsMap.get(acc.Id)) {  
                if(OlamSharingHelper.isCocoaPrimary(team.Is_Primary__c, team.Role_Name__c)) {
                    acc.Cocoa_Owner__c = null;
                    accToUpdate.add(acc);
                } 
                else if(OlamSharingHelper.isDairyPrimary(team.Is_Primary__c, team.Role_Name__c)) {
                    acc.Dairy_Owner_Id__c = null;
                    accToUpdate.add(acc);
                }
              	else if(OlamSharingHelper.isSpicePrimary(team.Is_Primary__c, team.Role_Name__c)) {
                    acc.Spice_Owner_Id__c = null;
                    accToUpdate.add(acc);
                }
                else if(OlamSharingHelper.isEdibleNutsPrimary(team.Is_Primary__c, team.Role_Name__c)) {
                    acc.Edible_Nuts_Owner_Id__c = null;
                    accToUpdate.add(acc);
                }
            }
		}
        if(!accToUpdate.isEmpty())
        	update accToUpdate;
    }
}