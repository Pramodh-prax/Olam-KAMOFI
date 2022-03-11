public class PLBSComponentController {

      @AuraEnabled(cacheable=true)
    public static string getTCBId(String OppId){
        String TcbId=[select id from TCB__c where Opportunity__c=:OppId limit 1].Id;
        return TcbId;
    }
}