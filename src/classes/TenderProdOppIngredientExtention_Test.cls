@isTest
public class TenderProdOppIngredientExtention_Test {
	@istest static void testMethod1(){
        Id ParentRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Opportunity').getRecordTypeId();
        Id TCBRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('PLBS Tendering Product').getRecordTypeId();
        Account acc = new Account(Name = 'UNIT TEST account1', BillingCity='TestIndia', BillingStreet = 'Test 1 street', BillingCountry = 'India', BillingCountryCode ='IN', BillingPostalCode = '123456' , ShippingStreet = 'Test 2 street', ShippingCountry = 'India', ShippingCountryCode ='IN', ShippingPostalCode = '123456');        
        insert acc;
        Product2 product1 = new Product2(Name = 'UNIT TEST Product 1');
        insert product1;
            Product2 product2 = new Product2(Name = 'UNIT TEST Product 2');
        insert product2;
            Product2 product3 = new Product2(Name = 'UNIT TEST Product 3');
        insert product3;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);     
        Update standardPricebook;
            Pricebook2 PLBSIngredient = new Pricebook2(Name = 'PLBS Ingredient',IsActive = true);     
        Insert PLBSIngredient;
            PricebookEntry pbEntry1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product1.Id, UnitPrice = 100, IsActive = true);
        insert pbEntry1;
        PricebookEntry pbEntry2 = new PricebookEntry(Pricebook2Id = PLBSIngredient.Id, Product2Id = product1.Id, UnitPrice = 100, IsActive = true);
        insert pbEntry2;
            PricebookEntry pbEntry5 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product3.Id, UnitPrice = 100, IsActive = true);
        insert pbEntry5;
            PricebookEntry pbEntry6 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product2.Id, UnitPrice = 100, IsActive = true);
        insert pbEntry6;
            PricebookEntry pbEntry3 = new PricebookEntry(Pricebook2Id = PLBSIngredient.Id, Product2Id = product2.Id, UnitPrice = 100, IsActive = true);
        insert pbEntry3;
            
            PricebookEntry pbEntry4 = new PricebookEntry(Pricebook2Id = PLBSIngredient.Id, Product2Id = product3.Id, UnitPrice = 100, IsActive = true);
        insert pbEntry4;
        PLBS_Product__c plbsPro=new PLBS_Product__c(Name='TestingPro',Product_Family__c='Snacks',Product_Category__c='Nut mixes');
        insert plbsPro;
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
        update new Opportunity(Id = opp1.Id, Pricebook2Id = PLBSIngredient.Id);
          //While Deploying to Product Rewrite bcz opportunity Trigger will active At That time
        tcb__c tcb1=new TCb__c(Opportunity__c=Opp1.Id,PM_Type_1st__c='DOY',PM_Type_2nd__c='RSC',Fobbing_Container__c=20,CTN_40FT_HC__c =20,Unit_CTN__c=10,
                              Pallet_Type__c='Disposal - 0.8x1.2m',Quotations_Given_as_Per__c='40FT Container');
        insert tcb1;
        /*tcb__c t=[select id from tcb__c where Opportunity__c=:opp1.Id];
        tcb__c tcb=new TCb__c(Id = t.Id,Opportunity__c=Opp1.Id,PM_Type_1st__c='DOY',PM_Type_2nd__c='RSC',Fobbing_Container__c=20,CTN_40FT_HC__c =20,Unit_CTN__c=10,
                              Pallet_Type__c='Disposal - 0.8x1.2m',Quotations_Given_as_Per__c='40FT Container');
        update tcb;*/
        
        OpportunityLineItem oppLineItem1 = new OpportunityLineItem(OpportunityId = opp1.Id, 
                                                                   Product2Id = product3.Id, 
                                                                   PricebookEntryId = pbEntry4.Id,Ratio__c=100,
                                                                   Sampling_Status__c = '7');
        insert oppLineItem1;
        
        PageReference pageRef = Page.CloneTenderProdOppWithIngredient;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id',opp1.id);
        
        
        // Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp1);
        TenderProdOppIngredientExtention generateOF = new TenderProdOppIngredientExtention(sc);
        try{
        generateOF.save();
        }catch(Exception e){
            
        }
    }
}