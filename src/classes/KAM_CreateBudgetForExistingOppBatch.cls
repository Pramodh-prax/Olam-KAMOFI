public class KAM_CreateBudgetForExistingOppBatch implements Database.Batchable<sObject>{

    public String query;
    public String subQuery;
    public Integer year;
 
    Set<Id> opptRecordTypes = new Set<Id> {
        OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID,
        OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID,
        OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID
    };

    Set<String> oppClosedStatus = new Set<String> {
        OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON
    };        

    public KAM_CreateBudgetForExistingOppBatch () {
        String tempQuery = 'SELECT Id, Name FROM Account';
        String tempSubQuery = 'SELECT Id, AccountId, Business_Unit__c, CloseDate, OwnerId FROM Opportunity WHERE CALENDAR_YEAR(CloseDate) =: year  AND StageName in:oppClosedStatus  AND RecordTypeId in:opptRecordTypes AND AccountId in: accountIds';
        init (
            tempQuery,
            tempSubQuery,
            System.today().year()
        );
    }

    public KAM_CreateBudgetForExistingOppBatch (Integer year){
        String tempQuery = 'SELECT Id, Name FROM Account';
        String tempSubQuery = 'SELECT Id, AccountId, Business_Unit__c, CloseDate, OwnerId FROM Opportunity WHERE CALENDAR_YEAR(CloseDate) =: year  AND StageName in:oppClosedStatus  AND RecordTypeId in:opptRecordTypes AND AccountId in:accountIds ';
        init (
            tempQuery,
            tempSubQuery,
            year
        );
    }
    public KAM_CreateBudgetForExistingOppBatch (String query, String subQuery, Integer year){
        init (query, subQuery, year);
    }

    private void init (String query, String subQuery, Integer year) {
        this.query = query;
        this.subQuery = subQuery;
        this.year = year;
    }
 
    public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext BC, List<Account> scope){
        try {
            Set<Id> accountIds = new Set<Id> ();
            for (Account eachAcc : scope) {
                accountIds.add (eachAcc.Id);
            }
            Map<String, Opportunity> buOpportunityMap = new Map<String, Opportunity> ();
            for (Opportunity eachOpp : Database.query(subQuery)) {
                if (!buOpportunityMap.containsKey(eachOpp.Business_Unit__c)) {
                    buOpportunityMap.put(eachOpp.Business_Unit__c, eachOpp);
                }
            }
    
            if (!buOpportunityMap.isEmpty()) {
                List<Opportunity>  qualifiedOppList = buOpportunityMap.values();
                OpportunityVolumeRollUpPromise promiseObj = new OpportunityVolumeRollUpPromise (qualifiedOppList [0]);
    
                for (Integer index = 1; index < qualifiedOppList.size(); index ++) {
                    promiseObj.then(new OpportunityVolumeRollUpPromise (qualifiedOppList[index]));
                }
    
                System.enqueueJob(promiseObj);
            }
        } catch (Exception e) {
            Error_Event_Capture__e errorCaptureEvent = new Error_Event_Capture__e (
                Apex_Class__c ='KAM_CreateBudgetForExistingOppBatch',
                Error_Details__c = e.getMessage ()
            );
            Database.SaveResult result = Eventbus.publish(errorCaptureEvent);
            if (result.isSuccess()) {
                System.debug('Event published successfully !!');
            } else {
                System.debug('Event publish failed :' + e.getMessage () );
            }
        }
    }
 
    public void finish(Database.BatchableContext BC){
    }
 }