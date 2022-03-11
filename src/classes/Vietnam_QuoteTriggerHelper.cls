public class Vietnam_QuoteTriggerHelper {
	
    public static void BeforeInsert(list<Quote> listOfQuote){
        
        set<Id> setOfopp = new set<Id>();
        
        map<string, TCB__c> mapOfOppIdToTCB = new map<string, TCB__c>();
        for(Quote qu: listOfQuote){
            setOfopp.add(qu.OpportunityId);
        }
        
        list<TCB__c> listOfTcb = [select Id,Opportunity__c,Quotations_Given_as_Per__c,Clearance_Pack_FL__c,Conversion_Cost_USD_lbs__c,DDP_TCB_FL__c,DDP_TCB_PL__c,
                                  Dest_Clearance_Pack_PL__c,Dest_Haulage_Port_WH_Pack_FL__c,Dest_Haulage_Port_WH_Pack_PL__c,Duty_Pack_FL__c,
                                  Duty_Pack_PL__c,Duty__c,TCB_FOB__c,Fixed_Costs_TCB__c,Fobbing_Container__c,Freight_Container__c,Freight_Pack_FL__c,
                                  Freight_Pack_PL__c,IMU_DDP_Floor_Loading__c,IMU_DDP_Pallet_Loading__c,IMU_FOB__c,Import_Clearance_USD_Cont__c,
                                  Initial_Design_TCB__c,Initial_Design__c,Interest_Months__c,Interest_TCB__c,Interest__c,Loss_1st_PM__c,Loss_2nd_PM_Carton__c,
                                  Loss_Product__c,Margin_TCB__c,Margin__c,Markup_W_O_Margin_USD_lbs__c,Markup_with_Margin_USD_lbs__c,Olam_WHs_Cost_USD_Pallet_Excl_PLT__c,
                                  Olam_WHs_Cost_USD_Pallet_Incl_PLT__c, Other_Fixed_Costs__c,Packing_TCB__c,Pallet_Cost_USD_EA__c,Pallet_TCB__c,
                                  Port_Olam_WH_USD_Cont__c,Opportunity_Processing__c,Product_TCB__c,Total_Ingredient_Price__c,Trucking_Pack_FL__c,
                                  Trucking_to_Final_Dest_Pack_PL__c,WH_Cost_Dest_Pack_FL__c ,WH_to_Customers_DC_Cost_USD_Pallet__c ,TCB_1st_PM_Pouch_Jar__c ,
                                  TCB_2nd_PM_Outer__c,Opportunity__r.Total_Ingredient_Price_No_Processing__c,CFR_LC_Pack_Floor_Load__c,CFR_LC_Pack_Pallet__c,
                                  CFR_USD_Pack_Floor_Load__c,CFR_USD_lbs_Pallet__c,CFR_USD_Pack_Pallet__c,DDP_LC_Pack_Floor_Load__c,DDP_LC_Pack_Pallet__c,
                                  DDP_USD_Pack_Floor_Load__c,DDP_USD_Pack_Pallet__c,DDP_USD_lbs_Floor_Load__c,DDP_USD_lbs_Pallet__c,FOB_LC_Pack_Floor_Load__c,
                                  FOB_LC_Pack_Pallet__c,FOB_USD_Pack_Floor_Load__c,FOB_USD_Pack_Pallet__c,FOB_USD_lbs_Floor_Load__c,FOB_USD_lbs_Pallet__c,
                                  FOB_to_DDP_USD_Pack_Floor_Load__c,FOB_to_DDP_USD_Pack_Pallet__c,FOB_to_DDP_USD_lbs_Floor_Load__c,FOB_to_DDP_USD_lbs_Pallet__c,
                                  MOQ_Packaging_1st__c,	PM_Type_1st__c,Term__c,Packing_Cost_lbs__c,WH_Cost_Dest_Pack_PL__c
                                  from TCB__c where Opportunity__c in :setOfopp];
        
        if(!listOfTcb.isEmpty()){
            for(TCB__c tcb : listOfTcb){
                mapOfOppIdToTCB.put(tcb.Opportunity__c, tcb);
            }
            
            for(Quote qu: listOfQuote){
                if(mapOfOppIdToTCB.containsKey(qu.OpportunityId)){
                    TCB__c tcb= mapOfOppIdToTCB.get(qu.OpportunityId);
                    qu.Quotations_Given_as_Per__c=tcb.Quotations_Given_as_Per__c;
                    qu.Clearance_Pack_FL__c=tcb.Clearance_Pack_FL__c;
                    qu.Conversion_Cost_USD_lbs__c=tcb.Conversion_Cost_USD_lbs__c;
                    qu.DDP_TCB_FL__c=tcb.DDP_TCB_FL__c;
                    qu.DDP_TCB_PL__c=tcb.DDP_TCB_PL__c;
                    qu.Dest_Clearance_Pack_PL__c=tcb.Dest_Clearance_Pack_PL__c;
                    qu.Dest_Haulage_Port_WH_Pack_FL__c=tcb.Dest_Haulage_Port_WH_Pack_FL__c;
                    qu.Dest_Haulage_Port_WH_Pack_PL__c=tcb.Dest_Haulage_Port_WH_Pack_PL__c;
                    qu.Duty_Pack_FL__c=tcb.Duty_Pack_PL__c;
                    qu.Duty_Pack_PL__c=tcb.Duty_Pack_PL__c;
                    qu.Duty__c=tcb.Duty__c;
                    qu.FOB_TCB__c=tcb.TCB_FOB__c;
                    qu.Fixed_Costs_TCB__c=tcb.Fixed_Costs_TCB__c;
                    qu.Fobbing_Container__c=tcb.Fobbing_Container__c;
                    qu.Freight_Container__c=tcb.Freight_Container__c;
                    qu.Freight_Pack_FL__c=tcb.Freight_Pack_FL__c;
                    qu.Freight_Pack_PL_c__c=tcb.Freight_Pack_PL__c;
                    qu.IMU_DDP_Floor_Loading__c=tcb.IMU_DDP_Floor_Loading__c;
                    qu.IMU_DDP_Pallet_Loading__c=tcb.IMU_DDP_Pallet_Loading__c;
                    qu.IMU_FOB__c=tcb.IMU_FOB__c;
                    qu.Import_Clearance_USD_Cont__c=qu.Import_Clearance_USD_Cont__c;
                    qu.Initial_Design_TCB__c=tcb.Initial_Design_TCB__c;
                    qu.Initial_Design__c=tcb.Initial_Design__c;
                    qu.Interest_Months__c=tcb.Interest_Months__c;
                    qu.Interest_TCB__c=tcb.Interest_TCB__c;
                    qu.Interest__c=tcb.Interest__c;
                    qu.Loss_1st_PM__c=tcb.Loss_1st_PM__c;
                    qu.Loss_2nd_PM_Carton__c=tcb.Loss_2nd_PM_Carton__c;
                    qu.Loss_Product__c=tcb.Loss_Product__c;
                    qu.Margin_TCB__c=tcb.Margin_TCB__c;
                    qu.Margin__c=tcb.Margin__c;
                    qu.Markup_W_O_Margin_USD_lbs__c=tcb.Markup_W_O_Margin_USD_lbs__c;
                    qu.Markup_with_Margin_USD_lbs__c=tcb.Markup_with_Margin_USD_lbs__c;
                    qu.Olam_WH_s_Cost_USD_Pallet_Excl_PLT__c=tcb.Olam_WHs_Cost_USD_Pallet_Excl_PLT__c;
                    qu.Olam_WH_s_Cost_USD_Pallet_Incl_PLT__c=tcb.Olam_WHs_Cost_USD_Pallet_Incl_PLT__c;
                    qu.Other_Fixed_Cost__c=tcb.Other_Fixed_Costs__c;
                    qu.Packing_TCB_c__c = tcb.Packing_TCB__c;
                    qu.Pallet_Cost_USD_EA__c=tcb.Pallet_Cost_USD_EA__c;
                    qu.Pallet_TCB_c__c=tcb.Pallet_TCB__c;
                    qu.Port_Olam_WH_USD_Cont__c=tcb.Port_Olam_WH_USD_Cont__c;
                    qu.Processing__c=tcb.Opportunity_Processing__c;
                    qu.Product_TCB__c=tcb.Product_TCB__c;
                    qu.Total_Ingredient_Price__c=tcb.Total_Ingredient_Price__c;
                    qu.Trucking_Pack_FL__c=tcb.Trucking_Pack_FL__c;
                    //qu.Trucking_to_Final_Dest_Pack_FL__c=tcb.Trucking_to_Final_Dest_Pack_PL__c;
                    qu.WH_Cost_Dest_Pack_FL__c=tcb.WH_Cost_Dest_Pack_FL__c;
                    qu.WH_to_Customer_s_DC_Cost_USD_Pallet__c=tcb.WH_to_Customers_DC_Cost_USD_Pallet__c;
                    qu.X1st_PM_Pouch_Jar_TCB__c=tcb.TCB_1st_PM_Pouch_Jar__c;
                    qu.X2nd_PM_Outer_TCB__c=tcb.TCB_2nd_PM_Outer__c;
                    qu.Total_Ingredient_Price_No_Processing__c=tcb.Opportunity__r.Total_Ingredient_Price_No_Processing__c;
                    qu.CFR_LC_Pack_Floor_Load__c=tcb.CFR_LC_Pack_Floor_Load__c;
                    qu.CFR_LC_Pack_Pallet__c=tcb.CFR_LC_Pack_Pallet__c;
                    qu.CFR_USD_Pack_Floor_Load__c=tcb.CFR_USD_Pack_Floor_Load__c;
                    qu.CFR_USD_lbs_Pallet__c=tcb.CFR_USD_lbs_Pallet__c;
                    qu.CFR_USD_Pack_Pallet__c=tcb.CFR_USD_Pack_Pallet__c;
                    qu.DDP_LC_Pack_Floor_Load__c = tcb.DDP_LC_Pack_Floor_Load__c;
                    qu.DDP_LC_Pack_Pallet__c = tcb.DDP_LC_Pack_Pallet__c;
                    qu.DDP_USD_Pack_Floor_Load__c = tcb.DDP_USD_Pack_Floor_Load__c;
                    qu.DDP_USD_Pack_Pallet__c=tcb.DDP_USD_Pack_Pallet__c;
                    qu.DDP_USD_lbs_Floor_Load__c=tcb.DDP_USD_lbs_Floor_Load__c;
                    qu.DDP_USD_lbs_Pallet__c=tcb.DDP_USD_lbs_Pallet__c;
                    qu.FOB_LC_Pack_Floor_Load__c=tcb.FOB_LC_Pack_Floor_Load__c;
                    qu.FOB_LC_Pack_Pallet__c=tcb.FOB_LC_Pack_Pallet__c;
                    qu.FOB_USD_Pack_Floor_Load__c=tcb.FOB_USD_Pack_Floor_Load__c;
                    qu.FOB_USD_Pack_Pallet__c=tcb.FOB_USD_Pack_Pallet__c;
                    qu.FOB_USD_lbs_Floor_Load__c=tcb.FOB_USD_lbs_Floor_Load__c;
                    qu.FOB_USD_lbs_Pallet__c=tcb.FOB_USD_lbs_Pallet__c;
                    qu.FOB_to_DDP_USD_Pack_Floor_Load__c=tcb.FOB_to_DDP_USD_Pack_Floor_Load__c;
                    qu.FOB_to_DDP_USD_Pack_Pallet__c=tcb.FOB_to_DDP_USD_Pack_Pallet__c;
                    qu.FOB_to_DDP_USD_lbs_Floor_Load__c=tcb.FOB_to_DDP_USD_lbs_Floor_Load__c;
                    qu.FOB_to_DDP_USD_lbs_Pallet__c=tcb.FOB_to_DDP_USD_lbs_Pallet__c;
                    qu.MOQ_Packaging_1st__c = tcb.MOQ_Packaging_1st__c;
                    qu.PM_Type_1st__c = tcb.PM_Type_1st__c;
                    qu.Plbs_Inco_Term__c = tcb.Term__c;
                    qu.Packing_Cost_lbs__c = tcb.Packing_Cost_lbs__c;
                    qu.Import_Clearance_USD_Cont__c = tcb.Import_Clearance_USD_Cont__c;
                    qu.WH_Cost_Dest_Pack_PL__c = tcb.WH_Cost_Dest_Pack_PL__c;
                    qu.Trucking_to_Final_Dest_PackPL__c = tcb.Trucking_to_Final_Dest_Pack_PL__c;
                    qu.Quote_Processing__c = tcb.Opportunity_Processing__c;
                       
                }
            }
            
            If(setOfopp != null)
            {
                List<Opportunity> childOppListToUpdate = [Select Id,stageName,Parent_Opportunity__r.Id from Opportunity where Id IN:setOfopp];
                List<Opportunity> parentOppListToUpdate = new List<Opportunity>();
                for(Opportunity opp : childOppListToUpdate)
                {
                    opp.stageName = 'Submitted';
                   	Opportunity parentOpp = new Opportunity();
                    parentOpp.Id = opp.Parent_Opportunity__r.Id;
                    parentOpp.stageName = 'Proposal/Price Quote';
                    parentOppListToUpdate.add(parentOpp);
                    
                }
                if(childOppListToUpdate != null)
                {
                	update childOppListToUpdate;    
                }
                
                if(parentOppListToUpdate != null)
                {
                    update parentOppListToUpdate;
                }
                
            }
        }
    }
    
    public static void SyncQuote(List<Quote> quoList)
    {
        Map<Id, Id> quoteMap = new Map<Id, Id>();
        Set<Id> oppIdSet = new Set<Id>();
    	for(Quote currentQuote : quoList){
        	quoteMap.put(currentQuote.Id, currentQuote.OpportunityId);
            oppIdSet.add(currentQuote.OpportunityId);
    	}
        
			QuoteAutoSyncUtil.syncQuote(quoteMap);
        
    }
    
    
}