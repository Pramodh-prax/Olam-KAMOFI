public class ObjectSharingFieldMap {
    
    public String objectName;
    public String objectAccountId;
    public String objectBU;
    
    public String shareObjectName;
    public String shareParentId;
    public String shareAccessLevel;
    
    public ObjectSharingFieldMap(string objName) {
        if(objName.equalsIgnoreCase('Opportunity')) {
            objectAccountId = 'AccountId';
            objectBU = 'Business_Unit__c';
            shareObjectName = 'OpportunityShare';
            shareParentId = 'OpportunityId';
            shareAccessLevel = 'OpportunityAccessLevel';
        }
        else if(objName.equalsIgnoreCase('Interactions__c')) {
            objectAccountId = 'Account__c';
            objectBU = 'Business_Unit__c';
            shareObjectName = 'Interactions__Share';
            shareParentId = 'ParentId';
            shareAccessLevel = 'AccessLevel';
        }
        else if(objName.equalsIgnoreCase('Consumption__c')) {
            objectAccountId = 'Account__c';
            objectBU = 'Business_Unit__c';
            shareObjectName = 'Consumption__Share';
            shareParentId = 'ParentId';
            shareAccessLevel = 'AccessLevel';
        }
    }
}