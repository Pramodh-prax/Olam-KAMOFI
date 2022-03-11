@isTest
public class TaskTriggerHandlerTest {
    
	
    
     @testSetUp
    static void createData (){
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
        Task test=new task();
        test.Subject='Visit';
        test.Status='completed';
        test.Interaction_Type__c='C Level Engagement';
        test.WhatId=acc.id;
		test.Priority='Normal';
        insert test;
        
        Task test1=new task();
        test1.Subject='Visit';
        test1.Status='open';
        test1.Interaction_Type__c='C Level Engagement';
        test1.WhatId=acc.id;
        test1.Priority='Normal';
        insert test1;
         Interactions__c inter=new Interactions__c();
        inter.Account__c=acc.Id;
        inter.Business_Unit__c='Cocoa';
        inter.Name='Test Interaction';
        insert inter;
        system.debug(test1.WhatId.getSObjectType().getDescribe().getSobjectType());
        
        
        Task test3=new task();
        test3.Subject='Visit';
        test3.Status='completed';
        test3.Interaction_Type__c='C Level Engagement';
        test3.WhatId=inter.id;
		test3.Priority='Normal';
        insert test3;
        Task test4=new task();
        test4.Subject='Visit';
        test4.Status='open';
        test4.Interaction_Type__c='C Level Engagement';
        test4.WhatId=inter.id;
        test4.Priority='Normal';
		insert test4;
         
        
    }
        public static testmethod void  handleBeforeInsertTest(){
            
        TaskTriggerHandler TaskHandler=TaskTriggerHandler.getInstance ();
        System.assert(TaskHandler!=null, 'Not get Instance');
        List<task> newList=[select Subject,Status,Interaction_Type__c,WhatId,Priority,Completed_Date__c from Task where Status='completed' ];
        System.assert(newList!=null&& !newList.isEmpty (), 'No newList Found');    
      TaskHandler.handleBeforeInsert(newList);
       System.assertEquals(newList[0].Completed_Date__c, System.today (), 'Insert Failed');     
            
      // TaskHandler.handleBeforeUpdate(newList, newMap, oldMap);
       //TaskHandler.handleOnAfterInsert(newList_interaction, newMap_interaction);
        //TaskHandler.handleOnAfterUpdate(newList_interaction, newMap_interaction, oldMap_interaction); 
        
    }
     public static testmethod void  handleBeforeUpdateTest(){
         
         TaskTriggerHandler TaskHandler=TaskTriggerHandler.getInstance ();
        System.assert(TaskHandler!=null, 'Not get Instance');
        task oldTask=[select Subject,Status,Interaction_Type__c,WhatId,Priority,Completed_Date__c from task where Status='open' limit 1 ];
         System.assert(oldTask!=null, 'No oldTask Found'); 
         Map<Id,Task> oldMap=new  Map<Id,Task>();
         oldMap.put(oldTask.Id,oldTask);
         task newTask=[select Subject,Status,Interaction_Type__c,WhatId,Priority,Completed_Date__c from task where Interaction_Type__c='C Level Engagement' AND Status='completed' limit 1 ];
         System.assert(newTask!=null, 'No newTask Found');  
        newTask.id=oldTask.Id;
        update newTask;
          Map<Id,Task> newMap=new  Map<Id,Task>();
         newMap.put(newTask.Id,newTask);
         List<task> newList=new List<task>();
         newList.add(newTask);
        System.assert(newList!=null&& !newList.isEmpty (), 'No newList Found');
         TaskHandler.handleBeforeUpdate(newList,newMap,oldMap);
          System.assertEquals(newList[0].Completed_Date__c, System.today (), 'Update Failed');  
       
     }
    public static testmethod void  handleOnAfterInsert(){
        TaskTriggerHandler TaskHandler=TaskTriggerHandler.getInstance ();
        System.assert(TaskHandler!=null, 'Not get Instance');
        task oldTask=[select Subject,Status,Interaction_Type__c,WhatId,Priority,Completed_Date__c from task where Interaction_Type__c='C Level Engagement' AND Status='open' limit 1 ];
         System.assert(oldTask!=null, 'No oldTask Found'); 
        task newTask=[select Subject,Status,Interaction_Type__c,WhatId,Priority,Completed_Date__c from task where Interaction_Type__c='C Level Engagement' AND Status='completed' limit 1 ];
         System.assert(newTask!=null, 'No newTask Found');  
        newTask.id=oldTask.Id;
        update newTask;
          Map<Id,Task> newMap=new  Map<Id,Task>();
         newMap.put(newTask.Id,newTask);
         List<task> newList=new List<task>();
         newList.add(newTask);
         TaskHandler.handleOnAfterInsert(newList,newMap);
        
       }
    public static testmethod void  handleOnAfterUpdateTest(){
         
         TaskTriggerHandler TaskHandler=TaskTriggerHandler.getInstance ();
        System.assert(TaskHandler!=null, 'Not get Instance');
        task oldTask=[select Subject,Status,Interaction_Type__c,WhatId,Priority,Completed_Date__c from task where Status='open' limit 1 ];
         System.assert(oldTask!=null, 'No oldTask Found'); 
         Map<Id,Task> oldMap=new  Map<Id,Task>();
         oldMap.put(oldTask.Id,oldTask);
        system.debug('before update'+oldTask);
         task newTask=[select Subject,Status,Interaction_Type__c,WhatId,Priority,Completed_Date__c from task where Interaction_Type__c='C Level Engagement' AND Status='completed' limit 1 ];
         newTask.id=oldTask.Id;
        update newTask;
          Map<Id,Task> newMap=new  Map<Id,Task>();
         newMap.put(newTask.Id,newTask);
         List<task> newList=new List<task>();
         newList.add(newTask);
        System.assert(newList!=null&& !newList.isEmpty (), 'No newList Found');
         TaskHandler.handleOnAfterUpdate(newList,newMap,oldMap); 
       
     }
    
}