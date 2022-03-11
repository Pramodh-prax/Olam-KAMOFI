@isTest
public class KAM_EngagementPlanCntlTest {
    public static final String COCOA_BU = 'Cocoa'; 
    
    @testSetUp
    static void createData () 
    {
        Account acc=new Account();
        acc.Name='DemoAccount';
        acc.Account_Type__c='Distributor';
        acc.BillingCountry='India';
        acc.BillingStreet='Pune-Mumbai road';
        insert acc;
        
        Account_Plans__c ap=new Account_Plans__c();
        ap.Account__c=acc.Id;
        ap.BU_Identifier__c= COCOA_BU;
        ap.StartDate__c=system.today();
        ap.EndDate__c=system.today().addDays (365);
        insert ap;
        
        //added by Sameer
        Access_Set__c access = OFI_TestDataFactory.createAccessSet('Country', null, 'SG', 'All', null, null, null, true);
        Access_Set_Assignment__c assign = OFI_TestDataFactory.createAccessSetAssignment(access.ID, UserInfo.getUserId(), //'Sales',
                                                                                        true);
        Teams__c team = OFI_TestDataFactory.createAccountTeam(acc.Id, UserInfo.getUserId(), 'All', 'Edit Access', //'Sales',
                                                              true, true);
    }
    
    private static List<Engagement_Plan_Line__c> createEngagementPlanLine () {
        Set<String> intTypes = new Set<String> {
            'C Level Engagement',
                'Commercial (Sales & Pricing)',
                'Finance (Structures & Payments)',
                'Innovation',
                'Risk (Solutions)',    
                'S&D (Market View Exchange)',
                'Sales & Ops Planning/Review',
                'Sustainability',
                'Other'
                };
                    List<String> frequencyList = new List<String> {
                        'Monthly',
                            'Quarterly',    
                            'Bi Monthly',
                            'Half Yearly',
                            'Need Based'
                            };
                                Integer index = 0;
        List<Engagement_Plan_Line__c> returnList = new List<Engagement_Plan_Line__c> ();
        for (String intType : intTypes) {
            Engagement_Plan_Line__c epl1 =new Engagement_Plan_Line__c();
            epl1.Type_of_Engagement__c= intType;
            epl1.Frequency__c=frequencyList [Math.mod(index, 4)];
            returnList.add (epl1);
            index ++;
        }
        return returnList;
    }
    
    
    public static testmethod void test_createEngagementPlans() {
        
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        
        Engagement_Plan__c ep=new Engagement_Plan__c();
        ep.Account__c=accPlans[0].Account__c;
        ep.Approval_Status__c='Approved';
        ep.Start_date__c= accPlans[0].StartDate__c;
        ep.End_Date__c=accPlans[0].EndDate__c;
        ep.Business_Unit__c= accPlans[0].BU_Identifier__c;
        
        List<Engagement_Plan_Line__c> planLines = createEngagementPlanLine ();
        
        String res = KAM_EngagementPlanCntl.createEngagementPlans(JSON.serialize(planLines) ,JSON.serialize(ep));    
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        System.assert((Boolean)resultMap.get ('success'), 'Exception thrown while processing record');
        
        System.assert(resultMap.containsKey ('engagementLines'), 'Invalid response failed to find engagementLines');
        System.assert(resultMap.containsKey ('engagementPlan'), 'Invalid response failed to find engagementPlan');    
        
        Engagement_Plan__c plan = (Engagement_Plan__c) JSON.deserialize(JSON.serialize(resultMap.get ('engagementPlan')), Engagement_Plan__c.class);
        
        System.assert(plan.Id != null, 'Insert / update failed');
        
        
        List<Engagement_Plan_Line__c> reLines = (List<Engagement_Plan_Line__c>)JSON.deserialize(JSON.serialize(resultMap.get ('engagementLines')), List<Engagement_Plan_Line__c>.class );
        System.assert(reLines.size () > 0);    
        
        Integer index = 0;
        for (Engagement_Plan_Line__c eachLine : reLines) {
            eachLine.Planned__c = index++;
        }
        
        res = KAM_EngagementPlanCntl.createEngagementPlans(JSON.serialize(reLines) ,JSON.serialize(plan));    
        
        resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        System.assert((Boolean)resultMap.get ('success'), 'Exception thrown while processing record');
        
        System.assert(resultMap.containsKey ('engagementLines'), 'Invalid response failed to find engagementLines');
        System.assert(resultMap.containsKey ('engagementPlan'), 'Invalid response failed to find engagementPlan');    
    }
    
    
    public static testmethod void testGetEngagementPlans() {
        
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        
        Engagement_Plan__c ep=new Engagement_Plan__c();
        ep.Account__c=accPlans[0].Account__c;
        ep.Approval_Status__c='Approved';
        ep.Start_date__c= accPlans[0].StartDate__c;
        ep.End_Date__c=accPlans[0].EndDate__c;
        ep.Business_Unit__c= accPlans[0].BU_Identifier__c;
        
        List<Engagement_Plan_Line__c> planLines = createEngagementPlanLine ();
        
        String res = KAM_EngagementPlanCntl.createEngagementPlans(JSON.serialize(planLines) ,JSON.serialize(ep));    
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        System.assert((Boolean)resultMap.get ('success'), 'Exception thrown while processing record');
        
        System.assert(resultMap.containsKey ('engagementLines'), 'Invalid r esponse failed to find engagementLines');
        System.assert(resultMap.containsKey ('engagementPlan'), 'Invalid response failed to find engagementPlan');    
        
        Engagement_Plan__c plan = (Engagement_Plan__c) JSON.deserialize(JSON.serialize(resultMap.get ('engagementPlan')), Engagement_Plan__c.class);
        
        System.assert(plan.Id != null, 'Insert / update failed');
        
        
        List<Engagement_Plan_Line__c> reLines = (List<Engagement_Plan_Line__c>)JSON.deserialize(JSON.serialize(resultMap.get ('engagementLines')), List<Engagement_Plan_Line__c>.class );
        System.assert(reLines.size () > 0);    
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'Engagement_Plan\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find Engagement_Plan component details ' );
        res = KAM_AccountPlanOverviewCntl.getDetails(
            JSON.serialize(accountPlanMetaData[0]),
            JSON.serialize(new Map<String, Object> {'accountPlan' => accPlans[0]})
        );
        List<Engagement_Plan__c> engagementPlans = (List<Engagement_Plan__c>) JSON.deserialize(res, List<Engagement_Plan__c>.class);
        System.assert(engagementPlans.size () > 0, 'Engagemet plan not found');
        System.assertEquals(ep.Account__c, engagementPlans[0].Account__c);
        System.assertEquals(ep.Start_date__c, engagementPlans[0].Start_date__c);
    }
    
    public static testmethod void testGetEngagementPlansInvalidKey() {
        
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'Engagement_Plan\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find Engagement_Plan component details ' );
        String res = KAM_AccountPlanOverviewCntl.getDetails(
            JSON.serialize(accountPlanMetaData[0]),
            JSON.serialize(new Map<String, Object> {'acountPlan' => accPlans[0]})
        );
        System.assert(res == null, 'Expected an null value, but actual contacts string returned');
    }
    
    public static testmethod void testGetEngagementPlansException() {
        List<Account_Plan_Overview_Component__mdt> accountPlanMetaData 
            = (List<Account_Plan_Overview_Component__mdt>) KAM_CustomMetaDataDAO.getCustomMetadataRecords (
                'SELECT Id, DeveloperName, Title__c, Order__c, ApexClass__c, Component_Name__c, Is_Active__c, Type__c FROM Account_Plan_Overview_Component__mdt WHERE DeveloperName = \'Engagement_Plan\'');
        System.assert(accountPlanMetaData.size () > 0, 'Unable to find Engagement_Plan component details ' );
        Boolean exceptionThrown = false;
        try {
            String res = KAM_AccountPlanOverviewCntl.getDetails(
                JSON.serialize(accountPlanMetaData[0]),
                JSON.serialize(new Map<String, Object> {'accountPlan' => null})
            );
        } catch (Exception e) {
            exceptionThrown =  true;
        } finally {
            System.assert(exceptionThrown, 'Expected an exception to be thrown, but there was no exception ');
        }
    }
    
    public static testmethod void test_refreshEngagementPlan() {
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        
        Engagement_Plan__c ep=new Engagement_Plan__c();
        ep.Account__c=accPlans[0].Account__c;
        ep.Approval_Status__c='Approved';
        ep.Start_date__c= accPlans[0].StartDate__c;
        ep.End_Date__c=accPlans[0].EndDate__c;
        ep.Business_Unit__c= accPlans[0].BU_Identifier__c;
        
        List<Engagement_Plan_Line__c> planLines = createEngagementPlanLine ();
        
        String res = KAM_EngagementPlanCntl.createEngagementPlans(JSON.serialize(planLines) ,JSON.serialize(ep));    
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        System.assert((Boolean)resultMap.get ('success'), 'Exception thrown while processing record');
        
        System.assert(resultMap.containsKey ('engagementLines'), 'Invalid r esponse failed to find engagementLines');
        System.assert(resultMap.containsKey ('engagementPlan'), 'Invalid response failed to find engagementPlan');    
        
        Engagement_Plan__c plan = (Engagement_Plan__c) JSON.deserialize(JSON.serialize(resultMap.get ('engagementPlan')), Engagement_Plan__c.class);
        
        System.assert(plan.Id != null, 'Insert / update failed');
        
        
        List<Engagement_Plan_Line__c> reLines = (List<Engagement_Plan_Line__c>)JSON.deserialize(JSON.serialize(resultMap.get ('engagementLines')), List<Engagement_Plan_Line__c>.class );
        System.assert(reLines.size () > 0);    
        
        Integer index = 0;
        for (Engagement_Plan_Line__c eachLine : reLines) {
            eachLine.Planned__c = index++;
        }
        
        res = KAM_EngagementPlanCntl.createEngagementPlans(JSON.serialize(reLines) ,JSON.serialize(plan));    
        
        resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        System.assert((Boolean)resultMap.get ('success'), 'Exception thrown while processing record');
        
        System.assert(resultMap.containsKey ('engagementLines'), 'Invalid response failed to find engagementLines');
        System.assert(resultMap.containsKey ('engagementPlan'), 'Invalid response failed to find engagementPlan'); 
        
        string epc= KAM_EngagementPlanCntl.refreshEngagementPlan(accPlans[0]);
        
        List<Engagement_Plan__c> engagementPlans = (List<Engagement_Plan__c>) JSON.deserialize(epc, List<Engagement_Plan__c>.class);
        System.assert(engagementPlans.size () > 0, 'Engagemet plan not found');
        System.assertEquals(ep.Account__c, engagementPlans[0].Account__c);
    }
    
    @isTest
    static void test_refreshEngagementPlanException() {
        Boolean exceptionThrown = false;
        try {
            string epc= KAM_EngagementPlanCntl.refreshEngagementPlan(null);
        } catch (Exception e) {
            exceptionThrown =  true;
        } finally {
            System.assert(exceptionThrown, 'Expected an exception to be thrown, but there was no exception ');
        }
    }
    public static testmethod void test_riseRequestForEngagementPlanEdit()
    {
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        
        
        Engagement_Plan__c ep=new Engagement_Plan__c();
        ep.Account__c=accPlans[0].Account__c;
        ep.Approval_Status__c='Approved';
        ep.Start_date__c= accPlans[0].StartDate__c;
        ep.End_Date__c=accPlans[0].EndDate__c;
        ep.Business_Unit__c= accPlans[0].BU_Identifier__c;
        
        List<Engagement_Plan_Line__c> planLines = createEngagementPlanLine ();
        
        String res = KAM_EngagementPlanCntl.createEngagementPlans(JSON.serialize(planLines) ,JSON.serialize(ep));    
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        System.assert((Boolean)resultMap.get ('success'), 'Exception thrown while processing record');
        
        System.assert(resultMap.containsKey ('engagementLines'), 'Invalid response failed to find engagementLines');
        System.assert(resultMap.containsKey ('engagementPlan'), 'Invalid response failed to find engagementPlan');    
        
        Engagement_Plan__c plan = (Engagement_Plan__c) JSON.deserialize(JSON.serialize(resultMap.get ('engagementPlan')), Engagement_Plan__c.class);
        
        System.assert(plan.Id != null, 'Insert / update failed');
        
        
        ep=new Engagement_Plan__c();
        ep.Id=plan.Id;
        
        res= KAM_EngagementPlanCntl.riseRequestForEngagementPlanEdit(JSON.serialize(ep));
        
        
        resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        //System.assert((Boolean)resultMap.get ('success'), 'Exception thrown while processing record');
        //System.assert(resultMap.containsKey ('engagementPlan'), 'Invalid response failed to find engagementPlan');   
        
        Engagement_Plan__c planUpdated = [SELECT Id, Approval_Status__c FROM Engagement_Plan__c WHERE Id =: plan.Id];
        //System.assert(planUpdated.Approval_Status__c == 'Pending', 'Update failed');    
        
        res= KAM_EngagementPlanCntl.riseRequestForEngagementPlanEdit(JSON.serialize(ep));
        resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        //System.assert(!((Boolean)resultMap.get ('success')), 'This record is not locked previously');
        //System.assert(((String)resultMap.get ('message')) == Label.KAM_Plan_Approval_Waiting_Message, 'invalid approval state');
        
    }
    
    public static testmethod void test_riseRequestForEngagementPlanEditCatch()
    {
        Engagement_Plan__c ep=new Engagement_Plan__c();
        String result= KAM_EngagementPlanCntl.riseRequestForEngagementPlanEdit(JSON.serialize(ep)); 
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        System.assert(!((Boolean)resultMap.get ('success')), 'Exception thrown');
    }
    
    public static testmethod void test_getEngangementPickListValuesByField()
    {
        List<KAM_Util.PicklistEntry> pickListEntries = KAM_EngagementPlanCntl.getEngangementPickListValuesByField('Engagement_Plan_Line__c', 'Type_of_Engagement__c', true, false);
        System.assert(!pickListEntries.isEmpty (), 'Values not found for the give pick list field');
        
        Boolean exceptionThrown = false;
        try {
            pickListEntries = KAM_EngagementPlanCntl.getEngangementPickListValuesByField('Engagement_Plan__c', 'Type_of_Engagement__c', true, false);
        } catch (Exception e) {
            exceptionThrown = true;
        } finally {
            System.assert(exceptionThrown, 'Expected an exception to be thrown, but there was no exception ');
        }
    }
    public static testmethod void test_getActiveFrequencyMapping()
    {
        KAM_EngagementPlanCntl.getActiveFrequencyMapping();
    }
    
    public static testmethod void test_getRecentlyViewed()
    {
        KAM_EngagementPlanCntl.getRecentlyViewed();
    }
    
    public static testmethod void test_search()
    {
        List<LookupSearchResult> epc= KAM_EngagementPlanCntl.search('Sameer', new List<id>());
    }
    public static testmethod void test_getEngagementPlansByAccountId()
    {
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        
        Engagement_Plan__c ep=new Engagement_Plan__c();
        ep.Account__c=accPlans[0].Account__c;
        ep.Approval_Status__c='Approved';
        ep.Start_date__c= accPlans[0].StartDate__c;
        ep.End_Date__c=accPlans[0].EndDate__c;
        ep.Business_Unit__c= accPlans[0].BU_Identifier__c;
        
        List<Engagement_Plan_Line__c> planLines = createEngagementPlanLine ();
        
        String res = KAM_EngagementPlanCntl.createEngagementPlans(JSON.serialize(planLines) ,JSON.serialize(ep));    
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(res);
        
        System.assert(resultMap.containsKey ('success'), 'Invalid response');
        
        Engagement_Plan__c plan = (Engagement_Plan__c) JSON.deserialize(JSON.serialize(resultMap.get ('engagementPlan')), Engagement_Plan__c.class);
        
        System.assert(plan.Id != null, 'Insert / update failed');
        
        List<Engagement_Plan__c> plans =  KAM_EngagementPlanCntl.getEngagementPlansByAccountId(accPlans[0].Account__c);
        
       // System.assert(!plans.isEmpty(), 'Unable to find the engagement plans');
       // System.assertEquals(plan.Id, plans[0].Id, 'Unable to find valid engagement plans');
    }
    
    public static testmethod void test_getEngagementPlansById()
    {
        
        String selYear=String.valueOf(System.today().year ());
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        //added bu by sameer
        Engagement_Plan__c plan = KAM_EngagementPlanCntl.createEngagementPlan(selYear, accPlans[0].Account__c,accPlans[0].BU_Identifier__c);
        
        System.assertEquals(selYear, plan.Year__c, 'Engagement plan year mismatch');
        
        String res = KAM_EngagementPlanCntl.getEngagementPlansById(plan.Id);
        List<Engagement_Plan__c>  plans = (List<Engagement_Plan__c> ) JSON.deserialize(res, List<Engagement_Plan__c>.class);
        System.assert(plans.size () > 0, 'Unable to find the plans');
        System.assertEquals(plan.Id, plans[0].Id, 'Record MisMatch');
    }
    public static testmethod void test_createEngagementPlan()
    {
        String selYear=String.valueOf(System.today().year ());
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        //added bu by sameer
        Engagement_Plan__c plan = KAM_EngagementPlanCntl.createEngagementPlan(selYear, accPlans[0].Account__c,accPlans[0].BU_Identifier__c);
       
        System.assertEquals(selYear, plan.Year__c, 'Engagement plan year mismatch');
    }
    
    @isTest
    static void test_createEngagementPlanError() {
        String selYear='1976';
        List<Account_Plans__c> accPlans = [SELECT Id, Account__c, BU_Identifier__c, StartDate__c, EndDate__c  
                                           FROM Account_Plans__c 
                                           WHERE CreatedDate = TODAY AND BU_Identifier__c =:COCOA_BU
                                           LIMIT 1];
        
        System.assert(accPlans.size () > 0, 'Unable to find account Plan');
        Boolean exceptionThrown = false;
        try {
            //added bu by sameer
        Engagement_Plan__c plan = KAM_EngagementPlanCntl.createEngagementPlan(selYear, accPlans[0].Account__c,accPlans[0].BU_Identifier__c);
        
        } catch (Exception e) {
            exceptionThrown = true;
        } finally {
            System.assert(exceptionThrown, 'Expected an exception to be thrown, but there was no exception ');
        } 
    }
    //added by sameer
    @isTest
    public static void test_getUserBU(){
        User u = KAM_EngagementPlanCntl.getUserBU();
        System.assert(u!=null, 'No user found');
    }
    //added by sameer
    @isTest
    public static void test_getAccountTeams(){
        Account acc = [Select Id, Name From Account];
        List<Teams__c> team = KAM_EngagementPlanCntl.getAccountTeams(acc.Id);
        System.debug('teamlist======>'+team);
        System.assert(!team.isEmpty(), 'No team member found');
    }
    //added by sameer
    @isTest
    public static void test_getcurrentUserAccountTeam(){
	Account acc = [Select Id, Name From Account];
        Teams__c team = KAM_EngagementPlanCntl.getcurrentUserAccountTeam(acc.Id);
        System.assert(team!=null, 'No team member found');        
    }
}