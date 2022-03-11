@isTest
public class OFI_OpportunityTriggerTest {
    

    @isTest 
    static void testGetDetails () {
        
        
        Access_Set__c accset = OFI_TestDataFactory.createAccessSet('country', null, 'In', 'All', null, null, null, true);
        
        
        Profile p = [select id from profile where name='OFI'];
        
        User u = new User(alias = 'test123', email='test123@noemail.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='test123@noemail.com'/*, Access_Set_Role__c = 'PDI'*/ );
        insert u; 
        User u2 = new User(alias = 'test1234', email='test123@noemail.com2',
                          emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='test123@noemail.com2'/*, Access_Set_Role__c = 'PDI'*/ );
        insert u2; 
        User u3 = new User(alias = 't13234', email='test1fa23@nafoemail.com2',
                          emailencodingkey='UTF-8', lastname='Tessfting2', languagelocalekey='en_US',
                          localesidkey='en_US', profileid = p.Id,
                          timezonesidkey='America/Los_Angeles', username='test123@noemasfsil.csom2'/*, Access_Set_Role__c = 'PDI'*/ );
        insert u3; 
        
        Access_Set_Assignment__c accsetass1=OFI_TestDataFactory.createAccessSetAssignment(accset.Id, u.id, /*, 'PDI'*/ true);
        Access_Set_Assignment__c accsetass2=OFI_TestDataFactory.createAccessSetAssignment(accset.Id, u2.id, /*, 'PDI'*/ true);

        
        Account acc= OFI_TestDataFactory.createMultipleAccount('Test', 'India','In', null, null, null, true);
        Account acc1= OFI_TestDataFactory.createMultipleAccount('Test1', 'India','In', null, null, null, true);

        Set<id> userIds = new Set<id>();
        userIds.add(u.Id);
        userIds.add(u2.Id);
        
        Teams__c teamSpice = new Teams__c(Account__c =acc.id,Access_Level__c= 'Edit Access',Business_Unit__c ='Spice',User__c=u3.id);   
        insert teamSpice;
        
        List<Teams__c> TeamUpdate = [Select Id,Access_Level__c,User__c from Teams__c where User__c IN : userIds];
        for(Teams__c obj : TeamUpdate){
            obj.Access_Level__c = 'Edit Access';
        }
        update TeamUpdate;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Contact c= new Contact(AccountId=acc.id,Lastname='jack',Email='jakck@gmail.com');   
        insert c;
        Contact c2= new Contact(AccountId=acc1.id,Lastname='jack3',Email='jakck3@gmai3l.com');   
        insert c2;
        
        Opportunity opp1 = new Opportunity(Name='TestOpportunity', 
                                           AccountId=acc.Id, CloseDate=Date.Today(), StageName='Suspect',
                                           Business_unit__c ='Cocoa',
                                          RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId());
        insert opp1;
        OpportunityTeamMember oppt=new OpportunityTeamMember(OpportunityId=opp1.id,TeamMemberRole='PD&I Member',UserId=u2.Id);
        insert oppt;
        OpportunityContactRole ocr =new OpportunityContactRole(OpportunityId=opp1.Id,ContactId=c2.id);
        insert ocr;
        
       
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opp1.Id, Quantity = 5, PricebookEntryId = customPrice.Id, TotalPrice = 500);
        insert oli1;
        oli1.Quantity=6;
        update oli1;
        System.runAs(u){
            oli1.Quantity=12;
            try{
                update oli1; }catch(DMLException ex){}
            
            Opportunity oppTest = [Select Id, Name from Opportunity where id =: opp1.Id];
            System.debug('***oppTest '+oppTest);
             OpportunityLineItem oliTest = new OpportunityLineItem(OpportunityId = oppTest.Id, Quantity = 5, PricebookEntryId = customPrice.Id, TotalPrice = 500);
            try{
            insert oliTest;
            update oliTest;
            }catch(Exception e){}

            test.startTest();

            Contact c1= new Contact(AccountId=acc.id,Lastname='jack1',Email='jakk@gmail.com');   
            insert c1;
            
            Opportunity opp1new = new Opportunity(Name='TestOpportunityforuser', 
                                                  AccountId=acc1.Id, CloseDate=Date.Today(), StageName='Suspect',Business_unit__c = 'Cocoa', 
                                                  Pricebook2Id=customPB.Id);
            
            try{
                insert opp1new;
            }Catch(Exception e){}
            
            OpportunityContactRole ocr2 =new OpportunityContactRole(OpportunityId=opp1new.Id,ContactId=c2.id);
        	insert ocr2;
            
            Opportunity opdef = new Opportunity(Name = 'Test Opp2',AccountId =acc.id,CloseDate=system.today()+30,Description='test',Estimated_Volume_MT__c =3,Target_Selling_Price__c=2,
                                                Target_Margin__c='Low',Key_Driver_to_Win_Project__c ='Cost',First_Sample_Due_Date__c=system.today()+10,	CurrencyIsoCode ='USD',
                                                Category__c='WET',Segment__c ='DAIRY',Sub_Segment__c ='Chocolate milk',
                                                StageName= 'Briefing',Pricebook2Id=customPB.id, Business_unit__c = 'Cocoa'
                                                ,RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Defend Opportunity').getRecordTypeId());
            
            try{
                insert opdef;
            }Catch(Exception e){}
            OpportunityContactRole ocr3 =new OpportunityContactRole(OpportunityId=opdef.Id,ContactId=c.id);
        	insert ocr3;
            
            Opportunity opdev = new Opportunity(Name = 'Test Opp develop',AccountId =acc.id,CloseDate=system.today()+30,Description='test',Estimated_Volume_MT__c =22,Target_Selling_Price__c=3,
                                                Target_Margin__c='Low',Key_Driver_to_Win_Project__c ='Cost',First_Sample_Due_Date__c=system.today()+10,CurrencyIsoCode ='USD',
                                                Category__c='WET',Segment__c ='DAIRY',Sub_Segment__c ='Chocolate milk',
                                                StageName= 'Briefing',Pricebook2Id=customPB.id, Business_unit__c = 'Dairy'
                                                ,RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Develop Opportunity').getRecordTypeId());
            
            try{
                insert opdev;
            }Catch(Exception e){}
            OpportunityContactRole ocr4 =new OpportunityContactRole(OpportunityId=opdev.Id,ContactId=c.id);
        	insert ocr4;
            
            Opportunity opp = new Opportunity(Name='TestOpportunity',Business_Unit__c='Dairy', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Suspect', Pricebook2Id=customPB.Id,RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Develop Opportunity').getRecordTypeId());
            opp.Project_Type__c = 'Sample';
            try{
                insert opp;}catch(Exception e){}
            OpportunityContactRole ocr5 =new OpportunityContactRole(OpportunityId=opp.Id,ContactId=c.id);
        	insert ocr5;
            
            Opportunity oppNull = new Opportunity(Name='TestOpportunityBUnull', Business_unit__c ='', AccountId=acc.Id, CloseDate=Date.Today(), StageName='Suspect', Pricebook2Id=customPB.Id);
            try{
                insert oppNull;
            }catch(Exception e){}               
            try{
            
            OpportunityContactRole ocr1 =new OpportunityContactRole(OpportunityId=opp.Id,ContactId=c1.id);
            insert ocr1;
            opp.Amount=12;
            
            update opp;
            
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 5, PricebookEntryId = customPrice.Id, TotalPrice = 500, UoM__c='KG', Sampling_Status__c='1', Quantity_of_Sample_Grams__c=2);
            
                insert oli;
            }catch(DMLException ex){}
            
            oli1.Quantity=12;
            try{
                update oli1; }catch(DMLException ex){}
            
            test.stopTest();
           
        }
        System.runAs(u3){
            Opportunity opp13 = new Opportunity(Name='TestOpportunityGain1', 
                                           AccountId=acc.Id, CloseDate=Date.Today(), StageName='Suspect',
                                          RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Gain Opportunity').getRecordTypeId());
        insert opp13;

        OpportunityContactRole ocr76 =new OpportunityContactRole(OpportunityId=opp13.Id,ContactId=c2.id);
        insert ocr76;
        }
    }
    /*
    @isTest
    static void test_getMapOfUserAccessSet()
    {
        List<User> user = [Select Id, Name From User where email='test123@noemail.com'];
        OFI_OpportunityLineItemHandler.getMapOfUserAccessSet(user[0].Id);
    }*/
    
}