public class CloneTenderOppWithProdController {
    
    private ApexPages.StandardController controller {get;set;}
    private opportunity opp{get;set;}
    public Opportunity OpportunityCloned {get;set;}
    
    public CloneTenderOppWithProdController(ApexPages.StandardController controller){
                System.debug('Inside CloneTenderOppWithProdController');
        this.controller = controller;
        opp = (Opportunity)controller.getRecord();
        opp = [select id, owner.name,Accountid,Amount,CloseDate,Contractid,Description,NextStep,Name,stageName,Ownerid,Campaignid,IsPrivate,Probability,Pricebook2Id,Type,
               Tender_Number__c, Market__c, Person_In_Charge__c, Bid_Open__c,Tender_Contract_Start__c,Tender_Contract_End__c,LeadSource,
               Local_Currency__c, Exchange_Rate_Local_USD__c, Exchange_Rate_USD_VND__c from Opportunity where id =: opp.Id];
        System.debug('Opp '+Opp);
        OpportunityCloned = opp.clone(false,true);
        
    }
    
     public PageReference save() {
        System.debug('Inside Extension save');
        
        try {
            insert(OpportunityCloned);
            
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
         
         Map<String,Opportunity> oppProToClone = new Map<String,Opportunity>();
         Map<String,TCB__c> TCBToClone =new Map<String,TCB__c>();
         Map<string,string> mapOfChildOppToRefOppId= new Map<string,string>();
         set<String> setOfRefOppId = new set<String>();
        List<Opportunity> soppProduct = [select Id,owner.name,Accountid,Amount,CloseDate,Contractid,Description,LeadSource,NextStep,Name,stageName,Ownerid,Campaignid,IsPrivate,Probability,Pricebook2Id,Type,
                                         Parent_Opportunity__c, Plbs_Shelf_Price__c,Plbs_Weight_G__c, PLBS_Product__c, Case_Mix__c,Plbs_Annual_Unit__c,Plbs_Est_Award__c,Plbs_Manufacturing_Facility__c,
                                         (select Id,Quotations_Given_as_Per__c,Opportunity_Processing__c,Loss_Product__c,Loss_1st_PM__c,Loss_2nd_PM_Carton__c, Packing_Cost_lbs__c, Pallet_Cost_USD_EA__c,
                                         Initial_Design__c, Other_Fixed_Costs__c, Fobbing_Container__c, TCB_FOB__c,Interest__c , Interest_Months__c,Margin__c , Freight_Container__c, Duty__c,Import_Clearance_USD_Cont__c, 
                                         Olam_WHs_Cost_USD_Pallet_Excl_PLT__c ,Olam_WHs_Cost_USD_Pallet_Incl_PLT__c, WH_to_Customers_DC_Cost_USD_Pallet__c, Pallet_Type__c, Max_Height_mm__c, Port_Olam_WH_USD_Cont__c,
                                         Max_Weight_kg__c ,Term__c, Port_of_Entry__c, Container_Type__c, PM_Type_1st__c, X1st_PM_Pouch_jar__c, MOQ_Packaging_1st__c, X1st_Structure__c,  X1st_Printing__c , Tare_Weight_g_1st__c, Length_mm_1st__c,
                                         Width_mm_1st__c , Depth_Gusset_Height_mm__c , PM_Type_2nd__c ,X2nd_PM_Carton__c , MOQ_Packaging_2nd__c, Structure_2nd__c ,Printing_2nd__c, Tare_Weight_g_2nd__c, Length_Depth_mm__c, Width_mm_2nd__c ,
                                         Height_mm__c ,Unit_CTN__c ,Case_Mix_PL__c ,CTN_Layer__c ,Layer_PL__c ,Layer_PL_40HC__c , PL_20FT__c ,PL_40FT__c ,CTN_20FT__c, CTN_40FT__c , CTN_40FT_HC__c from TCBs__r)
                                         from Opportunity where Parent_Opportunity__c  =: opp.Id];

         for(Opportunity Opp:soppProduct){
             Opportunity inCopy = Opp.clone(false,true);
            inCopy.Parent_Opportunity__c = OpportunityCloned.Id;
            inCopy.StageName = 'Opening';
             for(TCB__c tcb: Opp.TCBs__r){
                 TCB__c inCopyTCB = tcb.clone(false,true);  
                 inCopyTCB.PM_Type_1st__c  = tcb.PM_Type_1st__c;
                 inCopyTCB.Quotations_Given_as_Per__c  = tcb.Quotations_Given_as_Per__c;
                 inCopyTCB.PM_Type_2nd__c  = tcb.PM_Type_2nd__c;
                 inCopyTCB.Pallet_Type__c  = tcb.Pallet_Type__c;
                 TCBToClone.put(Opp.Id,inCopyTCB);//only one TCb
             }                
            oppProToClone.put(Opp.id,inCopy);
         }

         insert oppProToClone.values();
         system.debug('oppProToClone after '+oppProToClone);
         
         for(String ReferenceOppId:oppProToClone.keySet()){
             mapOfChildOppToRefOppId.put(oppProToClone.get(ReferenceOppId).Id,ReferenceOppId);
         }
         
         system.debug('mapOfChildOppToRefOppId '+mapOfChildOppToRefOppId);       
         list<TCB__c> listOfNewTCB =[select Id,Opportunity__c from TCB__c where Opportunity__c in :mapOfChildOppToRefOppId.keySet()];
         system.debug('listOfNewTCB '+listOfNewTCB);
         for(TCB__c tcb : listOfNewTCB){
               System.debug('Inside TCB');
             if( mapOfChildOppToRefOppId.containsKey(tcb.Opportunity__c )){
                 TCBToClone.get( mapOfChildOppToRefOppId.get(tcb.Opportunity__c) ).Id = tcb.Id;
             }
         }
         upsert TCBToClone.values();
         system.debug('TCBToClone.values() After  '+TCBToClone.values());
         
         for(Opportunity OppProCloned : soppProduct){
            setOfRefOppId.add(OppProCloned.id);
        }

        List<OpportunityLineItem> inToClone = new List<OpportunityLineItem>();
        List<OpportunityLineItem> soppIngredient = [Select Id, Grade__c, Product2Id, ProductCode,PricebookEntryId, ListPrice, OpportunityId, Name, Quantity, Ratio__c, UnitPrice, TotalPrice
                                                    from OpportunityLineItem
                                                    Where OpportunityId =: oppProToClone.keySet()];
        
        
         
       // for(Opportunity newOppProductClone: oppProToClone.values()){
         //   String NewOppProId = newOppProductClone.id;
            for(OpportunityLineItem oLI : soppIngredient){
                OpportunityLineItem inCopyIn = oLI.clone(false,true);
                inCopyIn.OpportunityId = oppProToClone.get(oLI.OpportunityId).Id;
                inCopyIn.UnitPrice = null;
                inToClone.add(inCopyIn);
            } 
        //}
        
        if (intoClone.size() > 0) {
        	insert inToClone;    
        }  
         system.debug('Last '+[select Id,Opportunity__c from TCB__c where Opportunity__c in :mapOfChildOppToRefOppId.keySet()]);
		 return new PageReference('/'+OpportunityCloned.id);
     }
}