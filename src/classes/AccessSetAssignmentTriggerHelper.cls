public class AccessSetAssignmentTriggerHelper {
    public static void populateUniqueId(List<Access_Set_Assignment__c> listOfAccessSetAssignments){
        for(Access_Set_Assignment__c accessSetAsgnment : listOfAccessSetAssignments){
            accessSetAsgnment.Unique_ID__c = accessSetAsgnment.Access_Set__c + '_' + accessSetAsgnment.User__c;
        }
    }
}