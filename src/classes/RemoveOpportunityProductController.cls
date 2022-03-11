/**
 * @description       : Controller for the RemoveOpportuntityProducts component that deletes selected product from an opportunity
 * @author            : Bharatesh Shetty
 * @group             : 
 * @last modified on  : 09-01-2021
 * @last modified by  : Bharatesh Shetty
**/
public class RemoveOpportunityProductController{
    public RemoveOpportunityProductController() {

    }
    /**
    * @description : To fetch all the Opportunity Line Items for the currect opportunity
    * @author Bharatesh Shetty | 09-01-2021 
    * @param recordId 
    * @return List<OpportunityLineItemWrapper> 
    **/
    @AuraEnabled 
    public static List<OpportunityLineItemWrapper> fetchOpportunityLineItemWrapper(Id recordId ){     
        List<OpportunityLineItemWrapper> lstOpportunityLineItemWrapper = new List<OpportunityLineItemWrapper>();
        // query OpportunityLineItem records related to opportunity and create 'OpportunityLineItemWrapper' class instance for each record.
        for(OpportunityLineItem opLineItem : [Select id,Name,OpportunityId,Opportunity.Name,Product2Id,Product2.Name,Product2.Product_Category__c,Volume__c,UnitPrice 
                                              from OpportunityLineItem 
                                              where OpportunityId =:recordId 
                                              order by Name]){
            // by default checkbox should be false 
            lstOpportunityLineItemWrapper.add(new OpportunityLineItemWrapper(false,opLineItem));
        } 
        // return the 'lstOpportunityLineItemWrapper' list 
        return lstOpportunityLineItemWrapper; 
    }
    @AuraEnabled
    public static String deleteOpportunityLineItems(List<OpportunityLineItemWrapper> listOfSelectedOppLineItemWrapper) { 
        System.debug('listOfSelectedOppLineItemWrapper: '+listOfSelectedOppLineItemWrapper);
        String returnResponse = 'SOME ERROR OCCURRED. PLEASE CONTACT SYSTEM ADMIN.' ;
        Savepoint sp = Database.setSavepoint();
        try{
            if(!listOfSelectedOppLineItemWrapper.isEmpty()){
                List<OpportunityLineItem> listOfOppLineItemsToDelete = new  List<OpportunityLineItem>();
                List<Opportunity_Log__C> listOfOppLogsToInsert = new  List<Opportunity_Log__C>();
                
                /*for(OpportunityLineItem  eachSelectedLineitem : listOfSelectedOpLineItems){
                    listOfOppLineItemsToDelete.add (new OpportunityLineItem(Id = eachSelectedLineitem.Id));
                    //For each of the selected lineitems create an Opportunity Log record while removing OpportunityLineItem.
                    Opportunity_Log__C OppLogsToInsert = new Opportunity_Log__C();
                    OppLogsToInsert.Name = eachSelectedLineitem.Product2.Name;
                    OppLogsToInsert.OpportunityID__c = eachSelectedLineitem.OpportunityId;
                    OppLogsToInsert.Product2Id__c = eachSelectedLineitem.Product2Id;
                    OppLogsToInsert.Action__c = OpportunityLogConstants.ACTION_MANNUALLY_REMOVED;
                    listOfOppLogsToInsert.add (OppLogsToInsert);
                }
                if(!listOfOppLineItemsToDelete.isEmpty() && !listOfOppLogsToInsert.isEmpty()){
                    //Delete OpportunityLineItems
                    delete listOfOppLineItemsToDelete;
                    //Create Opportunity Logs
                    insert listOfOppLogsToInsert;
                }*/
                for(OpportunityLineItemWrapper  eachSelectedLineitemWrapper : listOfSelectedOppLineItemWrapper){
                    listOfOppLineItemsToDelete.add (new OpportunityLineItem(Id = eachSelectedLineitemWrapper.objOpportunityLineItem.Id));
                    //For each of the selected lineitems create an Opportunity Log record while removing OpportunityLineItem.
                    Opportunity_Log__C OppLogsToInsert = new Opportunity_Log__C();
                    OppLogsToInsert.Name = eachSelectedLineitemWrapper.objOpportunityLineItem.Product2.Name;
                    OppLogsToInsert.OpportunityID__c = eachSelectedLineitemWrapper.objOpportunityLineItem.OpportunityId;
                    OppLogsToInsert.Product2Id__c = eachSelectedLineitemWrapper.objOpportunityLineItem.Product2Id;
                    OppLogsToInsert.Action__c = OpportunityLogConstants.ACTION_MANNUALLY_REMOVED;
                    OppLogsToInsert.Reason_for_Removal__c = eachSelectedLineitemWrapper.reasonForRemoval;
                    OppLogsToInsert.Volume__c = eachSelectedLineitemWrapper.objOpportunityLineItem.Volume__c;
                    OppLogsToInsert.UnitPrice__c = eachSelectedLineitemWrapper.objOpportunityLineItem.UnitPrice;
                    listOfOppLogsToInsert.add (OppLogsToInsert);
                }
                if(!listOfOppLineItemsToDelete.isEmpty() && !listOfOppLogsToInsert.isEmpty()){
                    //Delete OpportunityLineItems
                    delete listOfOppLineItemsToDelete;
                    //Create Opportunity Logs
                    insert listOfOppLogsToInsert;
                    returnResponse = 'SUCCESS';
               
                }
            }
            else{
                System.System.debug('Selected list empty');
            }
        }
        catch(Exception e){
            System.debug('Exception Message: '+e.getMessage());
            System.debug('Exception StacktraceSTring: '+e.getStackTraceString());
            returnresponse = e.getMessage();
            //returnresponse ='Divided by zero. Error';
            Database.rollback(sp);
        }
        return returnresponse;
    }
    public class OpportunityLineItemWrapper {
        @AuraEnabled public String reasonForRemoval {get;set;}
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public OpportunityLineItem objOpportunityLineItem{get;set;}
        public OpportunityLineItemWrapper(boolean isChecked, OpportunityLineItem objOpportunityLineItem){
            this.isChecked = isChecked;
            this.objOpportunityLineItem = objOpportunityLineItem;
        }
        public OpportunityLineItemWrapper(){
        }
    }
}