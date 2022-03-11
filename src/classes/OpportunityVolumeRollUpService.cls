public with sharing class OpportunityVolumeRollUpService {
    private static OpportunityVolumeRollUpService handler;

    private OpportunityVolumeRollUpService() {
    }

    public static OpportunityVolumeRollUpService getInstance () {
        return handler == null ? handler = new OpportunityVolumeRollUpService () : handler;
    }

    public void processClosedOpportunities (List<Opportunity> newList, Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Set<Id> opptRecordTypes = new Set<Id> {
            OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID,
            OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID,
            OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID
        };
        Set<String> oppClosedStatus = new Set<String> {
            OpportunityConstants.OPPORTUNITY_STAGE_CLOSING_WON
        };

        List<Opportunity> qualifiedOppList = new List<Opportunity> ();
        for (Opportunity eachOpp : newList) {
            if (opptRecordTypes.contains(eachOpp.RecordTypeId) 
                && String.isNotBlank(eachOpp.Business_Unit__c)
                && String.isNotBlank(eachOpp.StageName)
                && oppClosedStatus.contains(eachOpp.StageName)
                && (
                    (oldMap == null)
                    ||
                    (oldMap != null 
                        && oldMap.containsKey(eachOpp.Id) 
                        && eachOpp.StageName != oldMap.get(eachOpp.Id).StageName
                    )
                )
            ) {
                qualifiedOppList.add (eachOpp);
            }
        }

        if (qualifiedOppList.isEmpty()) {
            return;
        }

        OpportunityVolumeRollUpPromise promiseObj = new OpportunityVolumeRollUpPromise (qualifiedOppList[0]);

        for (Integer index = 1; index < qualifiedOppList.size(); index ++) {
            promiseObj.then(new OpportunityVolumeRollUpPromise (qualifiedOppList[index]));
        }

        System.enqueueJob(promiseObj);
        
    }
}