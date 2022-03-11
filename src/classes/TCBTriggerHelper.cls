public class TCBTriggerHelper {
            

    public static void updateFromPriceKit(list<TCB__c> listOfTCB, Set<id> setOfOppID,boolean isUpdate){
        system.debug('Inside updateFromPriceKit');
        Map<id,Opportunity> mapOfOppID = new  Map<id,Opportunity>();
        Set<String> productFamily = new Set<String>();
        Set<String> productCategory= new Set<String>();
        Map<id,id> mapOfOppIdToProdId=new Map<id,id>();      
        List<TCB__c> listOfTCBToUpdate = new List<TCB__c>();
        
        for(Opportunity Opp:[select id,PLBS_Product__c,Plbs_Weight_G__c from Opportunity where id in :setOfOppID]){
            mapOfOppID.put(opp.id,opp);
            mapOfOppIdToProdId.put(opp.Id,opp.PLBS_Product__c); 
        }
        system.debug('mapOfOppID ' +mapOfOppID);
        system.debug('mapOfOppIdToProdId ' +mapOfOppIdToProdId);
        Map<Id,PLBS_Product__c>  oppProductMap = new Map<Id,PLBS_Product__c>([Select id, Product_Family__c , Product_Category__c from PLBS_Product__c
                                                                              where id in: mapOfOppIdToProdId.values()]);
        system.debug('oppProductMap' +oppProductMap);
        if(oppProductMap.values().size() > 0){
            for(PLBS_Product__c proPrice: oppProductMap.values()){
                productFamily.add(proPrice.Product_Family__c);
                productCategory.add(proPrice.Product_Category__c);
            }
        }
        
        List<Product_Price_Kit__c> priceKitList = [Select id, Product_Family__c , Product_Category__c, Processing_loss__c , Processing_cost_USD_lb__c	
                                                   from Product_Price_Kit__c
                                                   where Product_Family__c in: productFamily
                                                   And Product_Category__c in: productCategory
                                                   And Active__c = TRUE];
        system.debug('priceKitList ' +priceKitList);
        for(TCB__c Tcb: listOfTCB){
            for (Product_Price_Kit__c matchedPrice : priceKitList) {
                if (matchedPrice.Product_Family__c == oppProductMap.get(mapOfOppIdToProdId.get(Tcb.Opportunity__c)).Product_Family__c &&
                    matchedPrice.Product_Category__c == oppProductMap.get(mapOfOppIdToProdId.get(Tcb.Opportunity__c)).Product_Category__c) {
                        if(isUpdate){
                            TCB__c tempTcb = new TCB__c(Id=Tcb.Id);
                            tempTcb.Opportunity_Processing__c = matchedPrice.Processing_cost_USD_lb__c;
                            tempTcb.Packing_loss__c  = (0.5 + (1/mapOfOppID.get(Tcb.Opportunity__c).Plbs_Weight_G__c)*100);
                            tempTcb.Loss_Product__c = matchedPrice.Processing_loss__c + (0.5 + (1/mapOfOppID.get(Tcb.Opportunity__c).Plbs_Weight_G__c )*100);
                            listOfTCBToUpdate.add(tempTcb);	
                            system.debug('TCB Update '+Tcb.Opportunity_Processing__c +' ' + Tcb.Packing_loss__c  +' '+Tcb.Loss_Product__c);
                        }else{
                            Tcb.Opportunity_Processing__c = matchedPrice.Processing_cost_USD_lb__c;
                            Tcb.Packing_loss__c  = (0.5 + (1/mapOfOppID.get(Tcb.Opportunity__c).Plbs_Weight_G__c)*100);
                            Tcb.Loss_Product__c = matchedPrice.Processing_loss__c + (0.5 + (1/mapOfOppID.get(Tcb.Opportunity__c).Plbs_Weight_G__c )*100);
                            system.debug('TCB VALUES '+Tcb.Opportunity_Processing__c +' ' + Tcb.Packing_loss__c  +' '+Tcb.Loss_Product__c);
                        }
                    }
            }
        }
        if(!listOfTCBToUpdate.isEmpty()){
            system.debug('TCB listOfTCBToUpdate '+listOfTCBToUpdate);
            update listOfTCBToUpdate;
        }
    }
    
    public static void calculate_EBITDA_FOB_DDP_USA_Pack_Floor_Load(list<TCB__c> listOfTCB,set<Id> OppId){
            Map<Id,Opportunity> mapOfIdToOpp=new map<Id,opportunity>([select id,Total_Ingredient_Price_No_Processing__c,Plbs_Weight_G__c from Opportunity where Id in :OppId]);
        String[] FieldSet1 = new String[]{'Product_TCB__c','TCB_1st_PM_Pouch_Jar__c','TCB_2nd_PM_Outer__c','Packing_TCB__c',
            								'Initial_Design_TCB__c','Fixed_Costs_TCB__c','Interest_TCB__c','Margin_TCB__c'};
     
        String[] fieldSet2 = new String[]{'Freight_Pack_FL__c','Duty_Pack_FL__c','Clearance_Pack_FL__c','Dest_Haulage_Port_WH_Pack_FL__c',
            								'WH_Cost_Dest_Pack_FL__c','Trucking_Pack_FL__c','Pallet_TCB__c'};        
       
                        
                        for(TCB__c tcb: listOfTCB) {
                            Decimal sum1a = 0;
                            for(String field1a: FieldSet1){
                                if (tcb.get(field1a) != null){
                                    sum1a  += (Decimal)tcb.get(field1a);
                                }
                            }
                            // calculate sum1b
                            Decimal sum1b = 0;
                            Decimal sum1 = 0;
                         if (	  tcb.Quotations_Given_as_Per__c 	== '40FT Container' 
                                && tcb.Pack_40FT_HC_FL__c 			!= null 
                                && tcb.Pack_40FT_HC_FL__c 			!= 0 
                                && tcb.Fobbing_Container__c 		!= null
                               ){
                                   
                                   sum1b = tcb.Fobbing_Container__c/tcb.Pack_40FT_HC_FL__c;
                               }
                            else if(   tcb.Quotations_Given_as_Per__c 	!= '40FT Container' //check 20 or 40ft, confirm it?
                                    && tcb.Pack_20FT_FL__c 				!= null 
                                    && tcb.Pack_20FT_FL__c 				!= 0 
                                    && tcb.Fobbing_Container__c			!= null
                                   ){
                                       sum1b = tcb.Fobbing_Container__c/tcb.Pack_20FT_FL__c;
                                   }
                            sum1 = sum1a + sum1b;
                            tcb.FOB_USD_Pack_Floor_Load__c = sum1;
                               // calculate sum2                    
                            Decimal sum2 =0;
                            tcb.DDP_USD_Pack_Floor_Load__c = 0;
                            for(String field2: fieldSet2){
                                if(tcb.get(field2) != null){
                                    system.debug(field2);
                                    system.debug((Decimal)tcb.get(field2));
                                    sum2 += (Decimal)tcb.get(field2);
                                    system.debug('tcb.FOB_USD_Pack_Floor_Load__c');
                                    system.debug(tcb.FOB_USD_Pack_Floor_Load__c);
                                    tcb.DDP_USD_Pack_Floor_Load__c = sum2 + tcb.FOB_USD_Pack_Floor_Load__c;
                                }
                            }
                            system.debug('sum1a: ' + sum1a + '  ' + 'sum1b: ' + sum1b + '  '+ 'sum1: ' + sum1 + '  '+ 'sum2: ' + sum2 + '  '+ 'Final:'+ tcb.DDP_USD_Pack_Floor_Load__c);
                             system.debug('Total Int ' + mapOfIdToOpp.get(tcb.Opportunity__c).Total_Ingredient_Price_No_Processing__c +' '+ mapOfIdToOpp.get(tcb.Opportunity__c).Plbs_Weight_G__c);
                             system.debug('tcb.Interest_TCB__c ' +tcb.Interest_TCB__c +' '+tcb.Margin_TCB__c); 
                            tcb.EBITDA_USD_Pack__c = 0;
                            if(  mapOfIdToOpp.get(tcb.Opportunity__c).Total_Ingredient_Price_No_Processing__c != null 
                               && mapOfIdToOpp.get(tcb.Opportunity__c).Total_Ingredient_Price_No_Processing__c != 0
                               && tcb.Interest_TCB__c            != null
                               && tcb.Margin_TCB__c 			 != null
                               && mapOfIdToOpp.get(tcb.Opportunity__c).Plbs_Weight_G__c 		 != null
                               && mapOfIdToOpp.get(tcb.Opportunity__c).Plbs_Weight_G__c			 != 0){
                                   tcb.EBITDA_USD_Pack__c = tcb.Interest_TCB__c + tcb.Margin_TCB__c 
                                       - ((1450836.38/5880000)/1000 * mapOfIdToOpp.get(tcb.Opportunity__c).Plbs_Weight_G__c);
                               }
                            else if(mapOfIdToOpp.get(tcb.Opportunity__c).Total_Ingredient_Price_No_Processing__c != null
                                    && mapOfIdToOpp.get(tcb.Opportunity__c).Total_Ingredient_Price_No_Processing__c == 0){
                                        tcb.EBITDA_USD_Pack__c = 0;
                                    }
                            system.debug('EBITDA_USD_Pack__c: ' + tcb.EBITDA_USD_Pack__c);
                         
                        }
    }
    
    public static void updateFrom1stPM(list<TCB__c> listOfTCB, Set<String> PmType1st){
        system.debug('Inside updateFrom1stPM');
        map<String,X1st_PM__c> mapofPm1st = new Map<String, X1st_PM__c>();
        List<X1st_PM__c> Pm1stList = [Select id, X1st_PM_Type__c, Loss__c from X1st_PM__c
                                      where X1st_PM_Type__c  in: pmType1st And Active__c = TRUE];
        system.debug('Pm1stList '+Pm1stList);
        for(X1st_PM__c match1stPM : Pm1stList){
            mapofPm1st.put(match1stPM.X1st_PM_Type__c, match1stPM);
        }
        
        for(TCB__c tcb:listOfTCB){
            if(mapofPm1st.containsKey(tcb.PM_Type_1st__c)){
                tcb.Loss_1st_PM__c=mapofPm1st.get(tcb.PM_Type_1st__c).Loss__c;
                system.debug('tcb.Loss_1st_PM__c '+tcb.Loss_1st_PM__c);
            }
        }
        
    }
    
    public static void updateFrom2ndPM(list<TCB__c> listOfTCB, Set<String> PmType2nd){
        system.debug('Inside updateFrom2ndPM');
        map<String,X2nd_PM__c> mapOfPm2nd = new Map<String, X2nd_PM__c>();
        List<X2nd_PM__c> Pm2ndList = [Select id, X2nd_PM_Type__c, Loss__c from X2nd_PM__c
                                      where X2nd_PM_Type__c in: pmType2nd And Active__c = TRUE ];
        system.debug('Pm2ndList '+Pm2ndList); 
        
        for(X2nd_PM__c match2ndPM : Pm2ndList){
            mapOfPm2nd.put(match2ndPM.X2nd_PM_Type__c, match2ndPM);
        }
        
        for(TCB__c tcb:listOfTCB){
            if(mapOfPm2nd.containsKey(tcb.PM_Type_2nd__c)){
                tcb.Loss_2nd_PM_Carton__c=mapOfPm2nd.get(tcb.PM_Type_2nd__c).Loss__c;
                system.debug('tcb.Loss_2nd_PM_Carton__c '+tcb.Loss_2nd_PM_Carton__c);
            }
        }
    }
    
    public static void updateFromPallet(list<TCB__c> listOfTCB, Set<String> palletType){
        system.debug('Inside updateFromPallet'); 
        map<String,Pallet__c> mapofPalletType = new Map<String, Pallet__c>(); 
        List<Pallet__c > PalletList = [Select id, Pallet_Type__c , USD_each__c from Pallet__c 
                                       where Pallet_Type__c  in: palletType And Active__c = TRUE];
        system.debug('PalletList '+PalletList);
        
        for(Pallet__c matchList : PalletList){
            mapofPalletType.put(matchList.Pallet_Type__c, matchList);
        }
        
        for(TCB__c tcb:listOfTCB){
            if(mapofPalletType.containsKey(tcb.Pallet_Type__c)){
                tcb.Pallet_Cost_USD_EA__c=mapofPalletType.get(tcb.Pallet_Type__c).USD_each__c;
                system.debug('tcb.Pallet_Cost_USD_EA__c '+tcb.Pallet_Cost_USD_EA__c);
            }
        }        
    }
    
    public static void updateFromPackingCost(set<Id> setOfOppIdToUpdateTCB){
        
        list<TCB__c> listOfTCBToUpdate= new list<TCB__c>();
        list<TCB__c> listOfTCB=[select Id,opportunity__r.Plbs_Weight_G__c,Packing_Cost_lbs__c from TCB__c where opportunity__c in :setOfOppIdToUpdateTCB];
        List<Packing_Cost__c > PackingCostList = [Select id, Packing_Cost_lbs__c, From__c, To__c from Packing_Cost__c 
                                                  where Active__c = TRUE];
        for(TCB__c tcb:listOfTCB){
            for(Packing_Cost__c MatchedList: PackingCostList){
                system.debug('tcb.Opportunity__r.Plbs_Weight_G__c '+tcb.Opportunity__r.Plbs_Weight_G__c+' MatchedList.From__c '+MatchedList.From__c+' MatchedList.To__c '+MatchedList.To__c );
                if(MatchedList.From__c < tcb.Opportunity__r.Plbs_Weight_G__c && MatchedList.To__c >=  tcb.Opportunity__r.Plbs_Weight_G__c){
                    TCB__c tcbs=new TCB__c(Id=tcb.Id);
                    tcbs.Packing_Cost_lbs__c = MatchedList.Packing_Cost_lbs__c;
                    system.debug('tcbs.Packing_Cost_lbs__c '+tcbs.Packing_Cost_lbs__c);
                    listOfTCBToUpdate.add(tcbs);
                }
            }
        }
        if(!listOfTCBToUpdate.isEmpty()){
            system.debug('listOfTCBToUpdate '+listOfTCBToUpdate);
            update listOfTCBToUpdate;
        }
    }
    
    public static void updateFromQuotationsAsPer(list<TCB__c> listOfTCB, Set<String> QuotationsAsPer){ 
        system.debug('Inside updateFromQuotationsAsPer'); 
        map<String,Quotations_as_per__c> mapOfQuotationsAsPer = new Map<String, Quotations_as_per__c>();
        List<Quotations_as_per__c  > QuotationsList = [Select id , USD__c, Fobbing_container__c  
                                                       from Quotations_as_per__c where Fobbing_container__c in:QuotationsAsPer And Active__c = TRUE];
        system.debug('QuotationsList '+QuotationsList);
        
        for(Quotations_as_per__c matchList : QuotationsList){
            mapOfQuotationsAsPer.put(matchList.Fobbing_container__c, matchList);
        }
        
        for(TCB__c tcb:listOfTCB){
            if(mapOfQuotationsAsPer.containsKey(tcb.Quotations_Given_as_Per__c)){
                tcb.Fobbing_Container__c=mapOfQuotationsAsPer.get(tcb.Quotations_Given_as_Per__c).USD__c;
                system.debug('tcb.Fobbing_Container__c '+tcb.Fobbing_Container__c);
            }
        }      
    }
    
}