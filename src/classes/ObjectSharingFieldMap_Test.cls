@isTest
public class ObjectSharingFieldMap_Test {
	
    @isTest
    public static void testOpportunity() {
        ObjectSharingFieldMap fieldMap = new ObjectSharingFieldMap('opportunity');
        
        System.assertEquals('AccountId', fieldMap.objectAccountId);
        System.assertEquals('Business_Unit__c', fieldMap.objectBU);
        System.assertEquals('OpportunityShare', fieldMap.shareObjectName);
        System.assertEquals('OpportunityId', fieldMap.shareParentId);
        System.assertEquals('OpportunityAccessLevel', fieldMap.shareAccessLevel);
    }
    
    @isTest
    public static void testInteractions() {
        ObjectSharingFieldMap fieldMap = new ObjectSharingFieldMap('Interactions__c');
        
        System.assertEquals('Account__c', fieldMap.objectAccountId);
        System.assertEquals('Business_Unit__c', fieldMap.objectBU);
        System.assertEquals('Interactions__Share', fieldMap.shareObjectName);
        System.assertEquals('ParentId', fieldMap.shareParentId);
        System.assertEquals('AccessLevel', fieldMap.shareAccessLevel);
    }
    
    @isTest
    public static void testConsumption() {
        ObjectSharingFieldMap fieldMap = new ObjectSharingFieldMap('Consumption__c');
        
        System.assertEquals('Account__c', fieldMap.objectAccountId);
        System.assertEquals('Business_Unit__c', fieldMap.objectBU);
        System.assertEquals('Consumption__Share', fieldMap.shareObjectName);
        System.assertEquals('ParentId', fieldMap.shareParentId);
        System.assertEquals('AccessLevel', fieldMap.shareAccessLevel);
    }
}