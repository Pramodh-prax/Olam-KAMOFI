public class OlamSharingHelper {
	public static final String OLAM_ROWCAUSE = 'Manual';
    public static final String OWNER_ROWCAUSE = 'Owner';
    public static final String PERMISSION_EDIT = 'Edit';
    public static final String PERMISSION_VIEW = 'Read';
    public static final String COCOA_SALES_MANAGER = 'Cocoa Sales Manager';
    public static final String DAIRY_SALES_MANAGER = 'Dairy Sales Manager';
    public static final String SPICE_SALES_MANAGER = 'Spice Sales Manager';
    public static final String EDIBLE_NUTS_SALES_MANAGER = 'Edible_Nuts Sales Manager';
    public static final String COCOA_BU = 'Cocoa';
    public static final String Dairy_BU = 'Dairy';
    public static final String Spice_BU = 'Spice';
    public static final String Edible_Nuts_BU = 'Edible_Nuts';
    
    public static boolean isTeamMatchWithBU(String teamRoleName, String businessUnit) {
        return (teamRoleName.equalsIgnoreCase(COCOA_SALES_MANAGER) && businessUnit.equalsIgnoreCase(COCOA_BU)) ||
               (teamRoleName.equalsIgnoreCase(DAIRY_SALES_MANAGER) && businessUnit.equalsIgnoreCase(Dairy_BU)) ||
               (teamRoleName.equalsIgnoreCase(SPICE_SALES_MANAGER) && businessUnit.equalsIgnoreCase(Spice_BU)) ||
               (teamRoleName.equalsIgnoreCase(EDIBLE_NUTS_SALES_MANAGER) && businessUnit.equalsIgnoreCase(Edible_Nuts_BU));
    }
    
    public static boolean isCocoaPrimary(boolean isPrimary, String teamRole) {
        return isPrimary && teamRole.equalsIgnoreCase(COCOA_SALES_MANAGER);
    }
    
    public static boolean isDairyPrimary(boolean isPrimary, String teamRole) {
        return isPrimary && teamRole.equalsIgnoreCase(DAIRY_SALES_MANAGER);
    }
    
   	public static boolean isSpicePrimary(boolean isPrimary, String teamRole) {
        return isPrimary && teamRole.equalsIgnoreCase(SPICE_SALES_MANAGER);
    }
    public static boolean isEdibleNutsPrimary(boolean isPrimary, String teamRole) {
        return isPrimary && teamRole.equalsIgnoreCase(EDIBLE_NUTS_SALES_MANAGER);
        
    }
    public static List<SObject> queryShareObjectByParentIdList(String objectName, Set<Id> filterParentList, Boolean isFilterRowCause) {
     	ObjectSharingFieldMap fieldMap = new ObjectSharingFieldMap(objectName);
        return queryShareObjectByParentIdList(fieldMap.shareObjectName, fieldMap.shareParentId, filterParentList, isFilterRowCause);
    }
    
    private static List<SObject> queryShareObjectByParentIdList(String objShareName, String parentIdFieldName, Set<Id> filterParentList, Boolean isIncludeOwnerRowCause) {
        String query = 'SELECT Id, RowCause, UserOrGroupId, ' + parentIdFieldName;
        query += ' FROM ' + objShareName;
		query += ' WHERE ' + parentIdFieldName + ' in :filterParentList';
        if(isIncludeOwnerRowCause)
            query += ' and ( RowCause = :OLAM_ROWCAUSE or RowCause = :OWNER_ROWCAUSE )';
        else
            query += ' and RowCause = :OLAM_ROWCAUSE';
        query += ' ORDER BY RowCause ASC';
        OlamLogger.log('queryShareObjectByParentIdList - query = ' + query);
        List<SObject> ret = Database.query(query);
        OlamLogger.logPretty('queryShareObjectByParentIdList return', ret);
		return ret;
    }
    
    public static List<SObject> filterDuplicateObjectShare(String objectName, List<SObject> objectShareList) {
        ObjectSharingFieldMap fieldMap = new ObjectSharingFieldMap(objectName);
        return filterDuplicateObjectShare(fieldMap.shareObjectName, fieldMap.shareParentId, objectShareList);
    }
    
    public static List<SObject> filterDuplicateObjectShare(String objectShareName, String parentIdFieldName, List<SObject> objectShareList) {
        OlamLogger.logPretty('filterDuplicateObjectShare - objectShareList input', objectShareList);
        Set<Id> filterIdList = new Set<Id>();
        for(SObject shareObject : objectShareList)
            filterIdList.add((Id)shareObject.get(parentIdFieldName));
        
		List<SObject> shareDupList = queryShareObjectByParentIdList(objectShareName, parentIdFieldName, filterIdList, true);
        if(!shareDupList.isEmpty()) {
            Map<String, Boolean> shareDupMap = new Map<String, Boolean>();
            for(SObject shareDup: shareDupList) {
				shareDupMap.put(generateSharingKey((String)shareDup.get(parentIdFieldName), (String)shareDup.get('UserOrGroupId')), true);
            }
            List<SObject> objShareListUpdated = new List<SObject>();
            for(SObject objShare: objectShareList) {
                if(!shareDupMap.containsKey(generateSharingKey((String)objShare.get(parentIdFieldName), (String)objShare.get('UserOrGroupId')))) {
                    objShareListUpdated.add(objShare);
                }
            }
            OlamLogger.logPretty('filterDuplicateObjectShare - objectShareList return', objShareListUpdated);
            return objShareListUpdated;
        }
        OlamLogger.logPretty('filterDuplicateObjectShare - objectShareList return', objectShareList);
        return objectShareList;
    }
    
    public static String generateSharingKey(Id objId, Id userId) {
        return objId + '_' + userId;
    }
    
    public static String generateSharingKeyWithRowCause(Id objId, Id userId) {
        return generateSharingKey(objId, userId) + '_' + OLAM_ROWCAUSE;
    }
    
    public static List<SObject> getObjectShareToDeleteList(String objectName, List<SObject> objectShareList) {
        ObjectSharingFieldMap fieldMap = new ObjectSharingFieldMap(objectName);
        return getObjectShareToDeleteList(fieldMap.shareObjectName, fieldMap.shareParentId, objectShareList);
    }
    
    private static List<SObject> getObjectShareToDeleteList(String objectShareName, String parentIdFieldName, List<SObject> objectShareList) {
        List<SObject> objShareToDeleteList = new List<SObject>();
        Set<Id> filterIdList = new Set<Id>();
        Map<String, Boolean> objShareToDeleteMap = new Map<String, Boolean>();
        OlamLogger.log('getObjectShareToDeleteList input, ' + objectShareName + ', ' + parentIdFieldName + ',' + objectShareList);
        for(SObject shareObject : objectShareList) {
            filterIdList.add((Id)shareObject.get(parentIdFieldName));
            objShareToDeleteMap.put(generateSharingKey((String)shareObject.get(parentIdFieldName), (String)shareObject.get('UserOrGroupId')), true);
        }
        
        List<SObject> currentShareList = queryShareObjectByParentIdList(objectShareName, parentIdFieldName, filterIdList, false);
        if(!currentShareList.isEmpty()) {
            for(SObject shareObject :currentShareList) {
                if(objShareToDeleteMap.containsKey(generateSharingKey((String)shareObject.get(parentIdFieldName), (String)shareObject.get('UserOrGroupId')))) {
                    objShareToDeleteList.add(shareObject);
                }
			}
        }
        
        return objShareToDeleteList;
    }

    public static SObject createObjectShare(String objectName, Id parentId, Id userId) {
        OlamLogger.log('createObjectShare input = ' + objectName + ', ' + parentId + ', ' + userId);
        if(parentId == null || userId == null)
            return null;
        
        if(objectName.equalsIgnoreCase('Opportunity')) {
            return createOppShare(parentId, userId);
        }
        else if(objectName.equalsIgnoreCase('Interactions__c')) {
            return createInteractionShare(parentId, userId);
        }
        else if(objectName.equalsIgnoreCase('Consumption__c')) {
            return createConsumptionShare(parentId, userId);
        }
        return null;
    }
    
    public static OpportunityShare createOppShare(Id oppId, Id userId) {
        OpportunityShare oppShr = new OpportunityShare();
        oppShr.OpportunityId  = oppId;
        oppShr.UserOrGroupId = userId;
        oppShr.OpportunityAccessLevel = PERMISSION_VIEW;
        oppShr.RowCause = OLAM_ROWCAUSE;
        
        return oppShr;
    }
    
    public static Interactions__Share createInteractionShare(Id interactionId, Id userId) {
		Interactions__Share shr  = new Interactions__Share();
        shr.ParentId  = interactionId;
        shr.UserOrGroupId = userId;
        shr.AccessLevel = PERMISSION_EDIT;
        shr.RowCause = OLAM_ROWCAUSE;
        
        return shr;
    }
    
    public static Consumption__Share createConsumptionShare(Id consumptionId, Id userId) {
        Consumption__Share shr  = new Consumption__Share();
        shr.ParentId  = consumptionId;
        shr.UserOrGroupId = userId;
        shr.AccessLevel = PERMISSION_EDIT;
        shr.RowCause = OLAM_ROWCAUSE;
        
        return shr;
    }
}