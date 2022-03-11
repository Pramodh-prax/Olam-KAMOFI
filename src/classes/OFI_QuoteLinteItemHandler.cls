// 
// Class created by Ashwini
// Last modified by Joel Tom on 01/02/2022
// 

public class OFI_QuoteLinteItemHandler {
    
    public static void checkUserAccessForInsert(list<QuoteLineItem> newQuLineItemList){
        
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(!hasCustomPermission){ 
            Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
            Map<string,Access_Set__c> mapOfproductCatToAcessset=new Map<string,Access_Set__c>();
            Map<id,QuoteLineItem> newMapOfIdtoQuLine = new Map<id,QuoteLineItem>();
            Map<id,Quote> mapOfIdtoQu=new Map<id,Quote>();
            Map<Id,PricebookEntry> mapOfIdtoPriceBookEntry=new Map<Id,PricebookEntry>();
            set<id> QuId=new set<Id>();
            set<id> AccountID=new set<Id>();
            set<id> idForPriceBookEntry=new set<Id>();
            Map<String,Opportunity_Team_Member_Role__mdt> mapofLabeltoOppTeamMemberRoleMDT=new Map<String,Opportunity_Team_Member_Role__mdt>();

            
            map<id,id> OppIdQuoteId=new map<Id,id>();
            set<id> OpportunityId = new set<id>();
            for(QuoteLineItem quLineItem:newQuLineItemList){
                QuId.add(quLineItem.QuoteId);
                idForPriceBookEntry.add(quLineItem.PriceBookEntryID);
            }
                        
            List<Quote> oli = new List<Quote>([SELECT AccountId,OpportunityId FROM Quote WHERE Id IN: quId]);    
            for(Quote o : oli){
                AccountID.add(o.AccountId);
               	OppIdQuoteId.put(o.Id,o.OpportunityId);   
                OpportunityId.add(o.OpportunityId);
            }
            
            mapOfIdtoQu=getAccIdFromQuId(QuId);
            mapOfUserIdToTeams=getAccountTeams(AccountID);
            mapOfIdtoPriceBookEntry=getProductDetailsFromPricebokentryId(idForPriceBookEntry);

            //
            //Commented by JOEL
            //Skipping the product category validation for existing Sprint 1 code in UAT
            //
            //mapOfproductCatToAcessset=getMapOfUserAccessSet(userinfo.getuserId());
            
            //Code Added by Joel Tom to validate Opp team members
            Map<Id,Map<Id,String>> oppUserRoleMap = opportunityTriggerOfiUser.fetchOppTeamMemberAndRole(OpportunityId);
            mapofLabeltoOppTeamMemberRoleMDT = opportunityTriggerOfiUser.getOppTeamMemberRoleMDT('OpportunityLineItem');
            
            for(QuoteLineItem quLineItem:newQuLineItemList){
                if(!oppUserRoleMap.isEmpty()){
                    Id quoteId =  quLineItem.QuoteId;
                    Id oppid = OppIdQuoteId.get(quoteId);
                    if(oppUserRoleMap.containskey(oppid))
                    {
                        if(!(mapofLabeltoOppTeamMemberRoleMDT.containsKey(oppUserRoleMap.get(oppid).get(userinfo.getuserId())))){
                            lineItemValidationInsert(quLineItem,mapOfUserIdToTeams,mapOfIdtoQu,mapOfproductCatToAcessset,mapOfIdtoPriceBookEntry);}       
                    }
                    else{lineItemValidationInsert(quLineItem,mapOfUserIdToTeams,mapOfIdtoQu,mapOfproductCatToAcessset,mapOfIdtoPriceBookEntry);}  
                }
                else{lineItemValidationInsert(quLineItem,mapOfUserIdToTeams,mapOfIdtoQu,mapOfproductCatToAcessset,mapOfIdtoPriceBookEntry);}            
            }
        }
    }
            
    public static void checkUserAccessForUpdate(list<QuoteLineItem> newQuLineItemList,Map<Id,QuoteLineItem> newMapOFQupLineItem,Map<Id,QuoteLineItem> oldMapOfQuLineItem){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(!hasCustomPermission){      
            Map<id,Quote> mapOfIdtoQu=new Map<id,Quote>();
            Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
            Map<string,Access_Set__c> mapOfproductCatToAcessset=new Map<string,Access_Set__c>();
            Map<id,QuoteLineItem> oldMapOfIdtoQuLine = new Map<id,QuoteLineItem>();
            Map<id,QuoteLineItem> newMapOfIdtoQuLine = new Map<id,QuoteLineItem>();
            set<id> QuId=new set<Id>();
            set<id> AccountID=new set<Id>();
        	Map<String,Opportunity_Team_Member_Role__mdt> mapofLabeltoOppTeamMemberRoleMDT=new Map<String,Opportunity_Team_Member_Role__mdt>();
            map<id,id> OppIdQuoteId=new map<Id,id>();
            set<id> OpportunityId = new set<id>();
            
            for(QuoteLineItem quLineItem:newQuLineItemList){
                QuId.add(quLineItem.QuoteId);                
            }
            
            List<Quote> oli = new List<Quote>([SELECT AccountId,OpportunityId FROM Quote WHERE Id IN: QuId]);
            for(Quote o : oli){
                AccountID.add(o.AccountId);
                OppIdQuoteId.put(o.Id,o.OpportunityId);   
                OpportunityId.add(o.OpportunityId);
            }
            
            //Code Added by Joel Tom to validate Opp team members
            Map<Id,Map<Id,String>> oppUserRoleMap = opportunityTriggerOfiUser.fetchOppTeamMemberAndRole(OpportunityId);
            mapofLabeltoOppTeamMemberRoleMDT = opportunityTriggerOfiUser.getOppTeamMemberRoleMDT('OpportunityLineItem');  
            mapOfIdtoQu=getAccIdFromQuId(quId);
            oldMapOfIdtoQuLine=getQuAndProductFromoppLine(oldMapOfQuLineItem);
            newMapOfIdtoQuLine=getQuAndProductFromoppLine(newMapOFQupLineItem);
            mapOfUserIdToTeams=getAccountTeams(AccountID);
            
            //
            //Commented by JOEL
            //Skipping the product category validation for existing Sprint 1 code in UAT
            //
            //mapOfproductCatToAcessset=getMapOfUserAccessSet(userinfo.getuserId());           
            for(QuoteLineItem quLineItem:newQuLineItemList){       
                if(!oppUserRoleMap.isEmpty()){
                    Id quoteId =  quLineItem.QuoteId;
                    Id oppid = OppIdQuoteId.get(quoteId);
                    if(oppUserRoleMap.containskey(oppid))
                    {
                        if(!(mapofLabeltoOppTeamMemberRoleMDT.containsKey(oppUserRoleMap.get(oppid).get(userinfo.getuserId())))){
                            lineItemValidationUpdate(quLineItem,mapOfUserIdToTeams,newMapOfIdtoQuLine,oldMapOfIdtoQuLine,mapOfproductCatToAcessset,mapOfIdtoQu);}        
                    }
                    else{
                        lineItemValidationUpdate(quLineItem,mapOfUserIdToTeams,newMapOfIdtoQuLine,oldMapOfIdtoQuLine,mapOfproductCatToAcessset,mapOfIdtoQu);}
                }
                else{
                    lineItemValidationUpdate(quLineItem,mapOfUserIdToTeams,newMapOfIdtoQuLine,oldMapOfIdtoQuLine,mapOfproductCatToAcessset,mapOfIdtoQu);}   
            }
        }     
    }
    
    public static void lineItemValidationInsert(QuoteLineItem quLineItem, Map<string,Teams__c> mapOfUserIdToTeams,Map<id,Quote> mapOfIdtoQu,Map<string,Access_Set__c> mapOfproductCatToAcessset, Map<Id,PricebookEntry> mapOfIdtoPriceBookEntry)
    {
        if((!mapOfUserIdToTeams.isEmpty())&& (!mapOfIdtoQu.isEmpty()) && (!mapOfIdtoPriceBookEntry.isEmpty()) /*&&(!mapOfproductCatToAcessset.isEmpty())*/){
            if((mapOfUserIdToTeams.containskey(String.ValueOF(mapOfIdtoQu.get(quLineItem.QuoteId).AccountId)+String.valueOf(userinfo.getuserId())))){
                if(mapOfUserIdToTeams.get(String.ValueOF(mapOfIdtoQu.get(quLineItem.QuoteId).AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c==mapOfIdtoPriceBookEntry.get(quLineItem.PriceBookEntryID).Product2.Business_Unit__c ||mapOfUserIdToTeams.get(String.ValueOF(mapOfIdtoQu.get(quLineItem.QuoteId).AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c==OpportunityConstants.OFI_BU_ALL){  
                    //
                    //Commented by JOEL
                    //Skipping the product category validation for existing Sprint 1 code in UAT
                    //
                    /*if(!mapOfproductCatToAcessset.isEmpty()){
                        if((mapOfproductCatToAcessset.containskey(String.valueOf(mapOfIdtoPriceBookEntry.get(quLineItem.PriceBookEntryID).Product2.Product_Category__c)+(String.valueOf(mapOfIdtoQu.get(quLineItem.QuoteId).Account.regions__c))))
                        ||((mapOfproductCatToAcessset.containskey(String.valueOf(mapOfIdtoPriceBookEntry.get(quLineItem.PriceBookEntryID).Product2.Product_Category__c)+(String.valueOf(mapOfIdtoQu.get(quLineItem.QuoteId).Account.billingcountrycode)))))
                        ||mapOfproductCatToAcessset.containskey('null'+(String.valueOf(mapOfIdtoQu.get(quLineItem.QuoteId).Account.billingcountrycode)))
                        ||mapOfproductCatToAcessset.containskey('null'+(String.valueOf(mapOfIdtoQu.get(quLineItem.QuoteId).Account.regions__c)))) 
                        {
                        }
                        else{quLineItem.addError('You have no access to this product category, region or the selected country. Please contact the administrator');}   
                        } */                                                                                                                                                                                                                                                                                                                                                                                }
                else{quLineItem.addError('You are not a part of the same business unit. Please contact the administrator');}   
            }else{quLineItem.addError('You have no permission to do this action. Please contact the administrator');}
        }else{quLineItem.addError('You are not part of this account. Please contact the administrator');} 
        
    }

    public static void lineItemValidationUpdate(QuoteLineItem quLineItem, Map<string,Teams__c> mapOfUserIdToTeams, Map<id,QuoteLineItem> newMapOfIdtoQuLine, Map<id,QuoteLineItem> oldMapOfIdtoQuLine,Map<string,Access_Set__c> mapOfproductCatToAcessset,Map<id,Quote> mapOfIdtoQu){
        
        if(!mapOfUserIdToTeams.isempty() && !newMapOfIdtoQuLine.isEmpty() && !oldMapOfIdtoQuLine.isEmpty() /* &&(!mapOfproductCatToAcessset.isEmpty()) */){
            if((mapOfUserIdToTeams.containskey(String.ValueOF(newMapOfIdtoQuLine.get(quLineItem.Id).Quote.AccountId)+String.valueOf(userinfo.getuserId())))){
                if((mapOfUserIdToTeams.get(String.ValueOF(newMapOfIdtoQuLine.get(quLineItem.Id).Quote.AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c==(oldMapOfIdtoQuLine.get(quLineItem.Id).Product2.Business_Unit__c))&&((oldMapOfIdtoQuLine.get(quLineItem.Id).Product2.Family)==(newMapOfIdtoQuLine.get(quLineItem.Id).Product2.Family)) ||mapOfUserIdToTeams.get(String.ValueOF(newMapOfIdtoQuLine.get(quLineItem.Id).Quote.AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c==OpportunityConstants.OFI_BU_ALL){
                    //
                    //Commented by JOEL
                    //Skipping the product category validation for existing Sprint 1 code in UAT
                    //
                    /*if(!mapOfproductCatToAcessset.isempty()){
                    if((mapOfproductCatToAcessset.containskey(String.valueOf(oldMapOfIdtoQuLine.get(quLineItem.Id).Product2.Product_Category__c)+(String.valueOf(mapOfIdtoQu.get(quLineItem.QuoteId).Account.regions__c))))
                    ||((mapOfproductCatToAcessset.containskey(String.valueOf(oldMapOfIdtoQuLine.get(quLineItem.Id).Product2.Product_Category__c)+(String.valueOf(mapOfIdtoQu.get(quLineItem.QuoteId).Account.billingcountrycode)))))
                    ||mapOfproductCatToAcessset.containskey('null'+(String.valueOf(mapOfIdtoQu.get(quLineItem.QuoteId).Account.billingcountrycode)))
                    ||mapOfproductCatToAcessset.containskey('null'+(String.valueOf(mapOfIdtoQu.get(quLineItem.QuoteId).Account.regions__c))))
                    {
                    }
                    else{quLineItem.addError('You have no access to this product category, region or the selected country. Please contact the administrator');}   
                    }*/
                }else{quLineItem.addError('You are not a part of the same business unit. Please contact the administrator');}   
            }else{quLineItem.addError('You have no permission to do this action. Please contact the administrator');}
        }else{quLineItem.addError('You are not part of this account. Please contact the administrator');} 
    }
    
   /* public static  Map<string,Access_Set__c> getMapOfUserAccessSet(id userId){
        List<Access_Set_Assignment__c> listOfAccessSetAssgnmnt= new List<Access_Set_Assignment__c>();
        set<id> idOfUserAcessSet=new set<id>();
        Map<string,Access_Set__c> mapOfproductCatToAcessset=new Map<string,Access_Set__c>();
        
        listOfAccessSetAssgnmnt=[Select Id,Access_Set__c,User__c,Account_Teams_Creation_Status__c 
                                 from Access_Set_Assignment__c 
                                 where User__c =:userId];
        for(Access_Set_Assignment__c accessSetAssgnments:listOfAccessSetAssgnmnt)
        {
            idOfUserAcessSet.add(accessSetAssgnments.Access_Set__c);
        }
        
        List<Access_Set__c> listOfUserAccessSet = [Select Id,Name,Region__c,Country__c,Customer_Group__c,Channel__c,Product_Category__c from Access_Set__c where Id IN: idOfUserAcessSet];
        
        for(Access_Set__c UserAccessSet:listOfUserAccessSet)
        {
            if(UserAccessSet.Country__c!=null){ 
                mapOfproductCatToAcessset.put(String.valueof(UserAccessSet.Product_Category__c)+String.valueOf(UserAccessSet.Country__c),UserAccessSet);
            }else{
                mapOfproductCatToAcessset.put(String.valueof(UserAccessSet.Product_Category__c)+String.valueOf(UserAccessSet.Region__c),UserAccessSet);        
            } 
        }
        return mapOfproductCatToAcessset; 
    }*/
    
    public static Map<id,QuoteLineItem> getQuAndProductFromoppLine(Map<id,QuoteLineItem> mapOfQuLine){
        Map<id,QuoteLineItem> mapOfIdtoOppLine = new Map<id,QuoteLineItem>([SELECT Quote.AccountId,Product2.Product_Category__c, Product2.Family, Product2.Business_Unit__c FROM QuoteLineItem WHERE Id IN: mapOfQuLine.keySet()]); 
        return mapOfIdtoOppLine;
    }
    
    public static Map<id,Quote> getAccIdFromQuId(set<id> QuId){
        Map<id,Quote> mapOfIdtoOpp=new Map<id,Quote>([SELECT Id, Name, AccountId,Account.billingcountrycode,Account.regions__c FROM Quote WHERE Id IN:QuId]);
        return mapOfIdtoOpp;
    }
    
    public static Map<id,PricebookEntry> getProductDetailsFromPricebokentryId(set<id> idForPriceBookEntry){
        Map<id,PricebookEntry> mapOfIdtoPriceBookEntry=new Map<id,PricebookEntry>([SELECT Id, Name,Product2.Product_Category__c, Product2.Family, Product2.Business_Unit__c  FROM PricebookEntry WHERE Id IN:idForPriceBookEntry]);
        return mapOfIdtoPriceBookEntry;
    }
    public static Map<string,Teams__c> getAccountTeams(Set<id> accntId)
    {
        list<Teams__c> listOfTeams=[Select id,Name,Business_Unit__c,Account__c,Is_Primary__c,User__c,Access_Level__c from Teams__c where Access_Level__c=:OpportunityConstants.EDIT_ACCESS AND Account__c IN:accntId];
        Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
        For(Teams__c tempTeam: listOfTeams){
            mapOfUserIdToTeams.put(String.valueOf(tempTeam.Account__c) + String.valueOF(tempTeam.User__c),tempTeam);
        }
        return mapOfUserIdToTeams;
    }
    
}