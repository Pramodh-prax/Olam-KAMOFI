@isTest
public class OlamSharingHelper_TestNoDml {
    
	@isTest
    public static void testIsTeamMatchWithBU() {
        Boolean res = OlamSharingHelper.isTeamMatchWithBU('Cocoa Sales Manager', 'Cocoa');
        System.assertEquals(true, res);
        
        res = OlamSharingHelper.isTeamMatchWithBU('Dairy Sales Manager', 'Dairy');
        System.assertEquals(true, res);
        
        /* Test return false */
        res = OlamSharingHelper.isTeamMatchWithBU('Cocoa Sales Manager', 'Dairy');
        System.assertEquals(false, res);
        
        res = OlamSharingHelper.isTeamMatchWithBU('Dairy Sales Manager', 'Cocoa');
        System.assertEquals(false, res);
        
        res = OlamSharingHelper.isTeamMatchWithBU('Not supported role', 'Cocoa');
        System.assertEquals(false, res);
        
        res = OlamSharingHelper.isTeamMatchWithBU('Not supported role', 'Dairy');
        System.assertEquals(false, res);
    }   
    
    @isTest
    public static void testIsCocoaPrimary() {
        Boolean res = OlamSharingHelper.isCocoaPrimary(true, 'Cocoa Sales Manager');
        System.assertEquals(true, res);
        
        /* Test return false */
        res = OlamSharingHelper.isCocoaPrimary(false, 'Cocoa Sales Manager');
        System.assertEquals(false, res);
        
        res = OlamSharingHelper.isCocoaPrimary(false, 'Not supported role');
        System.assertEquals(false, res);
    }
    
    @isTest
    public static void testIsDairyPrimary() {
        Boolean res = OlamSharingHelper.isDairyPrimary(true, 'Dairy Sales Manager');
        System.assertEquals(true, res);
        
        /* Test return false */
        res = OlamSharingHelper.isDairyPrimary(false, 'Dairy Sales Manager');
        System.assertEquals(false, res);
        
        res = OlamSharingHelper.isDairyPrimary(false, 'Not supported role');
        System.assertEquals(false, res);
    }
    
    @isTest
    public static void testGenerateSharingKey() {
        Id objId = Id.valueOf('a00000000000000001');
        Id userId = Id.valueOf('a00000000000000002');
        String res = OlamSharingHelper.generateSharingKey(objId, userId);
        System.assertEquals('a00000000000000001_a00000000000000002', res);
    }
    
    @isTest
    public static void testGenerateSharingKeyWithRowCause() {
        Id objId = Id.valueOf('a00000000000000001');
        Id userId = Id.valueOf('a00000000000000002');
        String res = OlamSharingHelper.generateSharingKeyWithRowCause(objId, userId);
        System.assertEquals('a00000000000000001_a00000000000000002_Manual', res);
    }
    
    @isTest
    public static void testCreateObjectShare() {
		Id parentId = Id.valueOf('a00000000000000001');
        Id userId = Id.valueOf('a00000000000000002');
        
        OpportunityShare res1 = (OpportunityShare)OlamSharingHelper.createObjectShare('Opportunity', parentId, userId);
        System.assertEquals(parentId, res1.OpportunityId);
        System.assertEquals(userId, res1.UserOrGroupId);
        
        Interactions__Share res2 = (Interactions__Share)OlamSharingHelper.createObjectShare('Interactions__c', parentId, userId);
        System.assertEquals(parentId, res2.ParentId);
        System.assertEquals(userId, res2.UserOrGroupId);
        
        Consumption__Share res3 = (Consumption__Share)OlamSharingHelper.createObjectShare('Consumption__c', parentId, userId);
        System.assertEquals(parentId, res3.ParentId);
        System.assertEquals(userId, res3.UserOrGroupId);
        
        SObject res = OlamSharingHelper.createObjectShare('Not_Support', parentId, userId);
        System.assertEquals(null, res);
        
        res = OlamSharingHelper.createObjectShare('Opportunity', null, userId);
        System.assertEquals(null, res);
        
        res = OlamSharingHelper.createObjectShare('Opportunity', parentId, null);
        System.assertEquals(null, res);
    }
}