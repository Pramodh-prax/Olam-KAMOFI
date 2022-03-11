@isTest
public class OpportunityVolumeRollUpServiceTest {
    
    @testSetup
    public static void createData()
    {
       
       PriceBook2 pb = new PriceBook2();
        pb.Name = 'Custom PB';
        pb.IsActive = true;            
        insert pb;

        Product2 product1 = creaeProduct ('P1', 'Some desc', 'SFDC-123', '03-Cocoa and Speciality', 'Cocoa Liquor', 'Natural', null, '1');
        Product2 product2 = creaeProduct ('P1', 'Some desc', 'SFDC-123', '03-Cocoa and Speciality', 'Cocoa Beans', null, null, '2');
        insert new List<Product2> {product1, product2};

        PricebookEntry pbe1 = createPriceBookEntry(product1, pb);
        PricebookEntry pbe2 = createPriceBookEntry(product2, pb);
        insert new List<PricebookEntry> {pbe1, pbe2};
        

        Account acc=new Account();
        acc.Name='Test';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;

        Opportunity newOpp=new Opportunity();
        newOpp.AccountId=acc.Id;
        newOpp.Name='Sample opp';
        newOpp.CloseDate=system.today().addDays(10);
        newOpp.Business_Unit__c='Cocoa';
        newOpp.StageName='Offering';
        newOpp.RecordTypeId=OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID;
        newOpp.Pricebook2Id = pb.Id;

        Opportunity newOpp1=new Opportunity();
        newOpp1.AccountId=acc.Id;
        newOpp1.Name='Sample opp';
        newOpp1.CloseDate=system.today().addDays(10);
        newOpp1.Business_Unit__c='Cocoa';
        newOpp1.StageName='Closing Won';
        newOpp1.RecordTypeId=OpportunityConstants.DEFEND_OPPORTUNITY_RECORD_TYPE_ID;
        newOpp1.Pricebook2Id = pb.Id;
        insert new List<Opportunity> {newOpp, newOpp1};


        OpportunityLineItem oppLineItem = createOpportunityLine (newOpp.Id, pbe1.Id);
        OpportunityLineItem oppLineItem1 = createOpportunityLine (newOpp.Id, pbe2.Id);

        OpportunityLineItem oppLineItem2 = createOpportunityLine (newOpp1.Id, pbe1.Id);
        OpportunityLineItem oppLineItem3 = createOpportunityLine (newOpp1.Id, pbe2.Id);
        insert new List<OpportunityLineItem> {oppLineItem, oppLineItem1, oppLineItem2, oppLineItem3};

        
    }
    static OpportunityLineItem createOpportunityLine (Id oppId, Id pbeId) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = oppId;
        oppLineItem.PricebookEntryId = pbeId;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        oppLineItem.Sampling_Status__c='7';
        oppLineItem.UoM__c = 'G';
        oppLineItem.Quantity_of_Sample_Grams__c = 100;

        return oppLineItem;
    }
    static Product2 creaeProduct (String name, String description, String productCode, String productFamily, String category, String subCat, String subCat2, String devCode) {
        return new Product2 (
            Name = name,
            Description = description,
            ProductCode =  productCode,
            isActive = true,
            Family = productFamily,
            Product_Category__c = category,
            Product_Sub_Category__c = subCat,
            Product_Sub_Category_2__c = subCat2,
            Development_Code__c = devCode
        );
    }

    static PricebookEntry createPriceBookEntry (Product2 p, PriceBook2 pb) {
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pb.Id;
        standardPrice.Product2Id = p.Id;
        standardPrice.UseStandardPrice = false;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        
        return standardPrice;
    }

    public static testmethod void processClosedOpportunitiesTest()
    {
        OpportunityVolumeRollUpService oppVolume =OpportunityVolumeRollUpService.getInstance();
        System.assert(oppVolume!=null, 'No instance Found');
        
        Opportunity oldOpp=[select AccountId,Name,CloseDate,Business_Unit__c,StageName,RecordTypeId from Opportunity where StageName= 'Offering'  ];
        System.assert(oldOpp!=null, 'No opportunity Found');
         Map<Id, Opportunity> oldMap= new Map<Id, Opportunity>();
        oldMap.put(oldOpp.Id,oldOpp);
        list<Opportunity> newList=new list<Opportunity>();
        //oldOpp.StageName='Closing Won';
        Opportunity newOpp=[select AccountId,Name,CloseDate,Business_Unit__c,StageName,RecordTypeId from Opportunity where StageName= 'Closing Won'  ];
         System.assert(newOpp!=null, 'No opportunity Found');
        newOpp.Id=oldOpp.Id;
      
        newList.add(newOpp);
        Map<Id, Opportunity> newMap= new Map<Id, Opportunity>();
        newMap.put(newOpp.id,newOpp);
        system.debug(newList);
        system.debug(oldmap);
        oppVolume.processClosedOpportunities(newList, newMap, oldMap);
        /* list<Opportunity> newList1=new list<Opportunity>();
        //oldOpp.StageName='Closing Won';
        Opportunity newOpp1=[select AccountId,Name,CloseDate,Business_Unit__c,StageName,RecordTypeId from Opportunity where StageName= 'Closing Won'  ];
         System.assert(newOpp1!=null, 'No opportunity Found');
        
      
        newList.add(newOpp1);
        Map<Id, Opportunity> newMap1= new Map<Id, Opportunity>();
        newMap.put(newOpp1.id,newOpp1);
        Map<ID,Opportunity> oldMap1=new  Map<ID,Opportunity>();
         oppVolume.processClosedOpportunities(newList1, newMap1, oldMap1);*/
       
    } 
    

}