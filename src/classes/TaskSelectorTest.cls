@isTest
public class TaskSelectorTest {

    public static testmethod void getTaksByInteractionAndDateTest(){
        
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
        Interactions__c inter=new Interactions__c();
        inter.Account__c=acc.Id;
        inter.Business_Unit__c='Cocoa';
        inter.Name='Test Interaction';
        insert inter;
        
          
        Task test=new task();
        test.Subject='Visit';
        test.Status='completed';
        test.Interaction_Type__c='C Level Engagement';
        test.WhatId=inter.id;
        test.Completed_Date__c=system.today();
		test.Priority='Normal';
        insert test;
        
        Date startDate=system.Today();
        Date endDate=system.today().addDays (15);
        
        set<String> interactionType=new set<String>();
        interactionType.add('C Level Engagement');
         interactionType.add('Commercial (Sales & Pricing)');
         interactionType.add('Finance (Structures & Payments)');
         interactionType.add('Innovation');
        
       
       List<AggregateResult> Res= TaskSelector.getTaksByInteractionAndDate(inter.Id,interactionType,startDate,endDate);
        system.assert(Res!=null && (!Res.isEmpty ()), 'Get Task Failed');
        
        
    }
    
    
    
}