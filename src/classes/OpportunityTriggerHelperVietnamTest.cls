@isTest
public class OpportunityTriggerHelperVietnamTest {
    
     @testSetup 
    static void testRecords(){
        
        Profile proId =[select Id from Profile where Name='Vietnam PLBS'];
         User us = createTestUser('Tester',ProId.id,null);
        PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;
        CustomPermission ps1 = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'Olam_Validation_Exception' limit 1];
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = ps1.Id
        );
        insert sea;
        insert new PermissionSetAssignment(AssigneeId = us.id, PermissionSetId = ps.Id);  
        
        system.runAs(us){
        Account acc = new Account(Name = 'UNIT TEST account1', BillingCity='TestIndia', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', BillingPostalCode = '123456' , ShippingStreet = 'Test 2 street', ShippingCountry = 'India', ShippingCountryCode ='IN', ShippingPostalCode = '123456');        
        insert acc;
        Product2 product1 = new Product2(Name = 'UNIT TEST Product 1');
        insert product1;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);     
        Update standardPricebook;
        PricebookEntry pbEntry1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product1.Id, UnitPrice = 100, IsActive = true);
        insert pbEntry1;
        
        PLBS_Product__c plbsPro=new PLBS_Product__c(Name='TestingPro',Product_Family__c='Snacks',Product_Category__c='Nut mixes');
        insert plbsPro;
        
        Price_Kit__c pk=new Price_Kit__c(Active__c=true,Name='2021',Start_Date__c=system.today());
        insert pk;
        Product_Price_Kit__c ppk = new Product_Price_Kit__c(Price_Kit__c=pk.Id,Product_Family__c='Snacks',Product_Category__c='Nut mixes',Processing_loss__c=20,Processing_cost_USD_lb__c=10,Active__c=true);
        insert ppk;
        X1st_PM__c pm1st = new X1st_PM__c(Price_Kit__c=pk.Id,X1st_PM_Type__c='DOY',Loss__c=0.2,Active__c=true);
        insert pm1st;
        X2nd_PM__c pm2st = new X2nd_PM__c(Price_Kit__c=pk.Id,X2nd_PM_Type__c='RSC',Loss__c=0.2,Active__c=true);
        insert pm2st;
        Quotations_as_per__c Qap= new Quotations_as_per__c(Price_Kit__c=pk.Id, USD__c=200,Fobbing_container__c='40FT Container',Active__c=true);
        insert qap;
        Packing_Cost__c pc = new Packing_Cost__c(Price_Kit__c=pk.Id,Active__c=true,To__c=101,From__c=10,Packing_Cost_lbs__c=10);     
        insert pc;   
        Pallet__c pt = new Pallet__c(Price_Kit__c=pk.Id,Active__c=true,Pallet_Type__c='Disposal - 0.8x1.2m',USD_each__c=10);
        insert pt;
        Interest__c ints = new Interest__c(Price_Kit__c=pk.Id,Active__c=true,Interest__c=5);
        insert ints;
            
        Id ParentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Opportunity').getRecordTypeId();
        Id TCBRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Product').getRecordTypeId();
        Opportunity opp = new Opportunity(AccountId = acc.Id, 
                                          Name = 'unittest - opp',
                                          StageName = 'Briefing',
                                          CloseDate = date.newInstance(2050, 11, 21),
                                          Business_Unit__c = 'Dairy',
                                          RecordTypeId = ParentRecordTypeId,
                                          Local_Currency__c='USD',
                                          Pricebook2Id = standardPricebook.Id,
                                          Project_Type__c = 'Sample');
        insert opp;
        Opportunity opp1 = new Opportunity(AccountId = acc.Id, 
                                           Name = 'unittest - opp1',
                                           parent_Opportunity__c=Opp.Id,
                                           StageName = 'Briefing',
                                           PLBS_Product__c = plbsPro.Id,
                                           Plbs_Weight_G__c=100,
                                           CloseDate = date.newInstance(2050, 11, 21),
                                           Business_Unit__c = 'Dairy',
                                           RecordTypeId = TCBRecordTypeId,
                                           Pricebook2Id = standardPricebook.Id,
                                           Plbs_Annual_Unit__c =1,
                                           Plbs_Est_Award__c=1000,
                                           Project_Type__c = 'Sample');
        insert opp1;
        
        tcb__c tcb=new TCb__c(Opportunity__c=Opp1.Id,PM_Type_1st__c='DOY',PM_Type_2nd__c='RSC',Fobbing_Container__c=20,CTN_40FT_HC__c =20,Unit_CTN__c=10,
                              Pallet_Type__c='Disposal - 0.8x1.2m',Quotations_Given_as_Per__c='40FT Container');
        tcb.Opportunity_Processing__c=10;
        tcb.Interest__c=10;
        //tcb.Initial_Design_TCB__c=10;
        tcb.Loss_Product__c=10;
        tcb.Initial_Design__c=1;
        insert tcb;
        
            
        Quote qun= new Quote(OpportunityId=opp1.Id,Name='testq',pricebook2Id =standardPricebook.Id,ExpirationDate=system.today()+30,Inco_Terms__c='DAP',Ship_To_Party__c=acc.id);
            insert qun;
        
        
    }

    }
    
    @istest static void testMethod1(){
        
    }
    
 public static User createTestUser(string lastName, Id profileId, Id roleId) {
        User user = new User(
            ProfileId = profileId,
            LastName = lastName,
            Email = lastName + '@unittestuser.com',
            Username = lastName + '@unittestuser.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = roleId
        );    
        insert user;
        return user;
    }
    
    

}