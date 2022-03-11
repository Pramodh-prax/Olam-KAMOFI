public class OpportunityConstants {

    public static final Id DEFEND_OPPORTUNITY_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defend_Opportunity').getRecordTypeId();
    public static final Id DEVELOP_OPPORTUNITY_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Develop_Opportunity').getRecordTypeId();
    public static final Id GAIN_OPPORTUNITY_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Gain_Opportunity').getRecordTypeId();
    public static final Id SERVICE_OPPORTUNITY_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
    public static final Id PRESENT_OPPORTUNITY_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Present').getRecordTypeId();
    public static final Id TENDERING_OPPORTUNITY_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Tendering_Opportunity').getRecordTypeId();
    public static final Id PLBS_TENDERING_OPPORTUNITY_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PLBS_Tendering_Opportunity').getRecordTypeId();
    public static final Id PLBS_TENDERING_PRODUCT_RECORD_TYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PLBS_Tendering_Product').getRecordTypeId();
    
    public static final String OPPORTUNITY_STAGE_CLOSING_WON = 'Closing Won';
    public static final String OPPORTUNITY_STAGE_CLOSED = 'Closed';

    public static final String OPPTY_DEV_RT = 'Develop Opportunity';
    public static final String OPPTY_DEFEND_RT = 'Defend Opportunity';
    
    public static final String sampleStatus_New = '1';
    public static final String sampleStatus_Samples_Sent = '5';
    public static final String sampleStatus_Pending_Feedback = '12';
    public static final String sampleStatus_Resampling = '10';
    public static final String sampleStatus_Sample_Accepted = '7';
    public static final String sampleStatus_Sample_Rejected = '8';
    public static final String sampleStatus_Resample_Sent_to_the_Customer = '6';
    public static final String sampleStatus_Sample_Approved_asking_for_bulk_sample = '9';
    public static final String sampleStatus_Kept_on_Hold = '13';
    public static final String sampleStatus_No_Response = '14';
    public static final String sampleStatus_Project_Dropped = '16'; 
    
    public static final String OPPORTUNITY_STAGE_BRIEFING = 'Briefing'; 
    
    public static final String OPPORTUNITY_TEAM_MEMBER_EDIT_ACCESS = 'Edit'; 
    public static final String OPPORTUNITY_TEAM_PDandI_MEMBER_ROLE = 'PD&I Member'; 
    
    public static final String OPPORTUNITY_BU_STANDARD_PRICEBOOK_NAME = 'Standard Price Book';
    public static final String OPPORTUNITY_BU_SPICES_PRICEBOOK_NAME = 'Spices Price Book'; 
    public static final String OPPORTUNITY_BU_COCOA_PRICEBOOK_NAME = 'Cocoa Price Book';
    public static final String OPPORTUNITY_BU_DAIRY_PRICEBOOK_NAME = 'Dairy OIL Price Book'; 
    public static final String OPPORTUNITY_BU_EDIBLE_NUTS_PRICEBOOK_NAME = 'Edible Nuts Price Book';
    
    public static final String OPPORTUNITY_BU_SPICES = 'Spice'; 
    public static final String OPPORTUNITY_BU_COCOA= 'Cocoa';
    public static final String OPPORTUNITY_BU_DAIRY = 'Dairy'; 
    public static final String OPPORTUNITY_BU_EDIBLE_NUTS = 'Edible_Nuts';
    public static final String EDIT_ACCESS = 'Edit Access'; 
    public static final String OFI_BU_ALL = 'All'; 
    
}