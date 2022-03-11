public without sharing class KAM_ActionPlanCntl implements KAM_AccountPlan{
    public String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getDefendDevelopGainOpportunities ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class) ));
        }
        return null;
    }

    @AuraEnabled
    public static List<Opportunity> getPresentationOpportunities (Account_Plans__c accPlan) {
        try {
            return OpportunitySelector.getPresentationOpportunities  (
                        accPlan.Account__c, 
                        accPlan.BU_Identifier__c,
                        accPlan.StartDate__c, 
                        accPlan.EndDate__c
                    );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Opportunity> getServiceOpportunities (Account_Plans__c accPlan) {
        try {
            return OpportunitySelector.getServiceOpportunities  (
                        accPlan.Account__c, 
                        accPlan.BU_Identifier__c,
                        accPlan.StartDate__c, 
                        accPlan.EndDate__c
                    );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Opportunity> getGroupServiceOpportunities (Account_Plans__c accPlan, String accIdStr) {
        try {
            return OpportunitySelector.getGroupServiceOpportunities  (
                        (Set<Id>)JSON.deserialize(accIdStr, Set<Id>.class), 
                        accPlan.BU_Identifier__c,
                        accPlan.StartDate__c, 
                        accPlan.EndDate__c
                    );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Opportunity> getGroupPresentationOpportunities (Account_Plans__c accPlan, String accIdStr) {
        try {
            return OpportunitySelector.getGroupPresentationOpportunities  (
                        (Set<Id>)JSON.deserialize(accIdStr, Set<Id>.class), 
                        accPlan.BU_Identifier__c,
                        accPlan.StartDate__c, 
                        accPlan.EndDate__c
                    );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<Opportunity> getDefendDevelopGainOpportunities (Account_Plans__c accPlan) {
        try {
            return OpportunitySelector.getDefendDevelopGainOpportunities  (
                        accPlan.Account__c, 
                        accPlan.BU_Identifier__c,
                        accPlan.StartDate__c, 
                        accPlan.EndDate__c
                    );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled (cacheable=true)
    public static List<Opportunity> getGroupOpenDefendDevelopOpportunities (Account_Plans__c accPlan, String accIdStr) {
        try {
            return OpportunitySelector.getGroupOpenDefendDevelopOpportunities  (
                        (Set<Id>)JSON.deserialize(accIdStr, Set<Id>.class), 
                        accPlan.BU_Identifier__c,
                        accPlan.StartDate__c, 
                        accPlan.EndDate__c
                    );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpenDefendDevelopOpportunities (Account_Plans__c accPlan) {
        try {
            return OpportunitySelector.getOpenDefendDevelopOpportunities  (
                        accPlan.Account__c, 
                        accPlan.BU_Identifier__c,
                        accPlan.StartDate__c, 
                        accPlan.EndDate__c
                    );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getContentDocumentTitle (Account_Plans__c accPlan) {
        String titleStr = String.valueOf (accPlan.Id).substring (0, 16);
        titleStr += '_' + String.valueOf (accPlan.Account__c).substring (0, 16);
        if (String.isNotBlank(accPlan.BU_Identifier__c)) {
            titleStr += '_' + accPlan.BU_Identifier__c;
        }
        titleStr += '_comments.json';

        return titleStr;
    }
    @AuraEnabled
    public static string getComments(Account_Plans__c accPlan){
        try {
            String titleStr = getContentDocumentTitle (accPlan);

            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocument.title, ContentDocumentId, 
                ContentDocument.LatestPublishedVersionId,
                ContentDocument.LatestPublishedVersion.VersionData 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId =: accPlan.Id 
                AND ContentDocument.title =: titleStr
                LIMIT 1
            ];

            if (contentDocumentLinks == null || contentDocumentLinks.isEmpty ()) {
                return null;
            }
            
            Map<String, Object> resultMap = new Map <String, Object> ();
            resultMap.put('contentDocumentId', contentDocumentLinks[0].ContentDocumentId);
            resultMap.put('comments',  (contentDocumentLinks[0].ContentDocument.LatestPublishedVersion.VersionData.toString ()));

            return JSON.serialize(resultMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string saveComments (Account_Plans__c accPlan, String contentDocumentId, String commentStr){
        try {
            System.debug('In Save Comments controller');
            Map<String, Object> resultMap = new Map <String, Object> ();

            String titleStr = getContentDocumentTitle (accPlan);

            ContentVersion versionData = new ContentVersion();
            versionData.ContentLocation = 'S';
            if (String.isNotBlank(contentDocumentId)) {
                versionData.ContentDocumentId = contentDocumentId;

                resultMap.put('contentDocumentId', contentDocumentId);
            }
            
            versionData.VersionData = Blob.valueOf((commentStr));
            versionData.Title = titleStr;
            versionData.PathOnClient = titleStr;
            insert versionData; 

            resultMap.put('comments', (versionData.VersionData.toString ()));

            if (String.isBlank(contentDocumentId)) {
                ContentDocumentLink conDocLink = new ContentDocumentLink();
                conDocLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :versionData.Id].ContentDocumentId;
                conDocLink.LinkedEntityId = accPlan.Id;
                conDocLink.ShareType = 'V';
                insert conDocLink;

                resultMap.put('contentDocumentId', conDocLink.ContentDocumentId);
            }

            return JSON.serialize(resultMap);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}