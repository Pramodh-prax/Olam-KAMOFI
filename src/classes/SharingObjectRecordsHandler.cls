public class SharingObjectRecordsHandler {
    
    Public static void shareOpportunitiesWithAccountTeams(Map<Id,Opportunity> mapOfNewRecords){
        if(!mapOfNewRecords.isEmpty()){
            
            Set<Id> setOfAccountIds = new Set<Id>();
            Set<String> setOfBUs = new Set<String>{SharingUtility.BU_ALL}; //The records needs to be shared with team users with BU as "All" irrespective of BU value
                
                //Construct setOfAccountIds and setOfBUs
                for(Opportunity opp : mapOfNewRecords.values()){
                    if(opp.AccountId != Null && !setOfAccountIds.contains(opp.AccountId)){
                        setOfAccountIds.add(opp.AccountId);
                    }
                    if(String.isNotBlank(opp.Business_Unit__c) && !setOfBUs.contains(opp.Business_Unit__c)){
                        setOfBUs.add(opp.Business_Unit__c);
                    }
                }
            
            if(!setOfAccountIds.isEmpty() && !setOfBUs.isEmpty()){
                //Use setOfAccountIds and setOfBUs to query the Teams with matching BUs
                //Map<AccId, Map<BU,List<Team Rec>>
                Map<Id, Map<String,List<Teams__c>>> mapOfAccIdWithMapOfBUAndTeamsList = SharingUtility.getTeamsWithAccountAndBUs(setOfAccountIds,setOfBUs);
                
                if(!mapOfAccIdWithMapOfBUAndTeamsList.isEmpty()){
                    
                    List<SObject> listOfShareRecordsToInsert = new List<SObject>();
                    map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel = new map<Id, Map<Id,String>>();
                    
                    //Iterate to create the map of records to be shared with users with the access Level based on the team user's Access Level/Primary
                    for(Opportunity opp : mapOfNewRecords.values()){
                        if(opp.AccountId != Null && String.isNotBlank(opp.Business_Unit__c)){
                            if(mapOfAccIdWithMapOfBUAndTeamsList.containsKey(opp.AccountId)){
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(opp.AccountId).containsKey(opp.Business_Unit__c)){
                                    //There are account team records with the same BU
                                    //This record Id should be shared with the list of team records matching interaction.Business_Unit__c
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(opp.Id,opp.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(opp.AccountId).get(opp.Business_Unit__c),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(opp.AccountId).containsKey(SharingUtility.BU_ALL)){
                                    //There are account team records with the BU as "All"
                                    //This record Id should also be shared with the list of team records with Business_Unit__c as "All"
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(opp.Id,opp.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(opp.AccountId).get(SharingUtility.BU_ALL),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                            }
                        }
                    } 
                    
                    if(!mapOfRecordIdWithUserIdsNAccessLevel.isEmpty()){
                        
                        //Create the sharing wrapper to use for creating the sharing records later
                        
                        SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('opportunity');
                        wrapper.rowCause = SharingUtility.MANUAL_ROWCAUSE; //'Manual' as row cause for standard object
                        wrapper.mapOfRecordIdWithUserIdsNAccessLevel = mapOfRecordIdWithUserIdsNAccessLevel;
                        
                        //Create the sharing records
                        listOfShareRecordsToInsert = SharingUtility.createSharingRecords(wrapper);
                        
                        if(!listOfShareRecordsToInsert.isEmpty()){
                            insert listOfShareRecordsToInsert; //Partial success needed? or try catch needed ?
                            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                        }
                    }
                }
            }
        }
    }
    
    Public static void shareInteractionsWithAccountTeams(Map<Id,Interactions__c> mapOfNewRecords){
        if(!mapOfNewRecords.isEmpty()){
            
            Set<Id> setOfAccountIds = new Set<Id>();
            Set<String> setOfBUs = new Set<String>{SharingUtility.BU_ALL}; //The records needs to be shared with team users with BU as "All" irrespective of BU value
                
                //Construct setOfAccountIds and setOfBUs
                for(Interactions__c interaction: mapOfNewRecords.values()){
                    if(interaction.Account__c != Null && !setOfAccountIds.contains(interaction.Account__c)){
                        setOfAccountIds.add(interaction.Account__c);
                    }
                    if(String.isNotBlank(interaction.Business_Unit__c) && !setOfBUs.contains(interaction.Business_Unit__c)){
                        setOfBUs.add(interaction.Business_Unit__c);
                    }
                }
            
            if(!setOfAccountIds.isEmpty() && !setOfBUs.isEmpty()){
                //Use setOfAccountIds and setOfBUs to query the Teams with matching BUs
                //Map<AccId, Map<BU,List<Team Rec>>
                Map<Id, Map<String,List<Teams__c>>> mapOfAccIdWithMapOfBUAndTeamsList = SharingUtility.getTeamsWithAccountAndBUs(setOfAccountIds,setOfBUs);
                
                if(!mapOfAccIdWithMapOfBUAndTeamsList.isEmpty()){
                    
                    List<SObject> listOfShareRecordsToInsert = new List<SObject>();
                    map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel = new map<Id, Map<Id,String>>();
                    
                    //Iterate to create the map of records to be shared with users with the access Level based on the team user's Access Level/Primary
                    for(Interactions__c interaction: mapOfNewRecords.values()){
                        if(interaction.Account__c != Null && String.isNotBlank(interaction.Business_Unit__c)){
                            if(mapOfAccIdWithMapOfBUAndTeamsList.containsKey(interaction.Account__c)){
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(interaction.Account__c).containsKey(interaction.Business_Unit__c)){
                                    //There are account team records with the same BU
                                    //This record Id should be shared with the list of team records matching interaction.Business_Unit__c
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(interaction.Id,interaction.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(interaction.Account__c).get(interaction.Business_Unit__c),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(interaction.Account__c).containsKey(SharingUtility.BU_ALL)){
                                    //There are account team records with the BU as "All"
                                    //This record Id should also be shared with the list of team records with Business_Unit__c as "All"
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(interaction.Id,interaction.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(interaction.Account__c).get(SharingUtility.BU_ALL),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                            }
                        }
                    } 
                    
                    if(!mapOfRecordIdWithUserIdsNAccessLevel.isEmpty()){
                        
                        //Create the sharing wrapper to use for creating the sharing records later
                        
                        /*SharingUtility.SharingRecordCreateWrapper wrapper = new SharingUtility.SharingRecordCreateWrapper();
wrapper.shareObjectName = SharingUtility.getSharingObjectName('Interactions__c');
wrapper.parentFieldName = SharingUtility.getSharingRecParentFieldName('Interactions__c');
wrapper.accessLevelFieldName = SharingUtility.getSharingRecAccessLevelFieldName('Interactions__c');*/
                        
                        SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Interactions__c');
                        wrapper.rowCause = Schema.Interactions__Share.RowCause.Access_Set__c; // Record Creation Sharing Reason
                        wrapper.mapOfRecordIdWithUserIdsNAccessLevel = mapOfRecordIdWithUserIdsNAccessLevel;
                        
                        //Create the sharing records
                        listOfShareRecordsToInsert = SharingUtility.createSharingRecords(wrapper);
                        
                        if(!listOfShareRecordsToInsert.isEmpty()){
                            insert listOfShareRecordsToInsert; //Partial success needed? or try catch needed ?
                            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                        }
                    }
                }
            }
        }
    }
    
    Public static void shareConsumptionsWithAccountTeams(Map<Id,Consumption__c> mapOfNewRecords){
        if(!mapOfNewRecords.isEmpty()){
            
            Set<Id> setOfAccountIds = new Set<Id>();
            Set<String> setOfBUs = new Set<String>{SharingUtility.BU_ALL}; //The records needs to be shared with team users with BU as "All" irrespective of BU value
                
                //Construct setOfAccountIds and setOfBUs
                for(Consumption__c consumption: mapOfNewRecords.values()){
                    if(consumption.Account__c != Null && !setOfAccountIds.contains(consumption.Account__c)){
                        setOfAccountIds.add(consumption.Account__c);
                    }
                    if(String.isNotBlank(consumption.Business_Unit__c) && !setOfBUs.contains(consumption.Business_Unit__c)){
                        setOfBUs.add(consumption.Business_Unit__c);
                    }
                }
            
            if(!setOfAccountIds.isEmpty() && !setOfBUs.isEmpty()){
                //Use setOfAccountIds and setOfBUs to query the Teams with matching BUs
                //Map<AccId, Map<BU,List<Team Rec>>
                Map<Id, Map<String,List<Teams__c>>> mapOfAccIdWithMapOfBUAndTeamsList = SharingUtility.getTeamsWithAccountAndBUs(setOfAccountIds,setOfBUs);
                
                if(!mapOfAccIdWithMapOfBUAndTeamsList.isEmpty()){
                    
                    List<SObject> listOfShareRecordsToInsert = new List<SObject>();
                    map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel = new map<Id, Map<Id,String>>();
                    
                    //Iterate to create the map of records to be shared with users with the access Level based on the team user's Access Level/Primary
                    for(Consumption__c consumption : mapOfNewRecords.values()){
                        if(consumption.Account__c != Null && String.isNotBlank(consumption.Business_Unit__c)){
                            if(mapOfAccIdWithMapOfBUAndTeamsList.containsKey(consumption.Account__c)){
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(consumption.Account__c).containsKey(consumption.Business_Unit__c)){
                                    //There are account team records with the same BU
                                    //This record Id should be shared with the list of team records matching interaction.Business_Unit__c
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(consumption.Id,consumption.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(consumption.Account__c).get(consumption.Business_Unit__c),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(consumption.Account__c).containsKey(SharingUtility.BU_ALL)){
                                    //There are account team records with the BU as "All"
                                    //This record Id should also be shared with the list of team records with Business_Unit__c as "All"
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(consumption.Id,consumption.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(consumption.Account__c).get(SharingUtility.BU_ALL),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                            }
                        }
                    } 
                    
                    if(!mapOfRecordIdWithUserIdsNAccessLevel.isEmpty()){
                        
                        //Create the sharing wrapper to use for creating the sharing records later
                        SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Consumption__c');
                        wrapper.rowCause = Schema.Consumption__Share.RowCause.Access_Set__c; // Record Creation Sharing Reason
                        wrapper.mapOfRecordIdWithUserIdsNAccessLevel = mapOfRecordIdWithUserIdsNAccessLevel;
                        
                        //Create the sharing records
                        listOfShareRecordsToInsert = SharingUtility.createSharingRecords(wrapper);
                        
                        if(!listOfShareRecordsToInsert.isEmpty()){
                            
                            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                            insert listOfShareRecordsToInsert; //Partial success needed? or try catch needed ?
                            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                            
                        }
                    }
                }
            }
        }
    }
    
    Public static void shareBudgetsWithAccountTeams(Map<Id,Budget_vs_Actuals__c> mapOfNewRecords){
        if(!mapOfNewRecords.isEmpty()){
            
            Set<Id> setOfAccountIds = new Set<Id>();
            Set<String> setOfBUs = new Set<String>{SharingUtility.BU_ALL}; //The records needs to be shared with team users with BU as "All" irrespective of BU value
                
                //Construct setOfAccountIds and setOfBUs
                for(Budget_vs_Actuals__c budget: mapOfNewRecords.values()){
                    if(budget.Account__c != Null && !setOfAccountIds.contains(budget.Account__c)){
                        setOfAccountIds.add(budget.Account__c);
                    }
                    if(String.isNotBlank(budget.Business_Unit__c) && !setOfBUs.contains(budget.Business_Unit__c)){
                        setOfBUs.add(budget.Business_Unit__c);
                    }
                }
            
            if(!setOfAccountIds.isEmpty() && !setOfBUs.isEmpty()){
                //Use setOfAccountIds and setOfBUs to query the Teams with matching BUs
                //Map<AccId, Map<BU,List<Team Rec>>
                Map<Id, Map<String,List<Teams__c>>> mapOfAccIdWithMapOfBUAndTeamsList = SharingUtility.getTeamsWithAccountAndBUs(setOfAccountIds,setOfBUs);
                
                if(!mapOfAccIdWithMapOfBUAndTeamsList.isEmpty()){
                    
                    List<SObject> listOfShareRecordsToInsert = new List<SObject>();
                    map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel = new map<Id, Map<Id,String>>();
                    
                    //Iterate to create the map of records to be shared with users with the access Level based on the team user's Access Level/Primary
                    for(Budget_vs_Actuals__c budget : mapOfNewRecords.values()){
                        if(budget.Account__c != Null && String.isNotBlank(budget.Business_Unit__c)){
                            if(mapOfAccIdWithMapOfBUAndTeamsList.containsKey(budget.Account__c)){
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(budget.Account__c).containsKey(budget.Business_Unit__c)){
                                    //There are account team records with the same BU
                                    //This record Id should be shared with the list of team records matching interaction.Business_Unit__c
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(budget.Id,budget.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(budget.Account__c).get(budget.Business_Unit__c),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(budget.Account__c).containsKey(SharingUtility.BU_ALL)){
                                    //There are account team records with the BU as "All"
                                    //This record Id should also be shared with the list of team records with Business_Unit__c as "All"
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(budget.Id,budget.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(budget.Account__c).get(SharingUtility.BU_ALL),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                            }
                        }
                    } 
                    
                    if(!mapOfRecordIdWithUserIdsNAccessLevel.isEmpty()){
                        
                        //Create the sharing wrapper to use for creating the sharing records later
                        SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Budget_vs_Actuals__c');
                        wrapper.rowCause = Schema.Budget_vs_Actuals__Share.RowCause.Access_Set__c; // Record Creation Sharing Reason
                        wrapper.mapOfRecordIdWithUserIdsNAccessLevel = mapOfRecordIdWithUserIdsNAccessLevel;
                        
                        //Create the sharing records
                        listOfShareRecordsToInsert = SharingUtility.createSharingRecords(wrapper);
                        
                        if(!listOfShareRecordsToInsert.isEmpty()){
                            insert listOfShareRecordsToInsert; //Partial success needed? or try catch needed ?
                            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                        }
                    }
                }
            }
        }
    }
    
    Public static void shareAccountPlansWithAccountTeams(Map<Id,Account_Plans__c> mapOfNewRecords){
        if(!mapOfNewRecords.isEmpty()){
            
            Set<Id> setOfAccountIds = new Set<Id>();
            Set<String> setOfBUs = new Set<String>{SharingUtility.BU_ALL}; //The records needs to be shared with team users with BU as "All" irrespective of BU value
                
                //Construct setOfAccountIds and setOfBUs
                for(Account_Plans__c accPlan: mapOfNewRecords.values()){
                    if(accPlan.Account__c != Null && !setOfAccountIds.contains(accPlan.Account__c)){
                        setOfAccountIds.add(accPlan.Account__c);
                    }
                    if(String.isNotBlank(accPlan.BU_Identifier__c) && !setOfBUs.contains(accPlan.BU_Identifier__c)){
                        setOfBUs.add(accPlan.BU_Identifier__c);
                    }
                }
            
            if(!setOfAccountIds.isEmpty() && !setOfBUs.isEmpty()){
                //Use setOfAccountIds and setOfBUs to query the Teams with matching BUs
                //Map<AccId, Map<BU,List<Team Rec>>
                Map<Id, Map<String,List<Teams__c>>> mapOfAccIdWithMapOfBUAndTeamsList = SharingUtility.getTeamsWithAccountAndBUs(setOfAccountIds,setOfBUs);
                
                if(!mapOfAccIdWithMapOfBUAndTeamsList.isEmpty()){
                    
                    List<SObject> listOfShareRecordsToInsert = new List<SObject>();
                    map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel = new map<Id, Map<Id,String>>();
                    
                    //Iterate to create the map of records to be shared with users with the access Level based on the team user's Access Level/Primary
                    for(Account_Plans__c accPlan : mapOfNewRecords.values()){
                        if(accPlan.Account__c != Null && String.isNotBlank(accPlan.BU_Identifier__c)){
                            if(mapOfAccIdWithMapOfBUAndTeamsList.containsKey(accPlan.Account__c)){
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(accPlan.Account__c).containsKey(accPlan.BU_Identifier__c)){
                                    //There are account team records with the same BU
                                    //This record Id should be shared with the list of team records matching interaction.Business_Unit__c
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(accPlan.Id,accPlan.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(accPlan.Account__c).get(accPlan.BU_Identifier__c),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(accPlan.Account__c).containsKey(SharingUtility.BU_ALL)){
                                    //There are account team records with the BU as "All"
                                    //This record Id should also be shared with the list of team records with Business_Unit__c as "All"
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(accPlan.Id,accPlan.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(accPlan.Account__c).get(SharingUtility.BU_ALL),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                            }
                        }
                    } 
                    
                    if(!mapOfRecordIdWithUserIdsNAccessLevel.isEmpty()){
                        
                        //Create the sharing wrapper to use for creating the sharing records later
                        SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Account_Plans__c');
                        wrapper.rowCause = Schema.Account_Plans__Share.RowCause.Access_Set__c; // Record Creation Sharing Reason
                        wrapper.mapOfRecordIdWithUserIdsNAccessLevel = mapOfRecordIdWithUserIdsNAccessLevel;
                        
                        //Create the sharing records
                        listOfShareRecordsToInsert = SharingUtility.createSharingRecords(wrapper);
                        
                        if(!listOfShareRecordsToInsert.isEmpty()){
                            
                            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                            insert listOfShareRecordsToInsert; //Partial success needed? or try catch needed ?
                            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                            
                        }
                    }
                }
            }
        }
    }
    
    Public static void shareEngPlansWithAccountTeams(Map<Id,Engagement_Plan__c> mapOfNewRecords){
        if(!mapOfNewRecords.isEmpty()){
            
            Set<Id> setOfAccountIds = new Set<Id>();
            Set<String> setOfBUs = new Set<String>{SharingUtility.BU_ALL}; //The records needs to be shared with team users with BU as "All" irrespective of BU value
                
                //Construct setOfAccountIds and setOfBUs
                for(Engagement_Plan__c engPlan: mapOfNewRecords.values()){
                    if(engPlan.Account__c != Null && !setOfAccountIds.contains(engPlan.Account__c)){
                        setOfAccountIds.add(engPlan.Account__c);
                    }
                    if(String.isNotBlank(engPlan.Business_Unit__c) && !setOfBUs.contains(engPlan.Business_Unit__c)){
                        setOfBUs.add(engPlan.Business_Unit__c);
                    }
                }
            
            if(!setOfAccountIds.isEmpty() && !setOfBUs.isEmpty()){
                //Use setOfAccountIds and setOfBUs to query the Teams with matching BUs
                //Map<AccId, Map<BU,List<Team Rec>>
                Map<Id, Map<String,List<Teams__c>>> mapOfAccIdWithMapOfBUAndTeamsList = SharingUtility.getTeamsWithAccountAndBUs(setOfAccountIds,setOfBUs);
                
                if(!mapOfAccIdWithMapOfBUAndTeamsList.isEmpty()){
                    
                    List<SObject> listOfShareRecordsToInsert = new List<SObject>();
                    map<Id, Map<Id,String>> mapOfRecordIdWithUserIdsNAccessLevel = new map<Id, Map<Id,String>>();
                    
                    //Iterate to create the map of records to be shared with users with the access Level based on the team user's Access Level/Primary
                    for(Engagement_Plan__c engPlan : mapOfNewRecords.values()){
                        if(engPlan.Account__c != Null && String.isNotBlank(engPlan.Business_Unit__c)){
                            if(mapOfAccIdWithMapOfBUAndTeamsList.containsKey(engPlan.Account__c)){
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(engPlan.Account__c).containsKey(engPlan.Business_Unit__c)){
                                    //There are account team records with the same BU
                                    //This record Id should be shared with the list of team records matching interaction.Business_Unit__c
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(engPlan.Id,engPlan.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(engPlan.Account__c).get(engPlan.Business_Unit__c),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                                if(mapOfAccIdWithMapOfBUAndTeamsList.get(engPlan.Account__c).containsKey(SharingUtility.BU_ALL)){
                                    //There are account team records with the BU as "All"
                                    //This record Id should also be shared with the list of team records with Business_Unit__c as "All"
                                    mapOfRecordIdWithUserIdsNAccessLevel = SharingUtility.createmapOfRecordIdWithUserIdsNAccessLevel(engPlan.Id,engPlan.OwnerId,mapOfAccIdWithMapOfBUAndTeamsList.get(engPlan.Account__c).get(SharingUtility.BU_ALL),mapOfRecordIdWithUserIdsNAccessLevel);
                                }
                            }
                        }
                    } 
                    
                    if(!mapOfRecordIdWithUserIdsNAccessLevel.isEmpty()){
                        
                        //Create the sharing wrapper to use for creating the sharing records later
                        SharingUtility.SharingRecordCreateWrapper wrapper = SharingUtility.createSharingRecordCreateWrapper('Engagement_Plan__c');
                        wrapper.rowCause = Schema.Engagement_Plan__Share.RowCause.Access_Set__c; // Record Creation Sharing Reason
                        wrapper.mapOfRecordIdWithUserIdsNAccessLevel = mapOfRecordIdWithUserIdsNAccessLevel;
                        
                        //Create the sharing records
                        listOfShareRecordsToInsert = SharingUtility.createSharingRecords(wrapper);
                        
                        if(!listOfShareRecordsToInsert.isEmpty()){
                            insert listOfShareRecordsToInsert; //Partial success needed? or try catch needed ?
                            System.debug('listOfShareRecordsToInsert: '+listOfShareRecordsToInsert);
                        }
                    }
                }
            }
        }
    }
}