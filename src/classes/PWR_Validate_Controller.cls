public class PWR_Validate_Controller {
    @AuraEnabled
    public static List<string> validate(String recId) {
        List<string> missingFields = new List<string>();
        TCB__c tcb = [SELECT Id, Name,
                           PM_Type_1st__c,
                           X1st_PM_Pouch_jar__c,
                           Tare_Weight_g_1st__c,
                           Length_mm_1st__c,
                           Width_mm_1st__c,
                           Depth_Gusset_Height_mm__c,
                           PM_Type_2nd__c,
                           X2nd_PM_Carton__c,
                           Tare_Weight_g_2nd__c,
                           Length_Depth_mm__c,
                           Width_mm_2nd__c,
                           Height_mm__c,
                           Unit_CTN__c,
                           Layer_PL__c,
                           Layer_PL_40HC__c,
                           PL_20FT__c,
                           PL_40FT__c,
                           CTN_20FT__c,
                           CTN_40FT__c,
                           CTN_40FT_HC__c, 
                           CTN_Layer__c,
                           MOQ_Packaging_1st__c,
                           MOQ_Packaging_2nd__c,
                           Pallet_Type__c 
                           
                           FROM TCB__c WHERE Opportunity__c = :recId];
        
        if (tcb.PM_Type_1st__c == null) {
            missingFields.add('PM Type (1st)');
        }
        if (tcb.X1st_PM_Pouch_jar__c == null) {
            missingFields.add('PM (Pouch/jar) VND/EA (1st)');
        }
        if (tcb.Tare_Weight_g_1st__c == null) {
            missingFields.add('Tare Weight (g) (1st)');
        }
        if (tcb.Length_mm_1st__c == null) {
            missingFields.add('Length (mm) (1st)');
        }
        if (tcb.Width_mm_1st__c == null) {
            missingFields.add('Width (mm) (1st)');
        }
        if (tcb.Depth_Gusset_Height_mm__c == null) {
            missingFields.add('Depth/ Gusset/ Height (mm)');
        }
        if (tcb.PM_Type_2nd__c == null) {
            missingFields.add('PM Type (2nd)');
        }
        if (tcb.X2nd_PM_Carton__c == null) {
            missingFields.add('PM (Carton) - VND/EA (2nd)');
        }
        if (tcb.Tare_Weight_g_2nd__c == null) {
            missingFields.add('Tare Weight (g) (2nd)');
        }
        if (tcb.Length_Depth_mm__c == null) {
            missingFields.add('Length/ Depth (mm)');
        }
        if (tcb.Width_mm_2nd__c == null) {
            missingFields.add('Width (mm) (2nd)');
        }
        if (tcb.Height_mm__c == null) {
            missingFields.add('Height (mm)');
        }
        if (tcb.Unit_CTN__c == null) {
            missingFields.add('Unit/ CTN');
        }
        
        if (tcb.CTN_Layer__c == null) {
            missingFields.add('CTN/ Layer');    
        }
        if (tcb.Layer_PL__c == null) {
            missingFields.add('Layer/ PL');   
        }
        if (tcb.Layer_PL_40HC__c == null) {
            missingFields.add('Layer/ PL 40HC');    
        }
        if (tcb.PL_20FT__c == null) {
            missingFields.add('PL/ 20FT');    
        }
        if (tcb.PL_40FT__c == null) {
            missingFields.add('PL/ 40FT');   
        }
        if (tcb.CTN_20FT__c == null) {
            missingFields.add('CTN/ 20FT');   
        }
        if (tcb.CTN_40FT__c == null) {
            missingFields.add('CTN/ 40FT');  
        }
        if (tcb.CTN_40FT_HC__c == null) {
            missingFields.add('CTN/ 40FT HC');
        }
         if (tcb.MOQ_Packaging_1st__c == null) {
            missingFields.add('MOQ Packaging (1st)');
        }
         if (tcb.MOQ_Packaging_2nd__c == null) {
            missingFields.add('MOQ Packaging (2nd)');
        }
         if (tcb.Pallet_Type__c == null) {
            missingFields.add('Pallet Type');
        }
        return missingFields;
    }
}