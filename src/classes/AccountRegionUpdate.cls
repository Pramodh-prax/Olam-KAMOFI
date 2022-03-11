public class AccountRegionUpdate 
{
    Public static void RegionUpdate(list<account> ListofNewAccounts)
    { 
        map<string, Region_Update__mdt> mapofiregion = Region_Update__mdt.getAll();
        system.debug('mapofiregion'+ mapofiregion);    
        for(account tempacc: ListofNewAccounts) 
        {
            
            if (tempacc.BillingCountryCode != Null && tempacc.BillingCountryCode != '' )
                
            { system.debug('mapofiregion'+ mapofiregion);
             system.debug('BillingCountry'+ tempacc.BillingCountryCode);
             system.debug('Key'+ mapofiregion.containskey(tempacc.BillingCountryCode));
             if(mapofiregion.containskey(tempacc.BillingCountryCode))
             {
                 tempacc.Regions__c = mapofiregion.get(tempacc.BillingCountryCode).ofi_Region__c;//Pramodh added for temp, untill production data updated
                 //tempacc.ofi_Region__c = mapofiregion.get(tempacc.BillingCountryCode).ofi_Region__c;
                 tempacc.ofi_Sub_Region__c = mapofiregion.get(tempacc.BillingCountryCode).ofi_Sub_Region__c;
                 tempacc.ofi_Sub_Region_2__c = mapofiregion.get(tempacc.BillingCountryCode).ofi_Sub_Region_2__c;
                 //system.debug('mapofiregion'+ mapofiregion);
                 //system.debug('BillingCountry'+ tempacc.BillingCountryCode);
             }
            }
        }
    }
    
    //Added by Bharatesh - Replacing Ashwini's fnctionality in AccountTriggerHanlder.beforeInsert
    public static void setOwnerToIntegrationUser(List<Account> listOfNewAccounts){
        //AccountTriggerHelper.validatePostalCode(listOfNewAccounts);
        //Reassigning Account Owner as "Intergration user"
        ID customLabelValue = System.Label.Integration_user_id;  //fetching custom label id of "Intergration user"
        for(Account tempAccount : listOfNewAccounts)
        {
            tempAccount.OwnerId = customLabelValue;  //Custom label having id of "Intergration user"  is assigned here
        }
        
    }
}