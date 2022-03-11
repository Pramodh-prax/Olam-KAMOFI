public class SamplingRequestToOSSMController {
    @AuraEnabled
    public static String createSampleRequest(String opportunityId){
        String message = 'SUCCESS';
        Boolean hasError = false;
        Boolean reprocessFailedRequest = false;
        
        Opportunity opp = new Opportunity();
        opp = getOpportunity(opportunityId);
        
        if(opp.OpportunityLineItems == null || opp.OpportunityLineItems.size() == 0){
            message = 'Please add a product for sampling!';
            hasError = true;
        }
        
        /*if(opp.OpportunityLineItems != null && opp.OpportunityLineItems.size() > 1){
            message = 'Please make sure only one product is added to the opportuntiy!';
            hasError = true;
        }*/
        
        if(opp.PDI_Member__c == null){
            message = 'Please make sure PDI Member is added!';
            hasError = true;
        }
        
        if(opp.PLM_Approval_Status__c != 'Approved' || opp.PDNI_Approval_Status__c != 'Approved'){
            message = 'Opportunity needs to be approved by both PLM and PDI Lead before submitting to OSSM!';
            hasError = true;
        }        
        
        List<Sample_Request__c> sampleRequestList = new List<Sample_Request__c>();
        sampleRequestList = getSampleRequests(opportunityId);
        
        if(sampleRequestList.size() > 0){
            if(sampleRequestList[0].Integration_Status__c == 'failed'){
                Sample_Request__c sampleRequestToUpdate = new Sample_Request__c(
                    Id = sampleRequestList[0].Id,
                    PD_I__c = opp.PDI_Member__c
                );
                update sampleRequestToUpdate;
                
                List<OpportunityLineItem> oppLineListToUpdate = new List<OpportunityLineItem>();
                for(OpportunityLineItem oppLine :opp.OpportunityLineItems){
                    oppLine.Opportunity_Owner__c = opp.OwnerId;
                    oppLine.PD_I_User__c = opp.PDI_Member__c;
                    oppLineListToUpdate.add(oppLine);
                }
                update oppLineListToUpdate;
                
                DELETE [SELECT Id FROM Sample_Request_Line_Item__c WHERE Sample_Request__c = :sampleRequestList[0].Id];
                
                List<Sample_Request_Line_Item__c> sampleLineListToInsert = new List<Sample_Request_Line_Item__c>();
                for(OpportunityLineItem oppLine :opp.OpportunityLineItems){
                    sampleLineListToInsert.add(createSampleRequestLine(sampleRequestList[0], oppLine));
                }
                insert sampleLineListToInsert;
                
                //publishPlatformEvent(sampleRequestList[0].Id);
                reprocessFailedRequest = true;
            }
            else{
                message = 'This opportunity has already been submitted for sampling!';
                hasError = true;
            }
        }
        
        if(hasError == false && reprocessFailedRequest == false){
            Sample_Request__c sampleRequest = createSampleRequest(opp);
            insert sampleRequest;
            
            List<OpportunityLineItem> oppLineListToUpdate = new List<OpportunityLineItem>();
            for(OpportunityLineItem oppLine :opp.OpportunityLineItems){
                oppLine.Opportunity_Owner__c = opp.OwnerId;
                oppLine.PD_I_User__c = opp.PDI_Member__c;
                oppLineListToUpdate.add(oppLine);
            }
            update oppLineListToUpdate;
            
            List<Sample_Request_Line_Item__c> sampleLineListToInsert = new List<Sample_Request_Line_Item__c>();
            for(OpportunityLineItem oppLine :opp.OpportunityLineItems){
                sampleLineListToInsert.add(createSampleRequestLine(sampleRequest, oppLine));
            }
            insert sampleLineListToInsert;
        }
        
        return message;
    }
    
    
    public static Sample_Request__c createSampleRequest(Opportunity opp){
        return new Sample_Request__c(
            Account__c = opp.AccountId,
            Opportunity__c = opp.Id,
            Sample_Due_Date__c = opp.First_Sample_Due_Date__c,
            Region__c = opp.Account.Regions__c,
            Country__c = opp.Account.BillingCountryCode,
            Sample_Requested_Date__c = Date.valueOf(opp.CreatedDate),
            PD_I__c = opp.PDI_Member__c
        );   
    }
    
    
    public static Sample_Request_Line_Item__c createSampleRequestLine(Sample_Request__c sampleRequest, OpportunityLineItem oppLine){
        return new Sample_Request_Line_Item__c(
                Sample_Request__c = sampleRequest.Id,
                Product__c = oppLine.Product2Id,
                Opportunity_Product__c = oppLine.Id,
                Sampling_Status__c = oppLine.Sampling_Status__c,
                Unit_of_measure__c = oppLine.UoM__c,
                Integration_Status__c = 'create',
                Tracking_Number__c = oppLine.Tracking_Number__c,
                Sample_with_Billing__c = oppLine.Sample_with_Billing__c,
                Sample_Feedback__c = oppLine.Sample_Feedback__c,
                Quantity__c = oppLine.Quantity_of_Sample_Grams__c,
                Development_Code__c = oppLine.Product2.Development_Code__c
            );
    }
    
    
    public static Opportunity getOpportunity(String opportunityId){
        return [SELECT Id, Name, AccountId, First_Sample_Due_Date__c, Account.Regions__c, Account.BillingCountryCode,
                CreatedDate, OwnerId,PLM_Approval_Status__c, PDNI_Approval_Status__c, PDI_Lead__c, PDI_Member__c,
               (
                   SELECT Id, Product2Id, Sampling_Status__c, UoM__c, Tracking_Number__c, Sample_with_Billing__c, 
                   Sample_Feedback__c, Quantity_of_Sample_Grams__c, Product2.Development_Code__c 
                   FROM OpportunityLineItems
               )
               FROM Opportunity
               WHERE Id = :opportunityId];
    }
    
    
    public static List<Sample_Request__c> getSampleRequests(String opportunityId){
        return [SELECT Id, Opportunity__c, Integration_Status__c,
                (SELECT Id FROM Sample_Request_Line_Items__r)
                FROM Sample_Request__c WHERE Opportunity__c = :opportunityId];
    }
    
    
    public static void publishPlatformEvent(String sampleRequestId){
        SampleRequest__e srEvent = new SampleRequest__e(SampleRequestId__c = sampleRequestId);
        
        Database.SaveResult result = EventBus.publish(srEvent);
        if (result.isSuccess()) {
            System.debug('Successfully published event.');
        } else {
            for(Database.Error err : result.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
        }       
    }
}