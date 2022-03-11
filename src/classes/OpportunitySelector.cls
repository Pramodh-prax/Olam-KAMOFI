public inherited sharing class OpportunitySelector {
    public static List<Opportunity> getPresentationOpportunities  (Id accountId, String bu, Date startDate, Date endDate) {
        Set<Id> recordTypes = new Set<Id> {
            OpportunityConstants.PRESENT_OPPORTUNITY_RECORD_TYPE_ID
            
        };

        return [
            SELECT Id, Name, CreatedDate, Estimated_Volume_MT__c, Number_of_Samples_Sent__c, Sample_Sent_Flag__c, Sample_Accepted_Flag__c,
            StageName, LastModifiedDate, OwnerId, Owner.Name, 
            CloseDate, Business_Unit__c, Account.Name, AccountId,
            
            (SELECT Id, Product2.Name, Sample_Sent_Date__c, toLabel(Sampling_Status__c), Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Product2Id
            FROM OpportunityLineItems)

            FROM Opportunity
            WHERE AccountId =: accountId
            AND RecordTypeId in: recordTypes
            AND Business_Unit__c =: bu
            AND (CloseDate >=: startDate AND CloseDate <=: endDate)
        ];
    }
    public static List<Opportunity> getServiceOpportunities  (Id accountId, String bu, Date startDate, Date endDate) {
        Set<Id> recordTypes = new Set<Id> {
           
            OpportunityConstants.SERVICE_OPPORTUNITY_RECORD_TYPE_ID
        };

        return [
            SELECT Id, Name, CreatedDate, Estimated_Volume_MT__c, Number_of_Samples_Sent__c, Sample_Sent_Flag__c, Sample_Accepted_Flag__c,
            StageName, LastModifiedDate, OwnerId, Owner.Name, 
            CloseDate, Business_Unit__c, Account.Name, AccountId,
            
            (SELECT Id, Product2.Name, Sample_Sent_Date__c, toLabel(Sampling_Status__c), Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Product2Id
            FROM OpportunityLineItems)

            FROM Opportunity
            WHERE AccountId =: accountId
            AND RecordTypeId in: recordTypes
            AND Business_Unit__c =: bu
            AND (CloseDate >=: startDate AND CloseDate <=: endDate)
        ];
    }
    
    public static List<Opportunity> getGroupPresentationOpportunities  (Set<Id> accountIds, String bu, Date startDate, Date endDate) {
        Set<Id> recordTypes = new Set<Id> {
            OpportunityConstants.PRESENT_OPPORTUNITY_RECORD_TYPE_ID
        };

        return [
            SELECT Id, Name, CreatedDate, Estimated_Volume_MT__c, Number_of_Samples_Sent__c, Sample_Sent_Flag__c, Sample_Accepted_Flag__c,
            StageName, LastModifiedDate, OwnerId, Owner.Name, 
            CloseDate, Business_Unit__c, Account.Name, AccountId,
            
            (SELECT Id, Product2.Name, Sample_Sent_Date__c, toLabel(Sampling_Status__c), Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Product2Id
            FROM OpportunityLineItems)

            FROM Opportunity
            WHERE AccountId in: accountIds
            AND RecordTypeId in: recordTypes
            AND Business_Unit__c =: bu
            AND (CloseDate >=: startDate AND CloseDate <=: endDate)
        ];
    }
    public static List<Opportunity> getGroupServiceOpportunities  (Set<Id> accountIds, String bu, Date startDate, Date endDate) {
        Set<Id> recordTypes = new Set<Id> {
            OpportunityConstants.SERVICE_OPPORTUNITY_RECORD_TYPE_ID
        };
        System.debug('in service');
        return [
            SELECT Id, Name, CreatedDate, Estimated_Volume_MT__c, Number_of_Samples_Sent__c, Sample_Sent_Flag__c, Sample_Accepted_Flag__c,
            StageName, LastModifiedDate, OwnerId, Owner.Name, 
            CloseDate, Business_Unit__c, Account.Name, AccountId,
            
            (SELECT Id, Product2.Name, Sample_Sent_Date__c, toLabel(Sampling_Status__c), Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Product2Id
            FROM OpportunityLineItems)

            FROM Opportunity
            WHERE AccountId in: accountIds
            AND RecordTypeId in: recordTypes
            AND Business_Unit__c =: bu
            AND (CloseDate >=: startDate AND CloseDate <=: endDate)
        ];
    }
    public static List<Opportunity> getDefendDevelopGainOpportunities (Id accountId, String bu, Date startDate, Date endDate) {
        Set<Id> recordTypes = new Set<Id> {
            OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID,
            OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID,
            OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID
        };

        return [
            SELECT Id, Name, StageName, OwnerId, Owner.Name, 
            CloseDate, Business_Unit__c, IsClosed, Account.Name, AccountId,
            (SELECT Id, Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Converted_Volume_in_MT__c,  Product2Id
            FROM OpportunityLineItems)
            FROM Opportunity
            WHERE AccountId =: accountId
            AND RecordTypeId in: recordTypes
            AND Business_Unit__c =: bu
            AND (CloseDate >=: startDate AND CloseDate <=: endDate)
            //AND StageName =: OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON
        ];
    }
    public static List<Opportunity> getGroupDefendDevelopGainOpportunities (Set<Id> accountIds, String bu, Date startDate, Date endDate) {
        Set<Id> recordTypes = new Set<Id> {
            OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID,
            OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID,
            OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID
        };

        return [
            SELECT Id, Name, StageName, OwnerId, Owner.Name, 
            CloseDate, Business_Unit__c, IsClosed, Account.Name, AccountId,
            (SELECT Id, Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Converted_Volume_in_MT__c, Product2Id
            FROM OpportunityLineItems)
            FROM Opportunity
            WHERE AccountId in: accountIds
            AND RecordTypeId in: recordTypes
            AND Business_Unit__c =: bu
            AND (CloseDate >=: startDate AND CloseDate <=: endDate)
        ];
    }
    

    //Todo : Update the status check which are the status need to be considered
    public static List<Opportunity> getOpenDefendDevelopOpportunities (Id accountId, String bu, Date startDate, Date endDate) {
        Set<Id> recordTypes = new Set<Id> {
            OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID,
            OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID
        };

        return [
            SELECT Id, Name, CreatedDate, Estimated_Volume_MT__c, Number_of_Samples_Sent__c, Sample_Sent_Flag__c, Sample_Accepted_Flag__c, 
            StageName, LastModifiedDate, OwnerId, Owner.Name, 
            CloseDate, Business_Unit__c, Account.Name, AccountId,
            (SELECT Id, Product2.Name, Sample_Sent_Date__c, toLabel(Sampling_Status__c), Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Product2Id, CreatedDate, Sample_Acceptance_Rejection_Date__c
            FROM OpportunityLineItems)
            FROM Opportunity
            WHERE AccountId =: accountId
            AND RecordTypeId in: recordTypes
            AND Business_Unit__c =: bu
            AND (CloseDate >=: startDate AND CloseDate <=: endDate)
            AND StageName !=: OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON
            ORDER BY CreatedDate DESC
        ];
    }
    
    public static List<Opportunity> getGroupOpenDefendDevelopOpportunities (Set<Id> accountIds, String bu, Date startDate, Date endDate) {
        Set<Id> recordTypes = new Set<Id> {
            OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID,
            OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID
        };

        return [
            SELECT Id, Name, CreatedDate, Estimated_Volume_MT__c, Number_of_Samples_Sent__c, Sample_Sent_Flag__c, Sample_Accepted_Flag__c, 
            StageName, LastModifiedDate, OwnerId, Owner.Name, 
            CloseDate, Business_Unit__c, Account.Name, AccountId,
            (SELECT Id, Product2.Name, Sample_Sent_Date__c, toLabel(Sampling_Status__c), Product2.Product_Category__c, 
            Product2.Product_Sub_Category__c, Product2.Product_Sub_Category_2__c,
            Volume__c, Product2Id, CreatedDate, Sample_Acceptance_Rejection_Date__c
            FROM OpportunityLineItems)
            FROM Opportunity
            WHERE AccountId in: accountIds
            AND RecordTypeId in: recordTypes
            AND Business_Unit__c =: bu
            AND (CloseDate >=: startDate AND CloseDate <=: endDate)
            AND StageName !=: OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON
            ORDER BY CreatedDate DESC
        ];
    }
    
    //added by rajat start- 26/7/21
    public static String getOpportunityRecordTypeNameFromId(Id recordtypeId){
        System.debug('Record Type Id - Selector :'+recordtypeId);
        String strRecordDevName ;
        if(recordtypeId != null){
            strRecordDevName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(recordtypeId).getDeveloperName(); 
        }
        System.debug('Record Type Name :'+strRecordDevName);
        if(strRecordDevName != null){
            return strRecordDevName;
        }else {
            return null;
        } 
    }
    //added by rajat end- 26/7/21
}