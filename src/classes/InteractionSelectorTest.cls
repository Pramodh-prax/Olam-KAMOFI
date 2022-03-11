@isTest
public class InteractionSelectorTest {
    
    @testSetup
    static void method()
    {
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
        Interactions__c i=new Interactions__c();
        i.Account__c=acc.Id;
        i.Business_Unit__c='Cocoa';
        insert i;
        
        
    }

	@isTest 
    static void test_getInteractionsByIds () {
        Interactions__c i=[Select Id,Business_Unit__c from Interactions__c where createdDate=Today Limit 1];
        List<Interactions__c> interactions = InteractionSelector.getInteractionsByIds (new set<Id> {null, i.Id});
        System.assert(interactions.size() > 0, 'No interactions found');
        System.assertEquals(i.Business_Unit__c, interactions[0].Business_Unit__c, 'Mismatch in BU');
    }    
    @isTest
    static void test_getInteractionsByAccountIds()
    {
        Account acc=[Select Id,Name from Account where createdDate=Today Limit 1];
        System.assert(acc!=null, 'Containing null values');
        Interactions__c i=[Select Id,Business_Unit__c from Interactions__c where createdDate=Today Limit 1];
        Set<Id> ids=new Set<Id>();	
        ids.add(acc.id);
        ids.add(null);
        Set<String> bu=new Set<String>();
        bu.add(i.Business_Unit__c);
        System.debug('ids==========>'+ids);
        System.debug('bu==========>'+bu);
        InteractionSelector.getInteractionsByAccountIds (ids,bu);
    }
    
}