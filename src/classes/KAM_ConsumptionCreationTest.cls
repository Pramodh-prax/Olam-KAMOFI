@isTest
public class KAM_ConsumptionCreationTest {
    
    static testMethod void testMethod1() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCity = 'Testcity';
        acc.BillingCountry = 'india';
        insert acc;
        Consumption__c cons = new Consumption__c();
        cons.Account__c=acc.Id;
        cons.Business_Unit__c = 'Cocoa';
        cons.Category__c='Cocoa Beans';
        cons.Volume_MT__c=100;
        cons.Year__c=String.valueOf(System.Today().year()-1);
        insert cons;
          List<Consumption__c> conList= new List<Consumption__c>();
        List<Brand_n_Comp__c>BnCList = new List<Brand_n_Comp__c>();
        for(Integer i=0 ;i <50;i++)
        {
            Consumption__c con = new Consumption__c();
            con.Account__c=acc.Id;
            con.Category__c='Cocoa Beans';
            con.Volume_MT__c=100;
            con.Year__c=String.valueOf(System.Today().year()-1);
            conList.add(con);
           
        }
          for(Integer j=0 ;j <50;j++)
        {
            Brand_n_Comp__c bc=new Brand_n_Comp__c();
            bc.Consumption__c=cons.Id;
                BnCList.add(bc);
        }
        
       try {
            if(conList.size()>0){
            insert conList;
            }
            if(BnCList.size()>0){
               
                insert BnCList;
            }
            
         
        } catch(Exception e) {
            System.debug(e);
        }
        Test.startTest();

            KAM_ConsumptionCreation obj = new KAM_ConsumptionCreation();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
        
        
        
    }

}