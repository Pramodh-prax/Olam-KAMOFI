@isTest
public class ProductMappingTriggerHandler_Test {
    
    public static void createTestUser() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            UserRole cocoaRole = new UserRole(DeveloperName = 'Cocoa_Something_Role', Name = 'Cocoa Something');
            insert cocoaRole;
            
            Id cocoaProfileId = [SELECT Id FROM Profile WHERE Name = 'Cocoa Sales'].Id;
            User user = new User(
                ProfileId = cocoaProfileId,
                LastName = 'UnitTestCocoaUser1',
                Email = 'UnitTestCocoaUser1' + '@unittestuser.com',
                Username = 'UnitTestCocoaUser1' + '@unittestuser.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                UserRoleId = cocoaRole.Id
            );    
            insert user;
        }
    }

    @isTest
    public static void testUpdatingExternalProductId() {
        Test.startTest();
        
        createTestUser();
            Product2 prd1, prd2, prd3, prd4, prd5, prd5Dup, prd6;
            User user1 = [SELECT Id FROM User WHERE LastName = 'UnitTestCocoaUser1'];
            System.runAs (user1) {
            prd1 = new Product2(Name='Product1');
            prd2 = new Product2(Name='Product2');
            prd3 = new Product2(Name='Product3');
            prd4 = new Product2(Name='Product4');
            prd5 = new Product2(Name='Product5');
            prd5Dup = new Product2(Name='Product5');
            prd6 = new Product2(Name='Product6', External_Product_Code__c='6666');
            List<Product2> products = new List<Product2>{prd1, prd2, prd3, prd4, prd5, prd5Dup, prd6};
            insert products;
        }
        
        Product_Mapping__c prdMap1 = new Product_Mapping__c(Product_Name__c = 'Product1', External_Product_Code__c  = '111');
        Product_Mapping__c prdMap2 = new Product_Mapping__c(Product_Name__c = 'Product2', External_Product_Code__c  = '');
        Product_Mapping__c prdMap3 = new Product_Mapping__c(Product_Name__c = '', External_Product_Code__c  = '333');
        Product_Mapping__c prdMap4 = new Product_Mapping__c(Product_Name__c = 'Product4', External_Product_Code__c  = '444');
        Product_Mapping__c prdMap4Dup = new Product_Mapping__c(Product_Name__c = 'Product4', External_Product_Code__c  = '4444');
        Product_Mapping__c prdMap5 = new Product_Mapping__c(Product_Name__c = 'Product5', External_Product_Code__c  = '555');
        Product_Mapping__c prdMap6 = new Product_Mapping__c(Product_Name__c = 'Product6', External_Product_Code__c  = '6666');
        Product_Mapping__c prdMap7 = new Product_Mapping__c(Product_Name__c = 'Product7', External_Product_Code__c  = '111');
        List<Product_Mapping__c> prdMaps = new List<Product_Mapping__c>{prdMap1, prdMap2, prdMap3, prdMap4, prdMap4Dup, prdMap5, prdMap6, prdMap7};
        insert prdMaps;    
        
        List<Id> productMapIds = new List<Id> {prdMap1.Id, prdMap2.Id, prdMap3.Id, prdMap4.Id, prdMap4Dup.Id, prdMap5.Id, prdMap6.Id, prdMap7.Id};
        Map<Id, Product_Mapping__c> actualResults = new map<Id, Product_Mapping__c>([select Id, Status__c, Note__c from Product_Mapping__c where Id in :productMapIds]);
        
        Test.stopTest();
        
        System.assertEquals('Applied', actualResults.get(prdMap1.Id).Status__c, 'ProductMap1 is not applied');
        System.assertEquals('Id:'+ prd1.Id, actualResults.get(prdMap1.Id).Note__c, 'ProductMap1 is applied to the wrong product');
        
        System.assertEquals('Skipped', actualResults.get(prdMap2.Id).Status__c, 'ProductMap2 is not skipped');
        System.assertEquals('External Product ID is null or empty', actualResults.get(prdMap2.Id).Note__c, 'ProductMap2 error');
        
        System.assertEquals('Skipped', actualResults.get(prdMap3.Id).Status__c, 'ProductMap3 is not skipped');
        System.assertEquals('Product name is null or empty', actualResults.get(prdMap3.Id).Note__c, 'ProductMap3 error');
        
        System.assertEquals('Skipped', actualResults.get(prdMap4.Id).Status__c, 'ProductMap4 is not skipped');
        System.assertEquals('Duplicate product name in the same batch', actualResults.get(prdMap4.Id).Note__c, 'ProductMap4 error');
        
        System.assertEquals('Skipped', actualResults.get(prdMap4Dup.Id).Status__c, 'ProductMap4Dup is not skipped');
        System.assertEquals('Duplicate product name in the same batch', actualResults.get(prdMap4Dup.Id).Note__c, 'ProductMap4Dup error');
        
        System.assertEquals('Skipped', actualResults.get(prdMap5.Id).Status__c, 'ProductMap5 is not Skipped');
        System.assertEquals('Duplicate product name found in SF(' + prd5.Id + ',' + prd5Dup.Id + ')', actualResults.get(prdMap5.Id).Note__c, 'ProductMap5 error');
        
        System.assertEquals('Skipped', actualResults.get(prdMap6.Id).Status__c, 'ProductMap6 is not skipped');
        System.assertEquals('Id:' + prd6.id + ', Already have External Product ID', actualResults.get(prdMap6.Id).Note__c, 'ProductMap6 error');
        
        System.assertEquals('Skipped', actualResults.get(prdMap7.Id).Status__c, 'ProductMap7 is not skipped');
        System.assertEquals('New product', actualResults.get(prdMap7.Id).Note__c, 'ProductMap7 error');
    }
}