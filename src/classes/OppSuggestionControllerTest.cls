@istest
public class OppSuggestionControllerTest {

    @istest static void testMethod1(){
        Id ParentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Opportunity').getRecordTypeId();
        Id TCBRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Product').getRecordTypeId();
        Account acc = new Account(Name = 'UNIT TEST account1', BillingCity='TestIndia', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', BillingPostalCode = '123456' , ShippingStreet = 'Test 2 street', ShippingCountry = 'India', ShippingCountryCode ='IN', ShippingPostalCode = '123456');        
        insert acc;
        
         PLBS_Product__c plbsPro=new PLBS_Product__c(Name='TestingPro',Product_Family__c='Snacks',Product_Category__c='Nut mixes');
        insert plbsPro;
        
        Opportunity opp1 = new Opportunity(AccountId = acc.Id, 
                                           Name = 'unittest - opp1',
                                           StageName = 'Briefing',
                                           PLBS_Product__c = plbsPro.Id,
                                           Plbs_Weight_G__c=100,
                                           CloseDate = date.newInstance(2050, 11, 21),
                                           Business_Unit__c = 'Dairy',
                                           RecordTypeId = TCBRecordTypeId,
                                           Plbs_Annual_Unit__c =1,
                                           Plbs_Est_Award__c=1000,
                                           Project_Type__c = 'Sample');
        insert opp1;
        Opportunity opp2 = new Opportunity(AccountId = acc.Id, 
                                           Name = 'unittest - opp1',
                                           StageName = 'Briefing',
                                           PLBS_Product__c = plbsPro.Id,
                                           Plbs_Weight_G__c=100,
                                           CloseDate = date.newInstance(2050, 11, 21),
                                           Business_Unit__c = 'Dairy',
                                           RecordTypeId = TCBRecordTypeId,
                                           Plbs_Annual_Unit__c =1,
                                           Plbs_Est_Award__c=1000,
                                           Project_Type__c = 'Sample');
        insert opp2;
        
        tcb__c tcb1=new TCb__c(Opportunity__c=Opp1.Id,PM_Type_1st__c='DOY',PM_Type_2nd__c='RSC',Fobbing_Container__c=20,CTN_40FT_HC__c =20,Unit_CTN__c=10,
                              Pallet_Type__c='Disposal - 0.8x1.2m',Quotations_Given_as_Per__c='40FT Container');
        insert tcb1;
        tcb__c tcb2=new TCb__c(Opportunity__c=Opp2.Id,PM_Type_1st__c='DOY',PM_Type_2nd__c='RSC',Fobbing_Container__c=20,CTN_40FT_HC__c =20,Unit_CTN__c=10,
                              Pallet_Type__c='Disposal - 0.8x1.2m',Quotations_Given_as_Per__c='40FT Container');
        insert tcb2;
        Delete [select ID from TCB__c where PM_Type_1st__c!='DOY'];
        OppSuggestionController.getSuggestionOpps(opp1.Id);
        OppSuggestionController.copy(opp1.Id,Opp2.ID);
    }
}