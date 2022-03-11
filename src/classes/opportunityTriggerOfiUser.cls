// 
// Class created by Punam
// Last modified by Joel Tom on 24/01/2022
// 

public class opportunityTriggerOfiUser {
    
    public static void checkUserAccess(list<opportunity> oppList)
    {     
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(!hasCustomPermission && userInfo.getName() != System.Label.Automated_Process){
            User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
            Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
            Map<String,PriceBook_Record__mdt> mapofLabeltoPricebook=new Map<String,PriceBook_Record__mdt>();
            
            Set<id> AccountIds = new Set<id>();
            for(opportunity opp:oppList)
            { 
                AccountIds.add(opp.AccountId);
            }
            
            mapOfUserIdToTeams=opportunityTriggerOfiUser.getAccountTeams(AccountIds);
            mapofLabeltoPricebook=opportunityTriggerOfiUser.getPriceBook();
            for(opportunity opp:oppList)
            {
                if(opp.RecordTypeId==OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID 
                   || opp.RecordTypeId==OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID 
                   || opp.RecordTypeId==OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID 
                   || opp.RecordTypeId==OpportunityConstants.PRESENT_OPPORTUNITY_RECORD_TYPE_ID 
                   || opp.RecordTypeId==OpportunityConstants.SERVICE_OPPORTUNITY_RECORD_TYPE_ID
                   || opp.RecordTypeId==OpportunityConstants.TENDERING_OPPORTUNITY_RECORD_TYPE_ID)
                {
                    String BU;
                    boolean isAccountTeam=false;
                    if(!mapOfUserIdToTeams.isempty()){
                        if((mapOfUserIdToTeams.containskey(String.ValueOF(opp.AccountId)+String.valueOf(u.Id)))){
                            BU=mapOfUserIdToTeams.get(String.ValueOF(opp.AccountId)+String.valueOf(u.Id)).Business_Unit__c;
                            isAccountTeam=true;
                            
                            if(!mapofLabeltoPricebook.isEmpty()){ 
                                PriceBook_Record__mdt pr1=mapofLabeltoPricebook.get(BU);
                                if(BU != OpportunityConstants.OFI_BU_ALL){
                                    opp.Pricebook2Id=pr1.PriceBookID__c;
                                }
                                else{
                                    if(opp.Business_Unit__c!=null){
                                        PriceBook_Record__mdt pr2=mapofLabeltoPricebook.get(opp.Business_Unit__c);
                                        opp.Pricebook2Id=pr2.PriceBookID__c;
                                    }
                                    else{
                                        opp.Business_Unit__c.addError('Please Select the Business Unit'); 
                                    }
                                }   
                            }
                        }else{
                            opp.addError(system.label.OFI_Opportunity_Create_Error_Msg);
                        }
                    }
                    else{ opp.addError(system.label.OFI_Opportunity_Create_Error_Msg);}
                    
                    if(isAccountTeam==true){
                        if(BU!=OpportunityConstants.OFI_BU_ALL && opp.RecordTypeId==OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID){    
                            if(opp.Business_Unit__c==null){
                                opp.Business_Unit__c = BU;   
                            }
                            if(opp.Business_Unit__c!=BU && opp.RecordTypeId==OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID){
                                opp.Business_Unit__c.addError(system.label.OFI_OpportunityField_Create_Error_Msg+' : '+BU);
                            }	
                        }   
                        if(BU==OpportunityConstants.OFI_BU_ALL && (opp.RecordTypeId==OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID 
                                                                   || opp.RecordTypeId==OpportunityConstants.PRESENT_OPPORTUNITY_RECORD_TYPE_ID 
                                                                   || opp.RecordTypeId==OpportunityConstants.SERVICE_OPPORTUNITY_RECORD_TYPE_ID
                                                                   || opp.RecordTypeId==OpportunityConstants.TENDERING_OPPORTUNITY_RECORD_TYPE_ID
                                                                   || opp.RecordTypeId==OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID))
                        {
                            
                            if(opp.Business_Unit__c == null || opp.Business_Unit__c == OpportunityConstants.OFI_BU_ALL){
                                opp.Business_Unit__c.addError('Please Select the Business Unit');
                            }
                        }
                        else{
                            if(BU!=OpportunityConstants.OFI_BU_ALL && (opp.RecordTypeId==OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID 
                                                                       || opp.RecordTypeId==OpportunityConstants.PRESENT_OPPORTUNITY_RECORD_TYPE_ID 
                                                                       || opp.RecordTypeId==OpportunityConstants.SERVICE_OPPORTUNITY_RECORD_TYPE_ID
                                                                       || opp.RecordTypeId==OpportunityConstants.TENDERING_OPPORTUNITY_RECORD_TYPE_ID
                                                                       || opp.RecordTypeId==OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID))
                            {
                                if(opp.Business_Unit__c==null){
                                    opp.Business_Unit__c = BU;   
                                }      
                            }
                            if(opp.Business_Unit__c!=BU && (opp.RecordTypeId==OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID 
                                                            || opp.RecordTypeId==OpportunityConstants.PRESENT_OPPORTUNITY_RECORD_TYPE_ID 
                                                            || opp.RecordTypeId==OpportunityConstants.SERVICE_OPPORTUNITY_RECORD_TYPE_ID
                                                            || opp.RecordTypeId==OpportunityConstants.TENDERING_OPPORTUNITY_RECORD_TYPE_ID
                                                            || opp.RecordTypeId==OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID))
                            {
                                opp.Business_Unit__c.addError(system.label.OFI_OpportunityField_Create_Error_Msg+' : '+BU);
                            }  
                        }
                    }
                }
                else{ opp.addError(system.label.OFI_Opportunity_Create_Error_Msg); }  
            }     
        }
    }
    
    public static void checkUserAccessForUpdateOpp(list<opportunity> newoppList,Map<Id,Opportunity> oldMapOfOpp)
    {
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Set_Admins');
        if(!hasCustomPermission && userInfo.getName() != System.Label.Automated_Process){
            User u=[Select Id,Name,Email,BU_Identifier__c,UserRole.Name from User where Id=:userinfo.getuserId()];
            Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
            Map<String,PriceBook_Record__mdt> mapofLabeltoPricebook=new Map<String,PriceBook_Record__mdt>();
            Map<String,Opportunity_Team_Member_Role__mdt> mapofLabeltoOppTeamMemberRoleMDT=new Map<String,Opportunity_Team_Member_Role__mdt>();
            Set<id> AccountIds = new Set<id>();
            Set<id> OppId=new set<Id>();
            for(opportunity opp:newoppList)
            {
                AccountIds.add(opp.AccountId);
                OppId.add(opp.Id);
            }
            
            //Code Added by Joel Tom to validate Opp team members
            Map<Id,Map<Id,String>> oppUserRoleMap = fetchOppTeamMemberAndRole(OppId);
            
            mapOfUserIdToTeams=opportunityTriggerOfiUser.getAccountTeams(AccountIds);
            mapofLabeltoPricebook=opportunityTriggerOfiUser.getPriceBook();
            mapofLabeltoOppTeamMemberRoleMDT = getOppTeamMemberRoleMDT('Opportunity');
            
            for(opportunity opp:newoppList)
            { 
                if(!oppUserRoleMap.isEmpty() && (opp.RecordTypeId==OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID || opp.RecordTypeId==OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID || opp.RecordTypeId==OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID )){
                    if(oppUserRoleMap.containskey(opp.Id)){    
                        if(!(mapofLabeltoOppTeamMemberRoleMDT.containsKey(oppUserRoleMap.get(opp.Id).get(userinfo.getuserId())))){
                            validateAccountTeamUserAccessOnUpdate(opp,mapOfUserIdToTeams, mapofLabeltoPricebook,oldMapOfOpp);
                        }
                    }
                    else{validateAccountTeamUserAccessOnUpdate(opp,mapOfUserIdToTeams, mapofLabeltoPricebook,oldMapOfOpp);} 
                }
                else{validateAccountTeamUserAccessOnUpdate(opp,mapOfUserIdToTeams, mapofLabeltoPricebook,oldMapOfOpp);} 
            }
        }   
    }
    
    //Method Added by Joel Tom to validate the Opp team members user access
    public static void validateAccountTeamUserAccessOnUpdate(opportunity opp, Map<string,Teams__c> mapOfUserIdToTeams, Map<String,PriceBook_Record__mdt> mapofLabeltoPricebook, Map<Id,Opportunity> oldMapOfOpp){
        if(opp.RecordTypeId==OpportunityConstants.GAIN_OPPORTUNITY_RECORD_TYPE_ID 
           || opp.RecordTypeId==OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID 
           || opp.RecordTypeId==OpportunityConstants.PRESENT_OPPORTUNITY_RECORD_TYPE_ID 
           || opp.RecordTypeId==OpportunityConstants.SERVICE_OPPORTUNITY_RECORD_TYPE_ID
           || opp.RecordTypeId==OpportunityConstants.TENDERING_OPPORTUNITY_RECORD_TYPE_ID
           || opp.RecordTypeId==OpportunityConstants.DEVELOP_OPPORTUNITY_RECORD_TYPE_ID )
        {
            String BU;
            boolean isAccountTeam=false;
            if(!mapOfUserIdToTeams.isempty()){
                if((mapOfUserIdToTeams.containskey(String.ValueOF(opp.AccountId)+String.valueOf(userinfo.getuserId())))){
                    BU=mapOfUserIdToTeams.get(String.ValueOF(opp.AccountId)+String.valueOf(userinfo.getuserId())).Business_Unit__c;
                    isAccountTeam=true;
                    PriceBook_Record__mdt pr1=mapofLabeltoPricebook.get(BU);
                    if(BU != OpportunityConstants.OFI_BU_ALL){
                        opp.Pricebook2Id=pr1.PriceBookID__c;
                    }
                    else{
                        PriceBook_Record__mdt pr2=mapofLabeltoPricebook.get(opp.Business_Unit__c);
                        opp.Pricebook2Id=pr2.PriceBookID__c;
                    }   
                } 
            }
            else{ opp.addError(system.label.OFI_Opportunity_Create_Error_Msg);}
            
            if(isAccountTeam==true){
                if((BU==OpportunityConstants.OFI_BU_ALL) || ((oldMapOfOpp.get(opp.id).Business_Unit__c==BU) && (oldMapOfOpp.get(opp.id).Business_Unit__c==opp.Business_Unit__c) )){ 
                }
                else{opp.addError(system.label.OFI_Opportunity_Create_Error_Msg);}  
            }
            else{opp.addError(system.label.OFI_Opportunity_Create_Error_Msg);}
        }
    }
    
    //Method Added by Joel Tom to get the Opp team members
    public static Map<Id,Map<Id,String>> fetchOppTeamMemberAndRole(Set<Id> OppId){
        Map<Id,Map<Id,String>> oppUserRoleMap = new Map<Id,Map<Id,String>>();
        List <OpportunityTeamMember> oppTeamMembersList = [Select UserId, TeamMemberRole, OpportunityId from OpportunityTeamMember where OpportunityId IN:OppId];
        for(OpportunityTeamMember oppTeamItem:oppTeamMembersList){
            if(oppUserRoleMap.containsKey(oppTeamItem.OpportunityId)){
                oppUserRoleMap.get(oppTeamItem.OpportunityId).put(oppTeamItem.UserId ,oppTeamItem.TeamMemberRole);
            }
            else{
                oppUserRoleMap.put(oppTeamItem.OpportunityId, new Map<Id,String>{oppTeamItem.UserId => oppTeamItem.TeamMemberRole});
            }  
        }
        return oppUserRoleMap;
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
        list<Teams__c> listOfTeams=[Select id,Name,Business_Unit__c,Account__c,Is_Primary__c,User__c,Access_Level__c /*,Access_Set_Role__c*/ from Teams__c where Access_Level__c=:OpportunityConstants.EDIT_ACCESS AND Account__c IN:accntId];
        Map<string,Teams__c> mapOfUserIdToTeams =new Map<string,Teams__c>();
        For(Teams__c tempTeam: listOfTeams){
            mapOfUserIdToTeams.put(String.valueOf(tempTeam.Account__c) + String.valueOF(tempTeam.User__c),tempTeam);
        }
        return mapOfUserIdToTeams;
    }
    
    public static  Map<String,Opportunity_Team_Member_Role__mdt> getOppTeamMemberRoleMDT(String ObjectName)
    {
        list<Opportunity_Team_Member_Role__mdt> OppTeamMemberRole=[select label,Opportunity_Role__c from Opportunity_Team_Member_Role__mdt where Object_Name__c =:ObjectName];
        Map<String,Opportunity_Team_Member_Role__mdt> mapofLabeltoOppTeamMemberRole=new Map<String,Opportunity_Team_Member_Role__mdt>();
        for(Opportunity_Team_Member_Role__mdt role:OppTeamMemberRole){
            mapofLabeltoOppTeamMemberRole.put(role.Opportunity_Role__c,role);
        }
        return mapofLabeltoOppTeamMemberRole;
    }
    
}