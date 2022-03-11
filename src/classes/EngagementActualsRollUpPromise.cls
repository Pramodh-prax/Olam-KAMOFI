public with sharing class EngagementActualsRollUpPromise extends Promise {
    Id interactionId;
    Set<String> interactionType;
  
    public EngagementActualsRollUpPromise(Id interactionId, Set<String> interactionType){
      this.interactionId = interactionId;
      this.interactionType = interactionType;
    }
  
    public EngagementActualsRollUpPromise(Id interactionId, Set<String> interactionType, Promise[] promises){
      this.interactionId = interactionId;
      this.interactionType = interactionType;
      this.promises = promises;
    }
  
    public override void execute(){
        Savepoint sp = Database.setSavePoint ();
        try {
        	List<Interactions__c> interactions = InteractionSelector.getInteractionsByIds (new Set<Id> {interactionId});

            if (interactions.isEmpty ()) {
                System.debug('Async Work Completed! due to no interactions' );
                return;
            }
    
            Interactions__c eachInteraction = interactions[0];
    
            /**
             * Dev Note: Assumption - that accout plan is created yearly, Since engagement plan is not tagged 
             * to account plan, we are considering here the start and end dates.
            */
            List <Engagement_Plan__c> engagementPlans = EngagementPlanSelector.getEngagementPlanByInteractionDetail (eachInteraction, interactionType);
    
            if (engagementPlans.isEmpty ()) {
                Engagement_Plan__c engPlan = new Engagement_Plan__c ();
                engPlan.Account__c = eachInteraction.Account__c;
                engPlan.Business_Unit__c = eachInteraction.Business_Unit__c;
                engPlan.Start_date__c = Date.newInstance(System.today().year (), 1, 1);
                engPlan.End_Date__c = Date.newInstance(System.today().year (), 12, 31);
                engPlan.Year__c = String.valueOf(System.today().year());
                engPlan.Name = eachInteraction.Business_Unit__c + '-' + System.today().year ();
    
                insert engPlan;
                if (engagementPlans == null) {engagementPlans = new List<Engagement_Plan__c> ();}
                engagementPlans.add (engPlan);
            }
            Engagement_Plan__c engPlan = engagementPlans[0];
            Map<String, Engagement_Plan_Line__c> engagementLines =  getEngagementPlanLines (engPlan);
            List <Engagement_Plan_Line__c> engagementPlansUpdateList = new List<Engagement_Plan_Line__c> ();
            List <Engagement_Plan_Line__c> engagementPlansInsertList = new List<Engagement_Plan_Line__c> ();
            
            for (AggregateResult aggRes : TaskSelector.getTaksByInteractionAndDate (eachInteraction.Id, interactionType, 
                                                                        engPlan.Start_date__c, engPlan.End_Date__c)) {
                String key = (String)aggRes.get ('Interaction_Type__c');
                if (engagementLines.containsKey (key)) {
                    Engagement_Plan_Line__c line = engagementLines.get (key);
                    line.Actuals__c = (Decimal) aggRes.get ('totalInteractions');
                    line.Last_Engagement_Date__c = System.today();
                    engagementPlansUpdateList.add (line);
                } else {
                    Engagement_Plan_Line__c line = new Engagement_Plan_Line__c ();
                    line.Engagement_Plan__c = engPlan.Id;
                    line.Type_of_Engagement__c = key;
                    line.Actuals__c = (Decimal) aggRes.get ('totalInteractions');
                    line.Last_Engagement_Date__c = System.today();
                    engagementPlansInsertList.add (line);
                }                                                                                   
            }
            
    
            if (engagementPlansUpdateList.isEmpty () && engagementPlansInsertList.isEmpty ()) {
                System.debug('Async Work Completed! due to no engagementPlansUpdateList && engagementPlansInsertList' );
                return;
            }
    
            if (engagementPlansUpdateList.size() > 0) {
                Database.SaveResult [] results = Database.update(engagementPlansUpdateList, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        System.debug('Update failed :' + result.getId() + ' Error :' + result.getErrors().toString());
                    }
                }
            }
            if (engagementPlansInsertList.size() > 0) {
                Database.SaveResult [] results = Database.insert(engagementPlansInsertList, false);
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        System.debug('Insert failed :' + result.getId() + ' Error :' + result.getErrors().toString());
                    }
                }
            }
                
        } catch (Exception e) {
            Database.rollback(sp);
            Error_Event_Capture__e errorCaptureEvent = new Error_Event_Capture__e (
                Apex_Class__c ='EngagementActualsRollUpPromise',
                Error_Details__c = e.getMessage (),
                Record_Detail__c = interactionId
            );
            Database.SaveResult result = Eventbus.publish(errorCaptureEvent);
            if (result.isSuccess()) {
                System.debug('Event published successfully !!');
            } else {
                System.debug('Event publish failed :' + e.getMessage () );
            }
        }

        System.debug('Async Work Completed!');
    }

    public Map<String, Engagement_Plan_Line__c> getEngagementPlanLines (Engagement_Plan__c eachPlan) {
        Map<String, Engagement_Plan_Line__c> returnMap = new Map<String, Engagement_Plan_Line__c> ();
        for (Engagement_Plan_Line__c eachLine : eachPlan.Engagement_Plan_Lines__r) {
            returnMap.put (eachLine.Type_of_Engagement__c, eachLine);
        }
        return returnMap;
    }
}