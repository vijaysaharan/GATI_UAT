@isTest(SeeAllData=true)
public class CustomerConnectDashboardController_Test {
    @isTest
    public static void createTestData(){
        Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        Account acc2=TestFactory.getAccount('TestAccount10' , 'Retail', '521181', True);
        Account acc3=TestFactory.getAccount('TestAccount33' , 'MSME', '521191', True);
        Account acc4=TestFactory.getAccount('TestAccount33' , 'Strategic', '521191', True);
        List<Opportunity> keaOpp = TestFactory.getOpportunity(2,acc1.Id);
        insert keaOpp;
        List<Opportunity> retailOpp = TestFactory.getOpportunity(2,acc2.Id);
        insert retailOpp;
        List<Opportunity> msmeOpp = TestFactory.getOpportunity(2,acc3.Id);
        insert msmeOpp;
        List<Opportunity> strategicOpp = TestFactory.getOpportunity(2,acc4.Id);
        insert strategicOpp;
        
        Lead ld = [select id,OwnerId from lead limit 1];//TestFactory.getLead12('Test Lead');
        
        User u1 = [select id from user where userRole.name='BLR ZONAL RETAIL' limit 1];
        
        User u2 = [select id from user where userRole.name='NATIONAL KEA HEAD'limit 1];
        
        User u3 = [select id from user where userRole.name='BLR MSME BDM 1' limit 1];
        
        User u4 = [select id from user where userRole.name='BLR Zonal Strategic' limit 1];
        
        
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Call_Type__c = 'Sales Call';
        cc.Sub_Type__c = 'Contract Signoff';
        cc.Visit_Start_Date__c = System.now();
        cc.Visit_End_Date__c =System.now()+1;
        cc.Customer_Code__c = acc1.Id;
        cc.Visit_Status__c = 'Planned';
        cc.Visit_Mode__c = 'Virtual Meet';
        cc.Lead__c = ld.Id;
        cc.OwnerId = u1.Id;
        insert cc;
        
        Customer_Connect__c cc1 = new Customer_Connect__c();
        cc1.Call_Type__c = 'Sales Call';
        cc1.Sub_Type__c = 'Contract Signoff';
        cc1.Visit_Start_Date__c = System.now();
        cc1.Visit_End_Date__c =System.now()+1;
        cc1.Customer_Code__c = acc2.Id;
        cc1.Visit_Status__c = 'Planned';
        cc1.Visit_Mode__c = 'Virtual Meet';
        cc1.Lead__c = ld.Id;
        cc1.OwnerId = u2.Id;
        insert cc1;
        
        Customer_Connect__c cc2 = new Customer_Connect__c();
        cc2.Call_Type__c = 'Sales Call';
        cc2.Sub_Type__c = 'Contract Signoff';
        cc2.Visit_Start_Date__c = System.now();
        cc2.Visit_End_Date__c =System.now()+1;
        cc2.Customer_Code__c = acc3.Id;
        cc2.Visit_Status__c = 'Planned';
        cc2.Visit_Mode__c = 'Virtual Meet';
        cc2.Lead__c = ld.Id;
        cc2.OwnerId = u3.Id;
        insert cc2;
        
        Customer_Connect__c cc3 = new Customer_Connect__c();
        cc3.Call_Type__c = 'Sales Call';
        cc3.Sub_Type__c = 'Contract Signoff';
        cc3.Visit_Start_Date__c = System.now();
        cc3.Visit_End_Date__c =System.now()+1;
        cc3.Customer_Code__c = acc4.Id;
        cc3.Visit_Status__c = 'Planned';
        cc3.Visit_Mode__c = 'Virtual Meet';
        cc3.Lead__c = ld.Id;
        cc3.OwnerId = u4.Id;
        insert cc3;
        
        Customer360__c c360 = new Customer360__c();
        c360.GATI_Company_Code__c = '102';
        c360.Customer_Code__c = acc1.Id;
        c360.MTD__c = 4900;
        c360.Customer360_Id__c = 'a03p000000CdjcJ';
        insert c360;
        Customer360__c c3601= new Customer360__c();
        c3601.GATI_Company_Code__c = '102';
        c3601.Customer_Code__c = acc2.Id;
        c3601.MTD__c = 4900;
        c3601.Customer360_Id__c = 'a03p000000CdjcK';
        insert c3601;
        Customer360__c c3602 = new Customer360__c();
        c3602.GATI_Company_Code__c = '102';
        c3602.Customer_Code__c = acc3.Id;
        c3602.MTD__c = 4900;
        c3602.Customer360_Id__c = 'a03p000000CdjcL';
        insert c3602;
        Customer360__c c3603 = new Customer360__c();
        c3603.GATI_Company_Code__c = '102';
        c3603.Customer_Code__c = acc4.Id;
        c3603.MTD__c = 4900;
        c3603.Customer360_Id__c = 'a03p000000CdjcM';
        insert c3603;
        
        Test.startTest();
        CustomerConnectDashboardController.dummy();
      	CustomerConnectDashboardController.getPicklistValue('Q1','2021-2022');
        CustomerConnectDashboardController.getPicklistValue('Q2','2021-2022');
        CustomerConnectDashboardController.getPicklistValue('Q3','2021-2022');
        CustomerConnectDashboardController.getPicklistValue('Q4','2021-2022');
       
        CustomerConnectDashboardController.getCustmoer360();
        CustomerConnectDashboardController.fetchOpprtunityData('Q1','2021-2022');
        CustomerConnectDashboardController.fetchOpprtunityData('Q2','2021-2022');
        CustomerConnectDashboardController.fetchOpprtunityData('Q3','2021-2022');
        CustomerConnectDashboardController.fetchOpprtunityData('Q4','2021-2022');
        CustomerConnectDashboardController.opportunitySignedAvgDays();
        CustomerConnectDashboardController.getAccountWithCustomer360();
        CustomerConnectDashboardController.getPromiseRevenue();
        Test.stopTest();
    }
    
}