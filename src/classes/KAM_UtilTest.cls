@isTest
public class KAM_UtilTest {
    
    @isTest
    static  void testGetPickListValues() {
        List<KAM_Util.PicklistEntry> pickListEntries = KAM_Util.getPickListValues('Account', 'BillingCountryCode', true, true);
        System.assert(!pickListEntries.isEmpty (), 'Values not found for the give pick list field');
        
        pickListEntries = KAM_Util.getPickListValues('Engagement_Plan_Line__c', 'Type_of_Engagement__c', true, false);
        System.assert(!pickListEntries.isEmpty (), 'Values not found for the give pick list field');
    }
}