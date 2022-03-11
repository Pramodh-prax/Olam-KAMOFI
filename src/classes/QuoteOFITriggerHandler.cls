// 
// Class created by Ashwini
// Last modified by Joel Tom on 24/01/2022
// 

public class QuoteOFITriggerHandler {
    public static void checkUserAccess(list<Quote> quoteList)
    {
        Map<string,Opportunity> mapOfUserIdToQu =new Map<string,Opportunity>();
        Map<String,PriceBook_Record__mdt> mapofLabeltoPricebook=new Map<String,PriceBook_Record__mdt>();
        Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
        Set<id> AccountIds = new Set<id>();
        Set<id> oppIds=new Set<id>();
        map<id,id> OppIdQuoteId=new map<Id,id>();
        
        for(Quote qu:quoteList)
        {
            oppIds.add(qu.OpportunityId); 
        	OppIdQuoteId.put(qu.Id,qu.OpportunityId);
        }
        
        Map<id,List<Opportunity>> mapofopp=new  Map<id,List<Opportunity>>();
        mapofopp= getAccountId(oppIds );
        
        for(Id accid:mapofopp.keySet())
        {
            for(Opportunity opp: mapofopp.get(accid)) 
            {
                AccountIds.add(opp.AccountId);
            } 
        }
        
        mapOfUserIdToTeams=QuoteOFITriggerHandler.getAccountTeams(AccountIds);
        mapOfUserIdToQu=QuoteOFITriggerHandler.getAccountQu(oppIds);
        mapofLabeltoPricebook=QuoteOFITriggerHandler.getPriceBook(); 
        
        //Code Added by Joel Tom to validate Opp team members
        Map<Id,Map<Id,String>> oppUserRoleMap = opportunityTriggerOfiUser.fetchOppTeamMemberAndRole(oppIds);
        Map<String,Opportunity_Team_Member_Role__mdt> mapofLabeltoOppTeamMemberRoleMDT = opportunityTriggerOfiUser.getOppTeamMemberRoleMDT('Opportunity');
        
        for(Quote qu:quoteList)
        { 
            if(!oppUserRoleMap.isEmpty()){
                Id oppid = OppIdQuoteId.get(qu.id);
                if(oppUserRoleMap.containskey(oppid)){    
                    if(mapofLabeltoOppTeamMemberRoleMDT.containsKey(oppUserRoleMap.get(oppid).get(userinfo.getuserId()))){
                        String BU;
                        BU=mapOfUserIdToQu.get(String.ValueOF(qu.OpportunityId)).Business_Unit__c;
                        if(!mapofLabeltoPricebook.isEmpty()){ 
                            PriceBook_Record__mdt pr1=mapofLabeltoPricebook.get(BU);
                            qu.Pricebook2Id = pr1.PriceBookID__c;
                        }
                        qu.Bussiness_Unit__c = BU;
                    }else{
                        validateAccountTeamUserAccessOnInsert(qu,mapOfUserIdToTeams, mapofLabeltoPricebook,mapOfUserIdToQu);
                    }
                }
                else{validateAccountTeamUserAccessOnInsert(qu,mapOfUserIdToTeams, mapofLabeltoPricebook,mapOfUserIdToQu);} 
            }
            else{validateAccountTeamUserAccessOnInsert(qu,mapOfUserIdToTeams, mapofLabeltoPricebook,mapOfUserIdToQu);} 
        }
    }
            
   //Method Added by Joel Tom to validate the Opp team members user access
    public static void validateAccountTeamUserAccessOnInsert(Quote qu, Map<string,Teams__c> mapOfUserIdToTeams, Map<String,PriceBook_Record__mdt> mapofLabeltoPricebook, Map<string,Opportunity> mapOfUserIdToQu)
    {
        String BU;
        if(!mapOfUserIdToTeams.isempty()){
            BU=mapOfUserIdToQu.get(String.ValueOF(qu.OpportunityId)).Business_Unit__c;
            Teams__c teamObj=mapOfUserIdToTeams.get(String.valueOf(userinfo.getuserId()));       
            
            if(mapOfUserIdToTeams.containskey(String.valueOf(userinfo.getuserId())) && (BU==teamObj.Business_Unit__c || teamObj.Business_Unit__c =='All')){     
                if(!mapofLabeltoPricebook.isEmpty()){ 
                    PriceBook_Record__mdt pr1=mapofLabeltoPricebook.get(BU);
                    qu.Pricebook2Id=pr1.PriceBookID__c;
                }
                qu.Bussiness_Unit__c = BU;
            }else{
                qu.addError(system.label.OFI_Quote_Create_Error_Msg);
            }
        }
        else{ qu.addError(system.label.OFI_Quote_Create_Error_Msg);} 
    }
    
    
    public static void checkUserAccessForUpdate(list<Quote> newquoteList,Map<Id,Quote> oldMapOfQuote)
    {   
        Map<string,Opportunity> mapOfUserIdToQu =new Map<string,Opportunity>();
        Map<String,PriceBook_Record__mdt> mapofLabeltoPricebook=new Map<String,PriceBook_Record__mdt>();
        Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
        Set<id> AccountIds = new Set<id>();
        Set<id> oppIds=new Set<id>();
        map<id,id> OppIdQuoteId=new map<Id,id>();
        
        for(Quote qu:newquoteList)
        {
            oppIds.add(qu.OpportunityId);
            OppIdQuoteId.put(qu.Id,qu.OpportunityId);
        }
        
        Map<id,List<Opportunity>> mapofopp=new  Map<id,List<Opportunity>>();
        mapofopp= getAccountId(oppIds );
        
        for(Id accid:mapofopp.keySet())
        {
            for(Opportunity opp: mapofopp.get(accid)) 
            {
                AccountIds.add(opp.AccountId);
            }  
        }
        
        //Code Added by Joel Tom to validate Opp team members
        Map<Id,Map<Id,String>> oppUserRoleMap = opportunityTriggerOfiUser.fetchOppTeamMemberAndRole(oppIds);
        Map<String,Opportunity_Team_Member_Role__mdt> mapofLabeltoOppTeamMemberRoleMDT = opportunityTriggerOfiUser.getOppTeamMemberRoleMDT('Opportunity');
        
        mapOfUserIdToTeams=QuoteOFITriggerHandler.getAccountTeams(AccountIds);
        mapOfUserIdToQu=QuoteOFITriggerHandler.getAccountQu(oppIds);
        mapofLabeltoPricebook=QuoteOFITriggerHandler.getPriceBook(); 
        
        for(Quote qu:newquoteList)
           { 
                if(!oppUserRoleMap.isEmpty()){
                    Id oppid = OppIdQuoteId.get(qu.id);
                    if(oppUserRoleMap.containskey(oppid)){    
                        if(!(mapofLabeltoOppTeamMemberRoleMDT.containsKey(oppUserRoleMap.get(oppid).get(userinfo.getuserId())))){
                            validateAccountTeamUserAccessOnUpdate(qu,mapOfUserIdToTeams, mapofLabeltoPricebook,oldMapOfQuote,mapOfUserIdToQu);
                        }
                    }
                    else{validateAccountTeamUserAccessOnUpdate(qu,mapOfUserIdToTeams, mapofLabeltoPricebook,oldMapOfQuote,mapOfUserIdToQu);} 
                }
                else{validateAccountTeamUserAccessOnUpdate(qu,mapOfUserIdToTeams, mapofLabeltoPricebook,oldMapOfQuote,mapOfUserIdToQu);} 
               
        }
    }
    
    //Method Added by Joel Tom to validate the Opp team members user access
    public static void validateAccountTeamUserAccessOnUpdate(Quote qu, Map<string,Teams__c> mapOfUserIdToTeams, Map<String,PriceBook_Record__mdt> mapofLabeltoPricebook, Map<Id,Quote> oldMapOfQuote, Map<string,Opportunity> mapOfUserIdToQu)
    {
        String BU;
        Teams__c obj=mapOfUserIdToTeams.get(String.valueOf(userinfo.getuserId()));
        boolean isAccountTeam=false;
        if(!mapOfUserIdToTeams.isempty()){
            BU=mapOfUserIdToQu.get(String.ValueOF(qu.OpportunityId)).Business_Unit__c;
            if(mapOfUserIdToTeams.containskey(String.valueOf(userinfo.getuserId())) && (BU==obj.Business_Unit__c || obj.Business_Unit__c=='All')){
                isAccountTeam=true;
                PriceBook_Record__mdt pr1=mapofLabeltoPricebook.get(BU);
                qu.Pricebook2Id=pr1.PriceBookID__c;
            }
            else{ 
                qu.addError(system.label.OFI_Quote_Create_Error_Msg);}
        }
        else{ 
            qu.addError(system.label.OFI_Quote_Create_Error_Msg);
        }
        
        if(isAccountTeam==true){
            if((BU==OpportunityConstants.OFI_BU_ALL) || ((oldMapOfQuote.get(qu.id).Bussiness_Unit__c==BU)&& (oldMapOfQuote.get(qu.id).Bussiness_Unit__c==qu.Bussiness_Unit__c) )){ 
            }
            else{
                qu.addError(system.label.OFI_Quote_Create_Error_Msg);
            }
        }
        else{
            qu.addError(system.label.OFI_Quote_Create_Error_Msg);
        } 
    
    }
    
    public static Map<string,Opportunity> getAccountQu(set<id> oppId)
    {
        list<Opportunity> listOfTeams=[Select id,Name,Business_Unit__c,AccountId from Opportunity where Id In :oppId   ];
        Map<string,Opportunity> mapOfUserIdToTeams =new Map<string,Opportunity>();
        For(Opportunity tempOpp: listOfTeams){
            mapOfUserIdToTeams.put(String.valueOf(tempOpp.id),tempOpp);
        }
        return mapOfUserIdToTeams;
    }
    
    public static  Map<String,PriceBook_Record__mdt> getPriceBook()
    {
        list<PriceBook_Record__mdt> priceBookdetails=[select label,PriceBookID__c from PriceBook_Record__mdt];
        Map<String,PriceBook_Record__mdt> mapofLabeltoPricebook=new Map<String,PriceBook_Record__mdt>();
        for(PriceBook_Record__mdt pricebook:priceBookdetails){
            mapofLabeltoPricebook.put(pricebook.label,pricebook);
        }
        return mapofLabeltoPricebook;
    }
    
    public static Map<string,Teams__c> getAccountTeams(Set<id> accntId)
    {
        list<Teams__c> listOfTeams=[Select id,Name,Business_Unit__c,Account__c,Is_Primary__c,User__c,Access_Level__c from Teams__c where Access_Level__c=:OpportunityConstants.EDIT_ACCESS AND Account__c IN:accntId];
        Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
        For(Teams__c tempTeam: listOfTeams){
            mapOfUserIdToTeams.put(String.valueOF(tempTeam.User__c),tempTeam);
        }
        return mapOfUserIdToTeams;
    }
    
    public static Map<id,List<Opportunity>> getAccountId(Set<id> oppId)
    {
        list<Opportunity> listOfTeams=[Select id,Business_Unit__c,AccountId from Opportunity where Id IN:oppId];
        Map<id,List<Opportunity>> mapOfUserIdToTeams =new Map<id,List<Opportunity>>();
        For(Opportunity tempopp: listOfTeams){
            if(mapOfUserIdToTeams.containsKey(tempopp.AccountId)){
                mapOfUserIdToTeams.get(tempopp.AccountId).add(tempopp);
            }else{
                mapOfUserIdToTeams.put(tempopp.AccountId,new List<Opportunity>{tempopp});
            }
        }
        return mapOfUserIdToTeams;
    }
}