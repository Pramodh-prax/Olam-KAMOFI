@istest
public class TCBTriggerTest {
    
    @testSetup static void testRecords(){
        //List<DatedConversionRate> vndcurrency = new List<DatedConversionRate>();
        /*vndcurrency = [SELECT ConversionRate, IsoCode, StartDate, NextStartDate 
                FROM DatedConversionRate 
                WHERE 
               IsoCode = 'VND'];*/
        Profile proId =[select Id from Profile where Name='Vietnam PLBS'];
        User us = createTestUser('Tester',ProId.id,null);
        PermissionSet ps = new PermissionSet(Label = 'mockPs', Name = 'mockPs');
        insert ps;
        CustomPermission ps1 = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'Vietnam_Custom_Exception' limit 1];
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
                                          //Local_Currency__c='USD',
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
        // Create new OpportunityLineItems
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id, 
                                                                   Product2Id = product1.Id, 
                                                                   PricebookEntryId = pbEntry1.Id,Ratio__c=100,
                                                                   Sampling_Status__c = '7');
        insert oppLineItem1;
        }
    }
    
    @istest static void testMethod1(){
        String query=getQueryString('Opportunity');
        query+=' FROM Opportunity';
        Map<Id,Opportunity> mapOfOpportunites=new Map<Id,Opportunity>((List<Opportunity>)DataBase.query(query));
        Map<Id,Opportunity> mapOfOpportunites1=new Map<Id,Opportunity>((List<Opportunity>)DataBase.query(query));
        Profile proId =[select Id from Profile where Name='Vietnam PLBS'];
        User us = createTestUser('Tester1',ProId.id,null);
        PermissionSet ps = new PermissionSet(Label = 'mockPs1', Name = 'mockPs1');
        insert ps;
        CustomPermission ps1 = [SELECT Id FROM CustomPermission WHERE DeveloperName = 'Olam_Validation_Exception' limit 1];
        SetupEntityAccess sea = new SetupEntityAccess(
            ParentId = ps.Id,
            SetupEntityId = ps1.Id
        );
        insert sea;
        insert new PermissionSetAssignment(AssigneeId = us.id, PermissionSetId = ps.Id);  
        
        system.runAs(us){
        OpportunityTriggerHelperVietnam.afterInsert(mapOfOpportunites.values());
        list<Opportunity> listOpp=mapOfOpportunites1.values();
        PLBS_Product__c plbsPro=new PLBS_Product__c(Name='TestingPro1');
        insert plbsPro;
        system.debug('listOpp Before ---> '+listOpp[1].PLBS_Product__c);
        system.debug('mapOfOpportunites Before ---> '+mapOfOpportunites.get(listOpp[1].Id).PLBS_Product__c);
        for(Opportunity opp:mapOfOpportunites.values()){
            Opp.PLBS_Product__c=plbsPro.id;
            Opp.Plbs_Weight_G__c=20;
            //Opp.Local_Currency__c='AUD';
        }
        system.debug('listOpp ---> '+listOpp[1].PLBS_Product__c);
        system.debug('mapOfOpportunites ---> '+mapOfOpportunites.get(listOpp[1].Id).PLBS_Product__c);
        OpportunityTriggerHelperVietnam.beforeUpdate(listOpp, mapOfOpportunites);
        OpportunityTriggerHelperVietnam.afterUpdate(listOpp, mapOfOpportunites);
        Id ParentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Opportunity').getRecordTypeId();
        list<Opportunity> opptest=[select id,local_currency__c,PLBS_Product__c,Plbs_Weight_G__c from Opportunity  ];
        for(Opportunity Opp: opptest){
            //opp.Local_Currency__c='AED';
            opp.PLBS_Product__c=plbsPro.Id;
            opp.Plbs_Weight_G__c=101; 
        }
        update opptest;
        system.debug('opptest '+opptest);
        string Oppid='';
        list<TCB__c> TCBtest=[select id,Name,PM_Type_1st__c,PM_Type_2nd__c,Pallet_Type__c,Quotations_Given_as_Per__c,Opportunity__c from TCB__c];
        system.debug('TCB--> '+[select id,Name from TCB__c where PM_Type_1st__c != 'DOY' ]);
        for(TCB__c tcb: TCBtest){
            tcb.PM_Type_1st__c='DOY';
            tcb.PM_Type_2nd__c='RSC';
            tcb.Pallet_Type__c='Disposal - 0.8x1.2m';
            tcb.Quotations_Given_as_Per__c='40FT Container';
            if(tcb.Opportunity__c!=null){
                Oppid=tcb.Opportunity__c;
            }
        }
        update TCBtest;
      
     //   PLBSComponentController.getTCBId(Oppid);
                 } 
    }
    
    public static String getQueryString(String objectName){
        Map<String, Schema.SObjectType> objMap = new Map<String, Schema.SObjectType>();
        objMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = objMap.get(objectName).getDescribe().fields.getMap();
        string queryString = 'SELECT ';
        for(Schema.SObjectField field :fieldMap.values()){
            queryString = queryString + field.getDescribe().getName() + ', ';
        }
        queryString = queryString.substring(0,queryString.length() - 2);
        return queryString;
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