public class TCBTriggerHandler {
    static list<Interest__c> interest=[select id,Interest__c from Interest__c where Active__c=true limit 1]; 
    
    Public static void BeforeInsert(list<TCB__c> listOfTCB){  
        Set<id> setOfOppID = new Set<id>();
        Set<String> PmType1st = new Set<String>();
        Set<String> PmType2nd = new Set<String>();
        Set<String> palletType = new Set<String>();
        Set<String> QuotationsAsPer = new Set<String>();
        list<TCB__c> listOfTCBToUpdate1stPm = new list<TCB__c>();
        list<TCB__c> listOfTCBToUpdate2ndPm = new list<TCB__c>();
        list<TCB__c> listOfTCBToUpdatePalletType = new list<TCB__c>();
        list<TCB__c> listOfTCBToUpdateQuotation = new list<TCB__c>();
        String[] FieldsToRollUp = new String[]{'Product_TCB__c','TCB_1st_PM_Pouch_Jar__c','TCB_2nd_PM_Outer__c','Pallet_TCB__c',
            'Packing_TCB__c','Initial_Design_TCB__c','Fixed_Costs_TCB__c','Fobbing_Fee_TCB__c',
            'Interest_TCB__c','Margin_TCB__c'};
                
                for(TCB__c Tcb: listOfTCB){
                    Tcb.TCB_FOB__c = 0;                                          //rollUpTCBFOB start
                    for (String field : FieldsToRollUp) {
                        system.debug(TCb.Opportunity__c+' SUM '+field+' '+Tcb.get(field));
                        if (Tcb.get(field) != null) {
                            Tcb.TCB_FOB__c += (Decimal)Tcb.get(field);
                        }
                    }
                    system.debug('tcb.Opportunity__c' +tcb.Opportunity__c);
                    system.debug('interest '+interest);//rollUpTCBFOB end
                    if(interest.size()>0 && interest[0].Interest__c != null){							//updateInterest Start
                        system.debug('interest.Interest__c' +interest[0].Interest__c);	
                        tcb.Interest__c=(Decimal)interest[0].Interest__c;
                    }else{
                        tcb.Interest__c=0;
                    }												//updateInterest end
                    if(tcb.Opportunity__c!= null){
                        setOfOppID.add(tcb.Opportunity__c);
                    }
                    if(tcb.PM_Type_1st__c!=null ){
                        PmType1st.add(tcb.PM_Type_1st__c);
                        listOfTCBToUpdate1stPm.add(tcb);
                    }
                    if(tcb.PM_Type_2nd__c!=null ){
                        PmType2nd.add(tcb.PM_Type_2nd__c);
                        listOfTCBToUpdate2ndPm.add(tcb);
                    }
                    if(tcb.Pallet_Type__c!=null ){
                        palletType.add(tcb.Pallet_Type__c);
                        listOfTCBToUpdatePalletType.add(tcb);
                    }
                    if(tcb.Quotations_Given_as_Per__c != null){
                        QuotationsAsPer.add(tcb.Quotations_Given_as_Per__c);
                        listOfTCBToUpdateQuotation.add(tcb);
                    }
                }
        
        if(!setOfOppID.isEmpty()){
            TCBTriggerHelper.updateFromPriceKit(listOfTCB, setOfOppID,false);
            TCBTriggerHelper.calculate_EBITDA_FOB_DDP_USA_Pack_Floor_Load(listOfTCB, setOfOppID);
        }
        if(!listOfTCBToUpdate1stPm.isEmpty()){
            TCBTriggerHelper.updateFrom1stPM(listOfTCBToUpdate1stPm, PmType1st);
        }
        if(!listOfTCBToUpdate2ndPm.isEmpty()){
            TCBTriggerHelper.updateFrom2ndPM(listOfTCBToUpdate2ndPm, PmType2nd);
        }
        if(!listOfTCBToUpdatePalletType.isEmpty()){
            TCBTriggerHelper.updateFromPallet(listOfTCBToUpdatePalletType, palletType);
        }
        if(!listOfTCBToUpdateQuotation.isEmpty()){
            TCBTriggerHelper.updateFromQuotationsAsPer(listOfTCBToUpdateQuotation, QuotationsAsPer);
        }
    }
    
    Public static void BeforeUpdate(list<TCB__c> listOfTCB, Map<id,TCB__c> OldMap){ 
        System.debug('Inside TCB beforeUpdate');
        Set<id> setOfOppIDToCalculateEDITA = new Set<id>();
        Set<String> PmType1st = new Set<String>();
        Set<String> PmType2nd = new Set<String>();
        Set<String> palletType = new Set<String>();
        Set<String> QuotationsAsPer = new Set<String>();
        list<TCB__c> listOfTCBToUpdate1stPm = new list<TCB__c>();
        list<TCB__c> listOfTCBToUpdate2ndPm = new list<TCB__c>();
        list<TCB__c> listOfTCBToUpdatePalletType = new list<TCB__c>();
        list<TCB__c> listOfTCBToUpdateQuotation = new list<TCB__c>();
        
        String[] FieldsToRollUp = new String[]{'Product_TCB__c','TCB_1st_PM_Pouch_Jar__c','TCB_2nd_PM_Outer__c','Pallet_TCB__c',
            'Packing_TCB__c','Initial_Design_TCB__c','Fixed_Costs_TCB__c','Fobbing_Fee_TCB__c',
            'Interest_TCB__c','Margin_TCB__c'};
                
                for(TCB__c Tcb: listOfTCB){
                    Tcb.TCB_FOB__c = 0;                                          //rollUpTCBFOB start
                    for (String field : FieldsToRollUp) {   
                         system.debug('SUM '+field+' '+Tcb.get(field));
                        if (Tcb.get(field) != null) {
                            Tcb.TCB_FOB__c += (Decimal)Tcb.get(field);
                        }
                    }
                    if(tcb.Opportunity__c!=null){
                        setOfOppIDToCalculateEDITA.add(tcb.Opportunity__c);
                    }
                    system.debug('tcb.Opportunity__c' +tcb.Opportunity__c);		//rollUpTCBFOB end
                    if(tcb.PM_Type_1st__c!=null &&  tcb.PM_Type_1st__c != OldMap.get(tcb.Id).PM_Type_1st__c ){
                        PmType1st.add(tcb.PM_Type_1st__c);
                        listOfTCBToUpdate1stPm.add(tcb);
                    }
                    if(tcb.PM_Type_2nd__c!=null &&  tcb.PM_Type_2nd__c != OldMap.get(tcb.Id).PM_Type_2nd__c){
                        PmType2nd.add(tcb.PM_Type_2nd__c);
                        listOfTCBToUpdate2ndPm.add(tcb);
                    }
                    if(tcb.Pallet_Type__c!=null  &&  tcb.Pallet_Type__c != OldMap.get(tcb.Id).Pallet_Type__c){
                        palletType.add(tcb.Pallet_Type__c);
                        listOfTCBToUpdatePalletType.add(tcb);
                    }
                    /*system.debug('interest '+interest);
                    if(interest.size()>0 && interest[0].Interest__c != null){							//updateInterest Start
                        system.debug('interest.Interest__c' +interest[0].Interest__c);	
                        tcb.Interest__c=(Decimal)interest[0].Interest__c;
                    }else{
                        tcb.Interest__c=0;
                    }*/																					//updateInterest end
                    
                    if(tcb.Quotations_Given_as_Per__c != null &&  tcb.Quotations_Given_as_Per__c != OldMap.get(tcb.Id).Quotations_Given_as_Per__c){
                        QuotationsAsPer.add(tcb.Quotations_Given_as_Per__c);
                        listOfTCBToUpdateQuotation.add(tcb);
                    }
                }
        if(!setOfOppIDToCalculateEDITA.isEmpty()){
            TCBTriggerHelper.calculate_EBITDA_FOB_DDP_USA_Pack_Floor_Load(listOfTCB, setOfOppIDToCalculateEDITA);
        }
        if(!listOfTCBToUpdate1stPm.isEmpty()){
            TCBTriggerHelper.updateFrom1stPM(listOfTCBToUpdate1stPm, PmType1st);
        }
        if(!listOfTCBToUpdate2ndPm.isEmpty()){
            TCBTriggerHelper.updateFrom2ndPM(listOfTCBToUpdate2ndPm, PmType2nd);
        }
        if(!listOfTCBToUpdatePalletType.isEmpty()){
            TCBTriggerHelper.updateFromPallet(listOfTCBToUpdatePalletType, palletType);
        }
        if(!listOfTCBToUpdateQuotation.isEmpty()){
            TCBTriggerHelper.updateFromQuotationsAsPer(listOfTCBToUpdateQuotation, QuotationsAsPer);
        }
    }
}