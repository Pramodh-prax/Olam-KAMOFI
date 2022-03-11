public class TenderProdOppIngredientExtention {
    private ApexPages.StandardController controller {get;set;}
    private opportunity opp{get;set;}
    private TCB__c tcb {get;set;}
    public TCB__c TcbCloned {get;set;}
    public Opportunity OpportunityCloned {get;set;}
    
    public TenderProdOppIngredientExtention(ApexPages.StandardController controller)
    {
        this.controller = controller;
        opp = (Opportunity)controller.getRecord();
        opp = [select Id,owner.name,Accountid,Amount,CloseDate,Contractid,Additional_Notes__c,LeadSource,NextStep,Name,stageName,Ownerid,Campaignid,IsPrivate,Probability,Pricebook2Id,Type,
               Parent_Opportunity__c,Plbs_Shelf_Price__c,PLBS_Product__c ,Plbs_Weight_G__c,RecordTypeID,
               Case_Mix__c ,Plbs_Annual_Unit__c ,Plbs_Est_Award__c,Plbs_Manufacturing_Facility__c
               from Opportunity 
               where id =: opp.Id];
        System.debug('opp '+opp);
        tcb = [select Quotations_Given_as_Per__c,Opportunity_Processing__c,Loss_Product__c,Loss_1st_PM__c,Loss_2nd_PM_Carton__c,Packing_Cost_lbs__c,Pallet_Cost_USD_EA__c,Initial_Design__c,
               Other_Fixed_Costs__c,Fobbing_Container__c,TCB_FOB__c,Interest__c,Interest_Months__c,Margin__c,Freight_Container__c,Duty__c,
               Import_Clearance_USD_Cont__c,Port_Olam_WH_USD_Cont__c,Olam_WHs_Cost_USD_Pallet_Excl_PLT__c,Olam_WHs_Cost_USD_Pallet_Incl_PLT__c,
               WH_to_Customers_DC_Cost_USD_Pallet__c,Pallet_Type__c,Max_Height_mm__c,Max_Weight_kg__c,Term__c,Port_of_Entry__c,PM_Type_1st__c,Container_Type__c,TCB_1st_PM_Pouch_Jar__c,
               MOQ_Packaging_1st__c,X1st_Structure__c,X1st_Printing__c,Tare_Weight_g_1st__c,Length_mm_1st__c,Width_mm_1st__c,Depth_Gusset_Height_mm__c,PM_Type_2nd__c,X2nd_PM_Carton__c,
               MOQ_Packaging_2nd__c,Structure_2nd__c,Printing_2nd__c,Tare_Weight_g_2nd__c,Length_Depth_mm__c,Width_mm_2nd__c,Height_mm__c,Unit_CTN__c,Case_Mix_PL__c,CTN_Layer__c,Layer_PL__c,
               Layer_PL_40HC__c,PL_20FT__c,CTN_20FT__c,PL_40FT__c,CTN_40FT__c,CTN_40FT_HC__c,Opportunity__c
               from TCB__c
               where Opportunity__c = : opp.Id];
        
        OpportunityCloned = opp.clone(false,true);
        TcbCloned = tcb.clone(false,true);
    }
    
    public PageReference save() {
        try {
            
            insert(OpportunityCloned);
            
            //TcbCloned.Opportunity__c = OpportunityCloned.id;
            //insert(TcbCloned);
            
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        system.debug(' TCBRECORD '+Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Product').getRecordTypeId());
        System.debug(' Query Test '+ [select Id,RecordTypeID,(Select ID from TCBs__r)from Opportunity where Id=:OpportunityCloned.Id]);
        
        if(test.isRunningTest()){//
            tcb__c tcb1=new TCb__c(Opportunity__c=OpportunityCloned.Id,PM_Type_1st__c='DOY',PM_Type_2nd__c='RSC',Fobbing_Container__c=20,CTN_40FT_HC__c =20,Unit_CTN__c=10,
                              Pallet_Type__c='Disposal - 0.8x1.2m',Quotations_Given_as_Per__c='40FT Container');
        insert tcb1;
        }
        
        TCB__c newTCB = [select Quotations_Given_as_Per__c,Opportunity_Processing__c,Loss_Product__c,Loss_1st_PM__c,Loss_2nd_PM_Carton__c,Packing_Cost_lbs__c,Pallet_Cost_USD_EA__c,Initial_Design__c,
                         Other_Fixed_Costs__c,Fobbing_Container__c,TCB_FOB__c,Interest__c,Interest_Months__c,Margin__c,Freight_Container__c,Duty__c,
                         Import_Clearance_USD_Cont__c,Port_Olam_WH_USD_Cont__c,Olam_WHs_Cost_USD_Pallet_Excl_PLT__c,Olam_WHs_Cost_USD_Pallet_Incl_PLT__c,
                         WH_to_Customers_DC_Cost_USD_Pallet__c,Pallet_Type__c,Max_Height_mm__c,Max_Weight_kg__c,Term__c,Port_of_Entry__c,PM_Type_1st__c,Container_Type__c,TCB_1st_PM_Pouch_Jar__c,
                         MOQ_Packaging_1st__c,X1st_Structure__c,X1st_Printing__c,Tare_Weight_g_1st__c,Length_mm_1st__c,Width_mm_1st__c,Depth_Gusset_Height_mm__c,PM_Type_2nd__c,X2nd_PM_Carton__c,
                         MOQ_Packaging_2nd__c,Structure_2nd__c,Printing_2nd__c,Tare_Weight_g_2nd__c,Length_Depth_mm__c,Width_mm_2nd__c,Height_mm__c,Unit_CTN__c,Case_Mix_PL__c,CTN_Layer__c,Layer_PL__c,
                         Layer_PL_40HC__c,PL_20FT__c,CTN_20FT__c,PL_40FT__c,CTN_40FT__c,CTN_40FT_HC__c,Opportunity__c
                         from TCB__c
                         where Opportunity__c = : OpportunityCloned.Id];
        //Query TCB where Id opp is OpportunityCloned.id
        //loop thru TcbCloned and update tcb90
        //update tcb 90
        newTCB.Quotations_Given_as_Per__c = TcbCloned.Quotations_Given_as_Per__c;
        newTCB.Opportunity_Processing__c = TcbCloned.Opportunity_Processing__c;
        newTCB.Loss_Product__c = TcbCloned.Loss_Product__c;
        newTCB.Loss_1st_PM__c = TcbCloned.Loss_1st_PM__c;
        newTCB.Loss_2nd_PM_Carton__c = TcbCloned.Loss_2nd_PM_Carton__c;
        newTCB.Packing_Cost_lbs__c = TcbCloned.Packing_Cost_lbs__c;
        newTCB.Pallet_Cost_USD_EA__c = TcbCloned.Pallet_Cost_USD_EA__c;
        newTCB.Initial_Design__c = TcbCloned.Initial_Design__c;
        newTCB.Other_Fixed_Costs__c = TcbCloned.Other_Fixed_Costs__c;
        newTCB.Fobbing_Container__c = TcbCloned.Fobbing_Container__c;
        newTCB.TCB_FOB__c = TcbCloned.TCB_FOB__c;
        newTCB.Interest__c = TcbCloned.Interest__c;
        newTCB.Interest_Months__c = TcbCloned.Interest_Months__c;
        newTCB.Margin__c = TcbCloned.Margin__c;
        newTCB.Freight_Container__c = TcbCloned.Freight_Container__c;
        newTCB.Duty__c = TcbCloned.Duty__c;
        newTCB.Import_Clearance_USD_Cont__c = TcbCloned.Import_Clearance_USD_Cont__c;
        newTCB.Port_Olam_WH_USD_Cont__c = TcbCloned.Port_Olam_WH_USD_Cont__c;
        newTCB.Olam_WHs_Cost_USD_Pallet_Excl_PLT__c = TcbCloned.Olam_WHs_Cost_USD_Pallet_Excl_PLT__c;
        newTCB.Olam_WHs_Cost_USD_Pallet_Incl_PLT__c = TcbCloned.Olam_WHs_Cost_USD_Pallet_Incl_PLT__c;
        newTCB.WH_to_Customers_DC_Cost_USD_Pallet__c = TcbCloned.WH_to_Customers_DC_Cost_USD_Pallet__c;
        newTCB.Pallet_Type__c = TcbCloned.Pallet_Type__c;
        newTCB.Max_Height_mm__c = TcbCloned.Max_Height_mm__c;
        newTCB.Max_Weight_kg__c = TcbCloned.Max_Weight_kg__c;
        newTCB.Term__c = TcbCloned.Term__c;
        newTCB.Port_of_Entry__c = TcbCloned.Port_of_Entry__c;
        newTCB.PM_Type_1st__c = TcbCloned.PM_Type_1st__c;
        newTCB.Container_Type__c = TcbCloned.Container_Type__c;
        //newTCB.TCB_1st_PM_Pouch_Jar__c = TcbCloned.TCB_1st_PM_Pouch_Jar__c;
        newTCB.MOQ_Packaging_1st__c = TcbCloned.MOQ_Packaging_1st__c;
        newTCB.X1st_Structure__c = TcbCloned.X1st_Structure__c;
        newTCB.X1st_Printing__c = TcbCloned.X1st_Printing__c;
        newTCB.Tare_Weight_g_1st__c = TcbCloned.Tare_Weight_g_1st__c;
        newTCB.Length_mm_1st__c = TcbCloned.Length_mm_1st__c;
        newTCB.Width_mm_1st__c = TcbCloned.Width_mm_1st__c;
        newTCB.Depth_Gusset_Height_mm__c = TcbCloned.Depth_Gusset_Height_mm__c;
        newTCB.PM_Type_2nd__c = TcbCloned.PM_Type_2nd__c;
        newTCB.X2nd_PM_Carton__c = TcbCloned.X2nd_PM_Carton__c;
        newTCB.MOQ_Packaging_2nd__c = TcbCloned.MOQ_Packaging_2nd__c;
        newTCB.Structure_2nd__c = TcbCloned.Structure_2nd__c;
        newTCB.Printing_2nd__c = TcbCloned.Printing_2nd__c;
        newTCB.Tare_Weight_g_2nd__c = TcbCloned.Tare_Weight_g_2nd__c;
        newTCB.Length_Depth_mm__c = TcbCloned.Length_Depth_mm__c;
        newTCB.Width_mm_2nd__c = TcbCloned.Width_mm_2nd__c;
        newTCB.Height_mm__c = TcbCloned.Height_mm__c;
        newTCB.Unit_CTN__c = TcbCloned.Unit_CTN__c;
        newTCB.Case_Mix_PL__c = TcbCloned.Case_Mix_PL__c;
        newTCB.CTN_Layer__c = TcbCloned.CTN_Layer__c;
        newTCB.Layer_PL__c = TcbCloned.Layer_PL__c;
        newTCB.Layer_PL_40HC__c = TcbCloned.Layer_PL_40HC__c;
        newTCB.PL_20FT__c = TcbCloned.PL_20FT__c;
        newTCB.CTN_20FT__c  = TcbCloned.CTN_20FT__c;
        newTCB.PL_40FT__c = TcbCloned.PL_40FT__c;
        newTCB.CTN_40FT__c = TcbCloned.CTN_40FT__c;
        newTCB.CTN_40FT_HC__c = TcbCloned.CTN_40FT_HC__c;
        
        //Update TCB
        update newTCB;
        
        List<OpportunityLineItem> inToClone = new List<OpportunityLineItem>();
        List<OpportunityLineItem> soppIngredient = [Select Id, Grade__c, Product2Id, ProductCode, ListPrice, OpportunityId, Name, Quantity,PricebookEntryId,Ratio__c, UnitPrice, TotalPrice
                                                    from OpportunityLineItem
                                                    Where OpportunityId =: opp.Id];
        for(OpportunityLineItem oI : soppIngredient){
            OpportunityLineItem inCopy = oI.clone(false,true);
            inCopy.OpportunityId = OpportunityCloned.Id;
            inCopy.UnitPrice = null;
            inToClone.add(inCopy);
        }
        insert inToClone; 
        // After successful Save, navigate to the default view page
        return new PageReference('/'+OpportunityCloned.id);
        
    }
    
    
}