@isTest
public class RelationshipUtiltiyTest {
    static testMethod void testMethod1(){
        RelationshipUtiltiy relUtil = new RelationshipUtiltiy();
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Testcity';
        acc.BillingCountry = 'india';
        
        Consumption__c cons = new Consumption__c();
             relUtil.registerRelationship(cons, acc, Consumption__c.Account__c);
        	cons.Business_Unit__c='Cocoa';
            cons.Category__c='Cocoa Beans';
            cons.Volume_MT__c=100;
        cons.Year__c=String.valueOf(System.Today().year()-1);
        insert acc;
        relUtil.resolve('Consumption__c');
        insert cons;
    }

}