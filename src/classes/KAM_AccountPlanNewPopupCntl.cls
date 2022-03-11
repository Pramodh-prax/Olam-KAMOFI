public class KAM_AccountPlanNewPopupCntl {
    @testVisible
    private static final String TYPE_GROUP = 'Group';
    //Method to Fetch picklist values
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        List<String> optionlist = new List<String>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();       
        if(nullRequired == true){
            optionlist.add('--None--');
        }       
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }
    
    //Method to create new Account plan   
    @AuraEnabled
    public static Account_Plans__c saveAccountPlan(Date StartDate,Date EndDate,String data){
        Map<String, Object> mapOfObject= (Map<String, Object>) JSON.deserializeUntyped(data);
        User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
        String BU,type,year,accId;
        
        //Commented  by Bharatesh Shetty as part of OFI
        /*if(u.BU_Identifier__c!='NONE'){
            BU = u.BU_Identifier__c;  }
        else if(u.BU_Identifier__c=='NONE'){
            BU = String.valueof(mapOfObject.get('BusinessUnit'));
        }*/
        
        // Added  by Bharatesh Shetty as part of OFI
        BU = String.valueof(mapOfObject.get('BusinessUnit'));
        
        type=String.valueof(mapOfObject.get('PlanType'));
        year=String.valueof(mapOfObject.get('year'));
        accId  =String.valueof(mapOfObject.get('AccountId'));
        List<Account_Plans__c> acc_plans=[Select id,BU_Identifier__c,Type__c,Year__c from Account_Plans__c where BU_Identifier__c=:BU AND Type__c=:type AND Year__c=:year AND Account__c=:accId];
        System.debug('Account Plan'+acc_plans);
        if(acc_plans!=null && !acc_plans.isEmpty())
        {
            NullPointerException e = new NullPointerException();
            e.setMessage(Label.KAM_AccountPlan_Create_Errror_Message);
            throw e;
        }
        else
        {
            Account_Plans__c app = new Account_Plans__c();
            app.Name = String.valueof(mapOfObject.get('name'));
            app.Description__c = String.valueof(mapOfObject.get('description'));
            app.Account__c =String.valueof(mapOfObject.get('AccountId'));
            app.StartDate__c = StartDate;
            app.EndDate__c = EndDate;
            app.Year__c = String.valueof(mapOfObject.get('year'));
            app.Type__c = String.valueof(mapOfObject.get('PlanType'));
            
            try {
                if (app.Type__c != null && app.Type__c == TYPE_GROUP) {
                    Account accObj  = [SELECT Id, Customer_Group__c FROM Account WHERE Id =: app.Account__c LIMIT 1];
                    if (String.isBlank(accObj.Customer_Group__c)) {
                        NullPointerException e = new NullPointerException();
                        e.setMessage(Label.KAM_Customer_Group_Empty_Message);
                        throw e;
                    }
                }
                /*if(u.BU_Identifier__c!='NONE'){
                    app.BU_Identifier__c = u.BU_Identifier__c;  
                }else if(u.BU_Identifier__c=='NONE'){
                    app.BU_Identifier__c = String.valueof(mapOfObject.get('BusinessUnit'));
                }*/
                
                app.BU_Identifier__c = BU;  
                insert app;
            }catch (DmlException e) {
                throw new AuraHandledException(e.getDmlMessage(0));
            }
            catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            
            return app;
        }
    } 
    
     @AuraEnabled
    public static Teams__c getcurrentUserAccountTeam(Id accountId){
        Teams__c currentUserAccountTeam = new Teams__c();
        List<Teams__c> listOfTeams = new List<Teams__c>();
        listOfTeams = [select Id,Business_Unit__c,User__c,Account__c from Teams__c where User__c =: userinfo.getuserId() and Account__c =: accountId limit 1];
        if(!listOfTeams.isEmpty()){
            currentUserAccountTeam = listOfTeams[0];
        }
        return currentUserAccountTeam;
    }
    
}