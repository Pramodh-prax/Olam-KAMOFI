@isTest
public class SalesAreaTriggerHandler_Test {
    
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
    
    @testSetup
    public static void prepare() {
        createTestUser();
        
        User user1 = [SELECT Id FROM User WHERE LastName = 'UnitTestCocoaUser1'];
        System.runAs (user1) {
            Account acc = new Account(Name = 'UNIT TEST account',
                                          BillingStreet = 'Test 1 street',
                                          BillingCountry = 'Singapore');
            insert acc;
       }
    }
    
    // Existing: 
    // New:      1
    // Expected result: Add 1
    @isTest
    public static void addNew() {
        Test.startTest();
        // Arrange
        Account acc = [SELECT Id FROM Account WHERE Name = 'UNIT TEST account'];
        
        // Action
        Sales_Area__c salesArea1 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        insert salesArea1;
        
        // Assert
        List<Sales_Area__c> currentSalesAreas = [Select Id from Sales_Area__c where Account_Name__c = :acc.Id];
        Test.stopTest();
        
        System.assertEquals(1, currentSalesAreas.size(), 'Number of the current sales areas are wrong');
        System.assertEquals(salesArea1.Id, currentSalesAreas[0].Id, 'salesArea1 is changed');
    }
    
    // Existing: 1 2
    // New:      1 2
    // Expected result: remains existing 1 2
    @isTest
    public static void sameThenDoNothing() {
        Test.startTest();
        // Arrange
        Account acc = [SELECT Id FROM Account WHERE Name = 'UNIT TEST account'];        
        Sales_Area__c salesArea1 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        Sales_Area__c salesArea2 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG42-OIL Beans-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        List<Sales_Area__c> existingSalesAreas = new List<Sales_Area__c>{salesArea1, salesArea2};
        insert existingSalesAreas;
        // Action
        Sales_Area__c salesArea1New = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        Sales_Area__c salesArea2New = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG42-OIL Beans-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        List<Sales_Area__c> newSalesAreas = new List<Sales_Area__c>{salesArea1New, salesArea2New};
        insert newSalesAreas;
        
        // Assert
        List<Sales_Area__c> currentSalesAreas = [Select Id from Sales_Area__c where Account_Name__c = :acc.Id];
        Test.stopTest();
        
        System.assertEquals(2, currentSalesAreas.size(), 'Number of the current sales areas are wrong');
        System.assertEquals(salesArea1.Id, currentSalesAreas[0].Id, 'salesArea1 is changed');
        System.assertEquals(salesArea2.Id, currentSalesAreas[1].Id, 'salesArea2 is changed');
    }
    
    // Existing: 1 2
    // New:      1 2(changed)
    // Expected result: keep   existing 1 and new 2
    //                  delete new 1 and existing 2
    @isTest
    public static void ifChangedThenUseNewOne() {
        Test.startTest();
        // Arrange
        Account acc = [SELECT Id FROM Account WHERE Name = 'UNIT TEST account'];
        
        Sales_Area__c salesArea1 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        Sales_Area__c salesArea2 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG42-OIL Beans-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        List<Sales_Area__c> existingSalesAreas = new List<Sales_Area__c>{salesArea1, salesArea2};
        insert existingSalesAreas;
        // Action
        Sales_Area__c salesArea1New = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        Sales_Area__c salesArea2New = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG42-OIL Beans-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa2',
                                                    Inco_Terms__c = 'IncoTermsCocoa2',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa2', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa2');
        List<Sales_Area__c> newSalesAreas = new List<Sales_Area__c>{salesArea1New, salesArea2New};
        insert newSalesAreas;
        
        // Assert
        List<Sales_Area__c> currentSalesAreas = [Select Id from Sales_Area__c where Account_Name__c = :acc.Id];
        Test.stopTest();
        
        System.assertEquals(2, currentSalesAreas.size(), 'Number of the current sales areas are wrong');
        System.assertEquals(salesArea1.Id, currentSalesAreas[0].Id, 'salesArea1 is changed');
        System.assertEquals(salesArea2New.Id, currentSalesAreas[1].Id, 'salesArea2 is not deleted');
    }
    
    @isTest
    public static void removeExisting() {
        Test.startTest();
        // Arrange
        Account acc = [SELECT Id FROM Account WHERE Name = 'UNIT TEST account'];
        Sales_Area__c salesArea1 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa');
        insert salesArea1;
        
        // Action
        Sales_Area__c salesArea2 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality',
                                                    Credit_Limit__c = 'CreditLimitCocoa',
                                                    Inco_Terms__c = 'IncoTermsCocoa',
                                                    Shipping_Conditions__c = 'ShippingConditionCocoa', 
                                                    Terms_of_Payment__c= 'TermsOfPaymentCocoa',
                                                    To_Delete__c = true);
        insert salesArea2;
        
        // Assert
        List<Sales_Area__c> currentSalesAreas = [Select Id from Sales_Area__c where Account_Name__c = :acc.Id];
        Test.stopTest();
        
        System.assertEquals(0, currentSalesAreas.size(), 'sales areas is not removed');
    }
    
    // Existing: 1 2 3
    // New:      2 3 4
    // Expected result: Remove 1 and Add 4
    /*@isTest
    public static void addNewAndDeleteUnmatch() {
        Test.startTest();
        // Arrange
        Account acc = new Account(Name = 'UNIT TEST account',
                                      BillingStreet = 'Test 1 street',
                                      BillingCountry = 'Singapore');
        insert acc;
        Sales_Area__c salesArea1 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality');
        Sales_Area__c salesArea2 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG42-OIL Beans-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality');
        Sales_Area__c salesArea3 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG43-OIL Products-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality');
        List<Sales_Area__c> existingSalesAreas = new List<Sales_Area__c>{salesArea1, salesArea2, salesArea3};
        insert existingSalesAreas;
        
        // Action
        Sales_Area__c salesArea2New = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG42-OIL Beans-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality');
        Sales_Area__c salesArea3New = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG43-OIL Products-Cocoa',
                                                    Distribution_Channel__c = '01-Export',
                                                    Division__c = '03-Cocoa and Speciality');
        Sales_Area__c salesArea4 = new Sales_Area__c(Account_Name__c = acc.Id, 
                                                    Sales_Org__c = 'SG41-OIL Processing-Cocoa',
                                                    Distribution_Channel__c = '02-Wholesale',
                                                    Division__c = '03-Cocoa and Speciality');
        List<Sales_Area__c> newSalesAreas = new List<Sales_Area__c>{salesArea2New, salesArea3New, salesArea4};
        insert newSalesAreas;
        
        // Assert
        List<Sales_Area__c> currentSalesAreas = [Select Id from Sales_Area__c where Account_Name__c = :acc.Id];
        Test.stopTest();
        
        System.assertEquals(3, currentSalesAreas.size(), 'Number of the current sales areas are wrong');
        System.assertEquals(salesArea2.Id, currentSalesAreas[0].Id, 'salesArea2 is changed');
        System.assertEquals(salesArea3.Id, currentSalesAreas[1].Id, 'salesArea3 is changed');
        System.assertEquals(salesArea4.Id, currentSalesAreas[2].Id, 'salesArea4 is changed');
    }*/
}