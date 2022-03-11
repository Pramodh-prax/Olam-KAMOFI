// 
// Class created by Punam
// Last modified by Joel Tom on 01/02/2022
// 

public class OFI_OpportunityLineItemHandler {
    
    public static void checkUserAccessForInsert(list<OpportunityLineItem> newOppLineItemList){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(!hasCustomPermission  && userInfo.getName() != System.Label.Automated_Process){
            User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
            Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
            Map<string,Access_Set__c> mapOfproductCatToAcessset=new Map<string,Access_Set__c>();
            Map<id,OpportunityLineItem> newMapOfIdtoOppLine = new Map<id,OpportunityLineItem>();
            Map<id,Opportunity> mapOfIdtoOpp=new Map<id,Opportunity>();
            Map<Id,PricebookEntry> mapOfIdtoPriceBookEntry=new Map<Id,PricebookEntry>();
            Map<String,Opportunity_Team_Member_Role__mdt> mapofLabeltoOppTeamMemberRoleMDT=new Map<String,Opportunity_Team_Member_Role__mdt>();
            set<id> OppId=new set<Id>();
            set<id> AccountID=new set<Id>();
            set<id> idForPriceBookEntry=new set<Id>();
            
            for(OpportunityLineItem oppLineItem:newOppLineItemList){
                OppId.add(oppLineItem.OpportunityId);
                idForPriceBookEntry.add(oppLineItem.PriceBookEntryID);
            }
            
            //Code Added by Joel Tom to validate Opp team members
            Map<Id,Map<Id,String>> oppUserRoleMap = opportunityTriggerOfiUser.fetchOppTeamMemberAndRole(OppId);
            
            List<Opportunity> oli = new List<Opportunity>([SELECT AccountId FROM Opportunity WHERE Id IN: OppId]);
            for(Opportunity o : oli){
                AccountID.add(o.AccountId);
            }
            
            //
            //Commented by JOEL
            //Skipping the product category validation for existing Sprint 1 code in UAT
            //
            //mapOfproductCatToAcessset=getMapOfUserAccessSet(u.Id);
            mapOfIdtoPriceBookEntry=getProductDetailsFromPricebokentryId(idForPriceBookEntry);
            mapOfUserIdToTeams=opportunityTriggerOfiUser.getAccountTeams(AccountID);    
            mapOfIdtoOpp=getAccIdFromOppId(OppId);
            mapofLabeltoOppTeamMemberRoleMDT = opportunityTriggerOfiUser.getOppTeamMemberRoleMDT('OpportunityLineItem');
            
            for(OpportunityLineItem oppLineItem:newOppLineItemList){
                if(!oppUserRoleMap.isEmpty()){
                    if(oppUserRoleMap.containskey(oppLineItem.OpportunityId)){
                        if(!(mapofLabeltoOppTeamMemberRoleMDT.containsKey(oppUserRoleMap.get(oppLineItem.OpportunityId).get(u.Id)))){
                            lineItemValidationInsert(oppLineItem,mapOfUserIdToTeams,mapOfIdtoOpp,mapOfproductCatToAcessset,mapOfIdtoPriceBookEntry);
                        }
                    }  
                    else{
                        lineItemValidationInsert(oppLineItem,mapOfUserIdToTeams,mapOfIdtoOpp,mapOfproductCatToAcessset,mapOfIdtoPriceBookEntry);
                    }
                }
                else{
                    lineItemValidationInsert(oppLineItem,mapOfUserIdToTeams,mapOfIdtoOpp,mapOfproductCatToAcessset,mapOfIdtoPriceBookEntry);
                }                       
            }
        } 
    }
    
    public static void checkUserAccessForUpdate(list<OpportunityLineItem> newOppLineItemList,Map<Id,OpportunityLineItem> newMapOFOppLineItem,Map<Id,OpportunityLineItem> oldMapOfOppLineItem){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(!hasCustomPermission && userInfo.getName() != System.Label.Automated_Process){   
            User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
            Map<id,Opportunity> mapOfIdtoOpp=new Map<id,Opportunity>();
            Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
            Map<string,Access_Set__c> mapOfproductCatToAcessset=new Map<string,Access_Set__c>();
            Map<id,OpportunityLineItem> oldMapOfIdtoOppLine = new Map<id,OpportunityLineItem>();
            Map<id,OpportunityLineItem> newMapOfIdtoOppLine = new Map<id,OpportunityLineItem>();
            Map<String,Opportunity_Team_Member_Role__mdt> mapofLabeltoOppTeamMemberRoleMDT=new Map<String,Opportunity_Team_Member_Role__mdt>();

            set<id> OppId=new set<Id>();
            set<id> AccountID=new set<Id>();
            for(OpportunityLineItem oppLineItem:newOppLineItemList){
                OppId.add(oppLineItem.OpportunityId);          
            }
            
            //Code Added by Joel Tom to validate Opp team members
            Map<Id,Map<Id,String>> oppUserRoleMap = opportunityTriggerOfiUser.fetchOppTeamMemberAndRole(OppId);
            
            List<Opportunity> oli = new List<Opportunity>([SELECT AccountId FROM Opportunity WHERE Id IN: OppId]);
            for(Opportunity o : oli){
                AccountID.add(o.AccountId);
            }
            
            //
            //Commented by JOEL
            //Skipping the product category validation for existing Sprint 1 code in UAT
            //
            //mapOfproductCatToAcessset=getMapOfUserAccessSet(u.Id);
            mapOfIdtoOpp=OFI_OpportunityLineItemHandler.getAccIdFromOppId(OppId);
            oldMapOfIdtoOppLine=getOppAndProductFromoppLine(oldMapOfOppLineItem);
            newMapOfIdtoOppLine=getOppAndProductFromoppLine(newMapOFOppLineItem);
            mapOfUserIdToTeams=opportunityTriggerOfiUser.getAccountTeams(AccountID);
            mapofLabeltoOppTeamMemberRoleMDT = opportunityTriggerOfiUser.getOppTeamMemberRoleMDT('OpportunityLineItem');
            
            for(OpportunityLineItem oppLineItem:newOppLineItemList){
                if(!oppUserRoleMap.isEmpty()){
                    if(oppUserRoleMap.containskey(oppLineItem.OpportunityId)){
                        if(!(mapofLabeltoOppTeamMemberRoleMDT.containsKey(oppUserRoleMap.get(oppLineItem.OpportunityId).get(u.Id)))){
                            lineItemValidationUpdate(oppLineItem,mapOfUserIdToTeams,newMapOfIdtoOppLine,oldMapOfIdtoOppLine,mapOfproductCatToAcessset,mapOfIdtoOpp);
                        }     
                    }  
                    else{
                        lineItemValidationUpdate(oppLineItem,mapOfUserIdToTeams,newMapOfIdtoOppLine,oldMapOfIdtoOppLine,mapOfproductCatToAcessset,mapOfIdtoOpp);}
                }
                else{
                    lineItemValidationUpdate(oppLineItem,mapOfUserIdToTeams,newMapOfIdtoOppLine,oldMapOfIdtoOppLine,mapOfproductCatToAcessset,mapOfIdtoOpp);}
            }
        }
    }
    
    //
    //
    //TO BE CONFIRMED - COMMENT THESE BELOW 2 METHODS FOR SKIPPING THE LINEITEM VALIDATION
    //
    //
    public static void lineItemValidationInsert(OpportunityLineItem oppLineItem, Map<string,Teams__c> mapOfUserIdToTeams,Map<id,Opportunity> mapOfIdtoOpp,Map<string,Access_Set__c> mapOfproductCatToAcessset, Map<Id,PricebookEntry> mapOfIdtoPriceBookEntry){
        if((!mapOfUserIdToTeams.isEmpty())&& (!mapOfIdtoOpp.isEmpty()) && (!mapOfIdtoPriceBookEntry.isEmpty())/* &&(!mapOfproductCatToAcessset.isEmpty())*/){
            if((mapOfUserIdToTeams.containskey(String.ValueOF(mapOfIdtoOpp.get(oppLineItem.OpportunityId).AccountId)+String.valueOf(userinfo.getuserId())))){
                if(mapOfUserIdToTeams.get(String.ValueOF(mapOfIdtoOpp.get(oppLineItem.OpportunityId).AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c==mapOfIdtoPriceBookEntry.get(oppLineItem.PriceBookEntryID).Product2.Business_Unit__c || mapOfUserIdToTeams.get(String.ValueOF(mapOfIdtoOpp.get(oppLineItem.OpportunityId).AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c==OpportunityConstants.OFI_BU_ALL){
                   	//
                   	//Commented by JOEL
                   	//Skipping the product category validation for existing Sprint 1 code in UAT
                   	// 
                    /* if(!mapOfproductCatToAcessset.isEmpty()){
                        if(!(mapOfUserIdToTeams.get(String.ValueOF(mapOfIdtoOpp.get(oppLineItem.OpportunityId).AccountId)+String.valueOf(userinfo.getuserId())).Access_Set_Role__c=='Sales')){  
                            if((mapOfproductCatToAcessset.containskey(String.valueOf(mapOfIdtoPriceBookEntry.get(oppLineItem.PriceBookEntryID).Product2.Product_Category__c)+(String.valueOf(mapOfIdtoOpp.get(oppLineItem.OpportunityId).Account.regions__c))))
                               ||((mapOfproductCatToAcessset.containskey(String.valueOf(mapOfIdtoPriceBookEntry.get(oppLineItem.PriceBookEntryID).Product2.Product_Category__c)+(String.valueOf(mapOfIdtoOpp.get(oppLineItem.OpportunityId).Account.billingcountrycode)))))
                               ||mapOfproductCatToAcessset.containskey('null'+(String.valueOf(mapOfIdtoOpp.get(oppLineItem.OpportunityId).Account.billingcountrycode)))
                               ||mapOfproductCatToAcessset.containskey('null'+(String.valueOf(mapOfIdtoOpp.get(oppLineItem.OpportunityId).Account.regions__c))))    
                            {
                            }
                            else{oppLineItem.addError('You have no access to this product category, region or the selected country. Please contact the administrator');}   
                        }
                    }*/
                }
                else{oppLineItem.addError('You are not a part of the same business unit. Please contact the administrator');}       
            }
            else{oppLineItem.addError('You have no permission to do this action. Please contact the administrator');} 
        }
        else{oppLineItem.addError('You are not part of this account. Please contact the administrator');}
    }
    
    public static void lineItemValidationUpdate(OpportunityLineItem oppLineItem, Map<string,Teams__c> mapOfUserIdToTeams, Map<id,OpportunityLineItem> newMapOfIdtoOppLine, Map<id,OpportunityLineItem> oldMapOfIdtoOppLine,Map<string,Access_Set__c> mapOfproductCatToAcessset,Map<id,Opportunity> mapOfIdtoOpp){
        if(!mapOfUserIdToTeams.isempty() && !newMapOfIdtoOppLine.isEmpty() && !oldMapOfIdtoOppLine.isEmpty()/*&&(!mapOfproductCatToAcessset.isEmpty())*/){
            if((mapOfUserIdToTeams.containskey(String.ValueOF(newMapOfIdtoOppLine.get(oppLineItem.Id).Opportunity.AccountId)+String.valueOf(userinfo.getuserId())))){
                if((mapOfUserIdToTeams.get(String.ValueOF(newMapOfIdtoOppLine.get(oppLineItem.Id).Opportunity.AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c==(oldMapOfIdtoOppLine.get(oppLineItem.Id).Product2.Business_Unit__c))&&((oldMapOfIdtoOppLine.get(oppLineItem.Id).Product2.Family)==(newMapOfIdtoOppLine.get(oppLineItem.Id).Product2.Family)) ||mapOfUserIdToTeams.get(String.ValueOF(newMapOfIdtoOppLine.get(oppLineItem.Id).Opportunity.AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c==OpportunityConstants.OFI_BU_ALL){
                  	//
                   	//Commented by JOEL
                   	//Skipping the product category validation for existing Sprint 1 code in UAT
                   	//
                    /* if(!mapOfproductCatToAcessset.isempty()){
                        if(!(mapOfUserIdToTeams.get(String.ValueOF(mapOfIdtoOpp.get(oppLineItem.OpportunityId).AccountId)+String.valueOf(userinfo.getuserId())).Access_Set_Role__c=='Sales')){      
                            if((mapOfproductCatToAcessset.containskey(String.valueOf(oldMapOfIdtoOppLine.get(oppLineItem.Id).Product2.Product_Category__c)+(String.valueOf(mapOfIdtoOpp.get(oppLineItem.OpportunityId).Account.regions__c))))
                               ||((mapOfproductCatToAcessset.containskey(String.valueOf(oldMapOfIdtoOppLine.get(oppLineItem.Id).Product2.Product_Category__c)+(String.valueOf(mapOfIdtoOpp.get(oppLineItem.OpportunityId).Account.billingcountrycode)))))
                               ||mapOfproductCatToAcessset.containskey('null'+(String.valueOf(mapOfIdtoOpp.get(oppLineItem.OpportunityId).Account.billingcountrycode)))
                               ||mapOfproductCatToAcessset.containskey('null'+(String.valueOf(mapOfIdtoOpp.get(oppLineItem.OpportunityId).Account.regions__c))))   
                            {
                            }
                            else{oppLineItem.addError('You have no access to this product category, region or the selected country. Please contact the administrator');}   
                        }
                    }*/
                }
                else{oppLineItem.addError('You are not a part of the same business unit. Please contact the administrator');}    
            }
            else{oppLineItem.addError('You have no permission to do this action. Please contact the administrator');} 
        }
        else{oppLineItem.addError('You are not part of this account. Please contact the administrator');} 
    }
    
    /*
    public static  Map<string,Access_Set__c> getMapOfUserAccessSet(id userId){
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
    }
    */
        
    public static Map<id,OpportunityLineItem> getOppAndProductFromoppLine(Map<id,OpportunityLineItem> mapOfOppLine){
        Map<id,OpportunityLineItem> mapOfIdtoOppLine = new Map<id,OpportunityLineItem>([SELECT Opportunity.AccountId,Product2.Product_Category__c, Product2.Family, Product2.Business_Unit__c FROM OpportunityLineItem WHERE Id IN: mapOfOppLine.keySet()]); 
        return mapOfIdtoOppLine;
    }
    
    public static Map<id,Opportunity> getAccIdFromOppId(set<id> OppId){
        Map<id,opportunity> mapOfIdtoOpp=new Map<id,opportunity>([SELECT Id, Name, AccountId,Account.billingcountrycode,Account.regions__c FROM Opportunity WHERE Id IN:OppId]);
        return mapOfIdtoOpp;
    }
    
    public static Map<id,PricebookEntry> getProductDetailsFromPricebokentryId(set<id> idForPriceBookEntry){
        Map<id,PricebookEntry> mapOfIdtoPriceBookEntry=new Map<id,PricebookEntry>([SELECT Id, Name,Product2.Product_Category__c, Product2.Family, Product2.Business_Unit__c FROM PricebookEntry WHERE Id IN:idForPriceBookEntry]);
        return mapOfIdtoPriceBookEntry;  
    }
    
}