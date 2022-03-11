public with sharing class TaskTriggerHandler {
    private static TaskTriggerHandler handler;
    private TaskTriggerHandler() {
    }

    public static TaskTriggerHandler getInstance () {
        return handler == null ? handler = new TaskTriggerHandler () : handler;
    }

    public void handleBeforeInsert (List<Task> newList) {
        updateCompletedDate (newList, null, null);
    }

    public void handleBeforeUpdate (List<Task> newList, Map<Id, Task> newMap,  Map<Id, Task> oldMap) {
        updateCompletedDate (newList, newMap, oldMap);
    }

    public void handleOnAfterInsert (List<Task> newList, Map<Id, Task> newMap ) {
        identifyInteractionTasks (newList, newMap, null);
    }
    public void handleOnAfterUpdate (List<Task> newList, Map<Id, Task> newMap,  Map<Id, Task> oldMap) {
        identifyInteractionTasks (newList, newMap, oldMap);
    }

    private void updateCompletedDate (List<Task> newList, Map<Id, Task> newMap,  Map<Id, Task> oldMap) {
        for (Task eachTask : newList) {
            if ( String.isNotBlank(eachTask.Status) 
                && eachTask.Status == TaskConstants.STATUS_COMPLETED
                && (
                    (oldMap == null)
                    ||
                    (oldMap != null 
                        && oldMap.containsKey(eachTask.Id) 
                        && eachTask.Status != oldMap.get(eachTask.Id).Status
                    )
                )) {
                eachTask.Completed_Date__c = System.today ();
            }
        }
    }

    private void identifyInteractionTasks (List<Task> newList, Map<Id, Task> newMap,  Map<Id, Task> oldMap) {
        Map<Id, Set<String>> taskInteractionTypeMap = new Map<Id, Set<String>> ();

        for (Task eachTask : newList) {
            if (String.isNotBlank (eachTask.WhatId)
                && eachTask.WhatId.getSObjectType().getDescribe().getSobjectType() == Interactions__c.SobjectType
                && String.isNotBlank(eachTask.Interaction_Type__c)
                //&& eachTask.Completed_Date__c != null
                && String.isNotBlank(eachTask.Status) 
                && eachTask.Status == TaskConstants.STATUS_COMPLETED
                && (
                    (oldMap == null)
                    ||
                    (oldMap != null 
                        && oldMap.containsKey(eachTask.Id) 
                        && eachTask.Status != oldMap.get(eachTask.Id).Status
                    )
                )) {
                    if (taskInteractionTypeMap.containsKey(eachTask.WhatId)) {
                        taskInteractionTypeMap.get(eachTask.WhatId).add (eachTask.Interaction_Type__c);
                    } else {
                        taskInteractionTypeMap.put (eachTask.WhatId, new Set<String>{eachTask.Interaction_Type__c});
                    }
            }
        }
        if (taskInteractionTypeMap.isEmpty()) {
            return;
        } 

        List<Id> interactionIdsList = new List<Id> (taskInteractionTypeMap.keySet());
        EngagementActualsRollUpPromise promiseObj = new EngagementActualsRollUpPromise (interactionIdsList[0], 
                                                                                        taskInteractionTypeMap.get (interactionIdsList[0]));

        for (Integer index = 1; index < interactionIdsList.size(); index ++) {
            promiseObj.then(new EngagementActualsRollUpPromise (interactionIdsList[index], taskInteractionTypeMap.get (interactionIdsList[index])));
        }

        System.enqueueJob(promiseObj);
    }
}