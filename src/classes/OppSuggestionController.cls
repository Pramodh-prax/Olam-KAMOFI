public class OppSuggestionController {
    @AuraEnabled
    public static List<Opportunity> getSuggestionOpps(String recId) {
        
        Opportunity opp = [SELECT Id, Name, PLBS_Product__c, Plbs_Weight_G__c,
                           (select Id,PM_Type_1st__c,Unit_CTN__c from TCBs__r)
                           FROM Opportunity WHERE Id = :recId];
        System.debug('opp');
        System.debug(opp);
        
        List<Opportunity> suggestedOpps = new List<Opportunity>(); 
        for(Opportunity opps:[SELECT Id, Name, PLBS_Product__c, Account.Name, Plbs_Weight_G__c,(select Id,PM_Type_1st__c,PM_Type_2nd__c,Pallet_Type__c,Unit_CTN__c from TCBs__r)
                                           FROM Opportunity WHERE PLBS_Product__c = :opp.PLBS_Product__c AND Plbs_Weight_G__c = :opp.Plbs_Weight_G__c AND Id <> :recId]){
             for(TCB__c tcbs:opps.TCBs__r){
                 if(tcbs.PM_Type_1st__c==opp.TCBs__r[0].PM_Type_1st__c){
                    suggestedOpps.add(opps);
                     system.debug('Opps '+opps);
                 }
             }
        }
        System.debug('suggestedOpps');
        System.debug(suggestedOpps);
        return suggestedOpps;
    }
    
     @AuraEnabled
    public static boolean copy(String recId, String oppToCopyId) {
        System.debug('Inside Copy');
        Tcb__c oppToCopy = [SELECT Id, Name,
                                 MOQ_Packaging_2nd__c,
                                 X1st_Printing__c,
                           MOQ_Packaging_1st__c,
                           X1st_PM_Pouch_jar__c,
                           Tare_Weight_g_1st__c,
                           Length_mm_1st__c,
                           Width_mm_1st__c,
                           X1st_Structure__c,   
                           Case_Mix_PL__c,
                           Depth_Gusset_Height_mm__c,
                           PM_Type_2nd__c,
                           X2nd_PM_Carton__c,
                           Tare_Weight_g_2nd__c,
                           Length_Depth_mm__c,
                           Width_mm_2nd__c,
                           Structure_2nd__c,
                           Printing_2nd__c,
                           Height_mm__c,
                           Unit_CTN__c,
                           Layer_PL__c,
                           Layer_PL_40HC__c,
                           PL_20FT__c,
                           PL_40FT__c,
                           CTN_20FT__c,
                           CTN_40FT__c,
                           CTN_40FT_HC__c, 
                           CTN_Layer__c 
                           FROM Tcb__c WHERE Opportunity__c = :oppToCopyId];
        
        Tcb__c destinationOpp = [SELECT Id, Name,
                                      MOQ_Packaging_2nd__c,
                                 X1st_Printing__c,
                           MOQ_Packaging_1st__c,
                           X1st_PM_Pouch_jar__c,
                           Tare_Weight_g_1st__c,
                           Length_mm_1st__c,
                           Width_mm_1st__c,
                           X1st_Structure__c,   
                           Case_Mix_PL__c,
                           Depth_Gusset_Height_mm__c,
                           PM_Type_2nd__c,
                           X2nd_PM_Carton__c,
                           Tare_Weight_g_2nd__c,
                           Length_Depth_mm__c,
                           Width_mm_2nd__c,
                           Structure_2nd__c,
                           Printing_2nd__c,
                           Height_mm__c,
                           Unit_CTN__c,
                           Layer_PL__c,
                           Layer_PL_40HC__c,
                           PL_20FT__c,
                           PL_40FT__c,
                           CTN_20FT__c,
                           CTN_40FT__c,
                           CTN_40FT_HC__c, 
                           CTN_Layer__c
                           FROM Tcb__c WHERE Opportunity__c = :recId];
        
        destinationOpp.MOQ_Packaging_2nd__c = oppToCopy.MOQ_Packaging_2nd__c;
        destinationOpp.X1st_Structure__c = oppToCopy.X1st_Structure__c;
        destinationOpp.X1st_Printing__c = oppToCopy.X1st_Printing__c;
        destinationOpp.MOQ_Packaging_1st__c = oppToCopy.MOQ_Packaging_1st__c;
        destinationOpp.X1st_PM_Pouch_jar__c = oppToCopy.X1st_PM_Pouch_jar__c;
        destinationOpp.Tare_Weight_g_1st__c = oppToCopy.Tare_Weight_g_1st__c;
        destinationOpp.Length_mm_1st__c = oppToCopy.Length_mm_1st__c;
        destinationOpp.Width_mm_1st__c = oppToCopy.Width_mm_1st__c;
        destinationOpp.Case_Mix_PL__c = oppToCopy.Case_Mix_PL__c;
        destinationOpp.Depth_Gusset_Height_mm__c = oppToCopy.Depth_Gusset_Height_mm__c;
        destinationOpp.PM_Type_2nd__c = oppToCopy.PM_Type_2nd__c;
        destinationOpp.X2nd_PM_Carton__c = oppToCopy.X2nd_PM_Carton__c;
        destinationOpp.Tare_Weight_g_2nd__c = oppToCopy.Tare_Weight_g_2nd__c;
        destinationOpp.Length_Depth_mm__c = oppToCopy.Length_Depth_mm__c;
        destinationOpp.Width_mm_2nd__c = oppToCopy.Width_mm_2nd__c;
        destinationOpp.Structure_2nd__c = oppToCopy.Structure_2nd__c;
        destinationOpp.Printing_2nd__c = oppToCopy.Printing_2nd__c;
        destinationOpp.Height_mm__c = oppToCopy.Height_mm__c;
        destinationOpp.Unit_CTN__c = oppToCopy.Unit_CTN__c;
        destinationOpp.Layer_PL__c = oppToCopy.Layer_PL__c;
        destinationOpp.Layer_PL_40HC__c = oppToCopy.Layer_PL_40HC__c;
        destinationOpp.PL_20FT__c = oppToCopy.PL_20FT__c; 
        destinationOpp.PL_40FT__c = oppToCopy.PL_40FT__c;
        destinationOpp.CTN_20FT__c = oppToCopy.CTN_20FT__c;
        destinationOpp.CTN_40FT__c = oppToCopy.CTN_40FT__c;
        destinationOpp.CTN_Layer__c = oppToCopy.CTN_Layer__c;
        destinationOpp.CTN_40FT_HC__c = oppToCopy.CTN_40FT_HC__c;
        
        Database.SaveResult result = Database.update(destinationOpp);
        return result.isSuccess();
    }

}