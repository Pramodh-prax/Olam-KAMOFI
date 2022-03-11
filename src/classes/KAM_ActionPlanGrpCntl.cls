public without sharing class KAM_ActionPlanGrpCntl implements KAM_AccountPlan{
    public String getDetails (String data) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        if (requestMap.containsKey ('accountPlan')) {
            return JSON.serialize(getAccountsAndPlansByCustomerGroup ((Account_Plans__c) JSON.deserialize(JSON.serialize(requestMap.get ('accountPlan')), Account_Plans__c.class) ));
        }
        return null;
    }

    public List<Account> getAccountsAndPlansByCustomerGroup (Account_Plans__c accountPlan) {
        try {
            if (accountPlan == null || String.isBlank(accountPlan.Customer_Group__c)) {
                NullPointerException e = new NullPointerException ();
                e.setMessage(Label.KAM_Invalid_Account_Plan_Detail_Error_Message);
                throw e;
            }
            return [
                SELECT Id, Name, 
                    (SELECT Id,Name, Description__c, EndDate__c, StartDate__c, Type__c, BU_Identifier__c,
                        Year__c,Account__c from Account_Plans__r 
                        WHERE StartDate__c =: accountPlan.StartDate__c
                        AND EndDate__c =: accountPlan.EndDate__c
                        AND BU_Identifier__c =: accountPlan.BU_Identifier__c
                    )  FROM Account
                WHERE Customer_Group__c =: accountPlan.Customer_Group__c
                LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<Opportunity> getGroupDefendDevelopGainOpportunities (Account_Plans__c accPlan, String accIdStr) {
        try {
            return OpportunitySelector.getGroupDefendDevelopGainOpportunities  (
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
    public static List<Opportunity> getDefendDevelopGainOpportunities (String accountPlanStr) {
        return KAM_ActionPlanCntl.getDefendDevelopGainOpportunities ((Account_Plans__c) JSON.deserialize (accountPlanStr, Account_Plans__c.class));
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
    @AuraEnabled(cacheable=true) 
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