public class SampleRequestLineItemHelper {
    
    public static void publishPlatformEvent(List<Sample_Request_Line_Item__c> SampleRequestLineItemList){
        List<SampleRequest__e> sreqEvtList = new  List<SampleRequest__e>();
        set<id> srIdset = new set<id>();
        for(Sample_Request_Line_Item__c srLinItmObj : SampleRequestLineItemList){
            srIdset.add(srLinItmObj.Sample_Request__c);              
        }
        for(id srid : srIdset){
            sreqEvtList.add(new SampleRequest__e(SampleRequestId__c=srid));     
        }
        
        publishPlatformEventsForSampleRequest(sreqEvtList);
    }
    
    
    public static void publishPlatformEventsForSampleRequest(List<SampleRequest__e> sampleRequestEventList){
        List<Database.SaveResult> results = EventBus.publish(sampleRequestEventList);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }       
        }
    }
    
    
    public static void publishPlatformEventOnFeedback(List<Sample_Request_Line_Item__c> SampleRequestLineItemList, Map<Id, Sample_Request_Line_Item__c> oldMap){
        Set<String> feedbackStatus = new Set<String>{'7', '8', '9', '10', '12', '13', '14', '16'};
        
        List<SampleFeedback__e> sreqEvtList = new  List<SampleFeedback__e>();
        set<id> srIdset = new set<id>();
        
        for(Sample_Request_Line_Item__c srLinItmObj : SampleRequestLineItemList){
            if(srLinItmObj.Sampling_Status__c != oldMap.get(srLinItmObj.Id).Sampling_Status__c && feedbackStatus.contains(srLinItmObj.Sampling_Status__c)){
                srIdset.add(srLinItmObj.Sample_Request__c);    
            }              
        }
        for(id srid : srIdset){
            sreqEvtList.add(new SampleFeedback__e(SampleRequestId__c=srid));     
        }
        List<Database.SaveResult> results = EventBus.publish(sreqEvtList);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }       
        }
        
    }
    
       
}