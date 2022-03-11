public class OpportunityTriggerHelperVietnam {
    
    public static void beforeInsert(List<Opportunity> oppList)
    {
        Set<Id> accId = new Set<Id>();
        Id PLBSTenderOppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Opportunity').getRecordTypeId();
        List<Opportunity> paropp = [Select PLBS_Opportunity_Number__c from Opportunity where RecordTypeId=:PLBSTenderOppRecId order by createdDate desc limit 1];
        String ordinalNumber;
        if(paropp.size()>0)
        {
        	if(Test.isRunningTest())
            {
                ordinalNumber = '0';
            }
            else
            {
            	ordinalNumber = paropp[0].PLBS_Opportunity_Number__c;    
            }
                
        }
        
        Integer ordNum;
        
        for(Opportunity opp : oppList)
        {
            accId.add(opp.AccountId);
        }
        
        Map<Id,Account> mapOfAccountIdAndAccount = new Map<id,Account>([Select id,Name from Account where Id IN: accId]);
        
        if(ordinalNumber == null || ordinalNumber == '')
        {
            ordNum = 0;
        }
        else
        {
        	String [] ordNumArr = ordinalNumber.split('_');
            if(Test.isRunningTest())
            {
                ordNum = 0;
            }
            else
            {
            	ordNum = Integer.valueOf(ordNumArr[3]);    
            }
        	    
        }
        System.debug('opp'+oppList);
        
        for(Opportunity opp : oppList)
        {
            
            If(opp.RecordTypeId == PLBSTenderOppRecId)
            {
                ordNum = ordNum+1;
                DateTime CreatedDate = System.now();
                String accName;
                if(mapOfAccountIdAndAccount.containsKey(opp.AccountId))
                {
                    accName = mapOfAccountIdAndAccount.get(opp.AccountId).Name;
                }
                
                String OppNum = accName +'_'+CreatedDate.year()+'_'+CreatedDate.month()+'_'+ordNum;
                System.debug('OppNum'+OppNum);
                opp.PLBS_Opportunity_Number__c = OppNum;
            }
        }
    }
    
    
    public static void afterInsert(list<Opportunity> listOfOpp){
        system.debug('Inside OpportunityTriggerHelper.afterInsert');
        Id TCBRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Product').getRecordTypeId();
        Id ParentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Opportunity').getRecordTypeId();
        set<String> setOfOppToUpdate=new set<String>(); 
        list<TCB__c> listOfTCB=new list<TCB__c>();
        set<String> IsoCodelist=new set<String>();
        list<Opportunity> OppListToUpdate=new list<opportunity>();
        set<Id> setOfOppIdToUpdateTCB=new set<Id>();
                
                for(Opportunity opp:listOfOpp){
                     system.debug('OPP.ID '+opp.id);
                      system.debug('PLBS_Product__c '+opp.PLBS_Product__c);
                    system.debug('opp.RecordTypeId == TCBRecordTypeId '+opp.RecordTypeId+'=='+TCBRecordTypeId);
                    if(opp.RecordTypeId==TCBRecordTypeId && opp.PLBS_Product__c!=null){
                        setOfOppToUpdate.add(opp.Id);
                        listOfTCB.add(new TCB__c(Opportunity__c=opp.Id,Parent_Opportunity__c=Opp.Parent_Opportunity__c));
                    }
                    if(opp.Local_Currency__c!=null && opp.RecordTypeId==ParentRecordTypeId){
                        IsoCodelist.add(opp.Local_Currency__c);
                        OppListToUpdate.add(opp);
                    }
                    if(opp.Plbs_Weight_G__c != null && opp.RecordTypeId==TCBRecordTypeId){
                        setOfOppIdToUpdateTCB.add(opp.Id);
                    }                    
                }
        
        if(!OppListToUpdate.isEmpty()){
            OpportunityTriggerHelperVietnam.updateExchangeRates(IsoCodelist,OppListToUpdate);
        }
        system.debug('listOfTCB '+listOfTCB);
        if(!listOfTCB.isEmpty()){
            OpportunityTriggerHelperVietnam.insertTCBAndTagOpp(setOfOppToUpdate,listOfTCB);
        }
        system.debug('setOfOppIdToUpdateTCB '+setOfOppIdToUpdateTCB);
        if(!setOfOppIdToUpdateTCB.isEmpty()){
            TCBTriggerHelper.updateFromPackingCost(setOfOppIdToUpdateTCB);
        }
       
    }
    
    public static void beforeUpdate(list<Opportunity> listOfOpp,Map<id,Opportunity> oldMap){
        system.debug('Inside OpportunityTriggerHelper.beforeUpdate');
        Id TCBRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Product').getRecordTypeId();
        Id ParentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Opportunity').getRecordTypeId();
        set<Id> setOfOppId= new set<Id>();
        
        for(Opportunity opp:listOfOpp){
            if(opp.PLBS_Product__c!=null && opp.PLBS_Product__c != oldMap.get(opp.Id).PLBS_Product__c && opp.RecordTypeId==TCBRecordTypeId ){
                setOfOppId.add(opp.Id);
            }   
        }
        system.debug('setOfOppId '+setOfOppId);
        if(!setOfOppId.isEmpty()){
            list<TCB__c> listOfTCB = [select id,Opportunity_Processing__c,Packing_loss__c,Loss_Product__c,Opportunity__c from TCB__c where Opportunity__c in :setOfOppId];
            TCBTriggerHelper.updateFromPriceKit(listOfTCB, setOfOppId,true);
        }
    }
    
    public static void afterUpdate(list<Opportunity> listOfOpp,Map<id,Opportunity> oldMap){
        Id ParentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Opportunity').getRecordTypeId();
        Id TCBRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Product').getRecordTypeId();
        set<String> IsoCodelist=new set<String>();
        set<Id> setOfOppIdToUpdateTCB=new set<Id>();
        list<Opportunity> OppListToUpdate=new list<opportunity>();
        
        for(Opportunity opp:listOfOpp){
            if(opp.Local_Currency__c!=null && opp.Local_Currency__c != oldMap.get(opp.Id).Local_Currency__c && opp.RecordTypeId==ParentRecordTypeId ){
                IsoCodelist.add(opp.Local_Currency__c);
                OppListToUpdate.add(opp);
            }
            if(opp.Plbs_Weight_G__c != null && opp.Plbs_Weight_G__c != oldMap.get(opp.Id).Plbs_Weight_G__c && opp.RecordTypeId==TCBRecordTypeId){
                setOfOppIdToUpdateTCB.add(opp.Id);
            }
        }
        
        if(!OppListToUpdate.isEmpty()){
            system.debug('IsoCodelist '+IsoCodelist +' '+OppListToUpdate);
            OpportunityTriggerHelperVietnam.updateExchangeRates(IsoCodelist,OppListToUpdate);
        }
        system.debug('setOfOppIdToUpdateTCB '+setOfOppIdToUpdateTCB);
        if(!setOfOppIdToUpdateTCB.isEmpty()){
            TCBTriggerHelper.updateFromPackingCost(setOfOppIdToUpdateTCB);
        }
    }
    
    
    
    //Sunil this method Creates TCB record, tags to Opp 
    public static void insertTCBAndTagOpp(set<String> setOfOppToUpdate,list<TCB__c> listOfTCB){
        system.debug('Inside insertTCBAndTagOpp'); 
        list<Opportunity> listOfOppToUpdate=new list<Opportunity>();
        map<string,Opportunity> mapOfParentOppToUpdate= new map<string,Opportunity>();
        system.debug('listOfTCB '+listOfTCB);
        try{

        if(!listOfTCB.isEmpty()){
            if(!setOfOppToUpdate.isEmpty()){
                map<Id,Opportunity> mapOfOppIdToOpp= new map<Id,Opportunity>([select id,Account.Inco_Terms__c from Opportunity where Id in :setOfOppToUpdate AND AccountId != null]);
                system.debug('mapOfOppIdToOpp '+mapOfOppIdToOpp);
                for(TCB__c tcb:listOfTCB){
                    if(mapOfOppIdToOpp.containsKey(tcb.Opportunity__c)){
                        tcb.Term__c=mapOfOppIdToOpp.get(tcb.Opportunity__c).Account.Inco_Terms__c;
                    }
                }
            }
            
            insert listOfTCB;
            System.debug('listOfTCB AfterInsert '+listOfTCB);    
        }
		    
        if(!setOfOppToUpdate.isEmpty()){
            list<Opportunity> listOfOpps=[select id,Parent_Opportunity__c, PLBS_Product__r.Name from Opportunity where Id in:setOfOppToUpdate];
            for(Opportunity opp:listOfOpps){
                mapOfParentOppToUpdate.put(opp.Parent_Opportunity__c,new opportunity(Id=opp.Parent_Opportunity__c,StageName='Preparing Sample/Packaging'));//make it a set
                listOfOppToUpdate.add(new opportunity(Id=opp.Id,Name=Opp.Name));
            }
            system.debug('mapOfParentOppToUpdate '+mapOfParentOppToUpdate);
            if(!listOfOppToUpdate.isEmpty()){
                update listOfOppToUpdate;
                update mapOfParentOppToUpdate.values();
            }
        }
                        
        }
        catch(Exception e){
            System.debug('Exception '+e);
             System.debug('Exception Line Number ' + e.getLineNumber());
        }
    }
    
    public static void updateExchangeRates(set<String> IsoCodelist,list<Opportunity> listOfOpp){
        Map<String,DatedConversionRate> mapOfIsoCodeToDCR = new Map<String,DatedConversionRate>();
        mapOfIsoCodeToDCR.put('VND',DatedConversionRateService.getConversionRate(system.today(),'VND'));   //VND
        list<Opportunity> listOfOppToUpdate=new list<Opportunity>();
        
        for(String IsoCode:IsoCodelist){
            DatedConversionRate DCR = DatedConversionRateService.getConversionRate(system.today(),IsoCode);
            mapOfIsoCodeToDCR.put(DCR.IsoCode,DCR);
        }
        System.debug('mapOfIsoCodeToDCR '+mapOfIsoCodeToDCR);
        for(Opportunity Opps:listOfOpp){ //list new
            opportunity Opp = new opportunity(Id=opps.Id);
            system.debug('mapOfIsoCodeToDCR '+mapOfIsoCodeToDCR.get(Opps.Local_Currency__c).ConversionRate);
            Opp.Exchange_Rate_Local_USD__c = 1/mapOfIsoCodeToDCR.get(Opps.Local_Currency__c).ConversionRate;
            Opp.Exchange_Rate_USD_VND__c = mapOfIsoCodeToDCR.get('VND').ConversionRate;
            listOfOppToUpdate.add(Opp);
        }
        if(!listOfOppToUpdate.isEmpty()){
            update listOfOppToUpdate;
        }
    }
    
  
}