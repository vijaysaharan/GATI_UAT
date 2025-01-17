@isTest
public with sharing class IncentiveTest {
    @TestSetup
    static void makeData(){ 
        Account acct = new Account();
        acct.Name = 'Test';
        acct.Customer_Code__c = 45071002.102;
        acct.BillingPostalCode = '201301';
        acct.ShippingPostalCode = '201307';
        acct.Customer_Category__c = 'MSME';
        acct.OwnerId = UserInfo.getUserId();
        insert acct;

        Customer360__c c360 = new Customer360__c();
        c360.Customer_Code__c = acct.Id;
        c360.Product__c = 'SUR EXPRESS';
        c360.Customer360_Id__c = '12345678.102.Oct-22.SUR EXPRESS';
        c360.Month_Year__c = 'OCT-2022';
        c360.AccountOwner__c = UserInfo.getUserId();
        c360.As_on_date__c = System.today();
        insert c360;

        Customer360__c c360LastMonth = new Customer360__c();
        c360LastMonth.Customer_Code__c = acct.Id;
        c360LastMonth.Product__c = 'SUR EXPRESS';
        c360LastMonth.Customer360_Id__c = '12345678.102.Sep-22.SUR EXPRESS';
        c360LastMonth.Month_Year__c = 'SEP-2022';
        c360LastMonth.AccountOwner__c = UserInfo.getUserId();
        c360LastMonth.As_on_date__c = System.today().addMonths(-1);
        insert c360LastMonth;

        Customer360__c c360LastYear = new Customer360__c();
        c360LastYear.Customer_Code__c = acct.Id;
        c360LastYear.Product__c = 'SUR EXPRESS';
        c360LastYear.Customer360_Id__c = '12345678.102.Oct-21.SUR EXPRESS';
        c360LastYear.Month_Year__c = 'OCT-2021';
        c360LastYear.AccountOwner__c = UserInfo.getUserId();
        c360LastYear.As_on_date__c = System.today().addMonths(-4);
        insert c360LastYear;

        Customer360__c c360NullAccountOwner = new Customer360__c();
        c360NullAccountOwner.Customer_Code__c = acct.Id;
        c360NullAccountOwner.As_on_date__c = System.today().addMonths(-1);
        c360NullAccountOwner.Product__c = 'SUR EXPRESS';
        c360NullAccountOwner.Customer360_Id__c = '12345678.102.Oct-20.SUR EXPRESS';
        c360NullAccountOwner.Month_Year__c = 'OCT-2020';
        insert c360NullAccountOwner;

        Sales_KRA__c salesKRA1 = new Sales_KRA__c();
        //salesKRA1.Name = 'TestSales';
        salesKRA1.Month__c = '10';
        salesKRA1.Year__c = '2022';
        salesKRA1.Remarks__c = 'test sales kra';
        salesKRA1.Product__c = 'SUR EXPRESS';
        salesKRA1.Account_Type__c = 'MSME';
        salesKRA1.KAM_KAE__c = UserInfo.getUserId();
        salesKRA1.Zone__c = 'BOMZ';
        salesKRA1.Target__c = 0;
        salesKRA1.Staff_Code__c = [SELECT Staff_Code__c FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1].Staff_Code__c;
        insert salesKRA1;

        Integer monthToConsider = System.today().addMonths(-1).month();
        Integer yearToConsider = System.today().addMonths(-1).year();
        Sales_KRA__c salesKRA2 = new Sales_KRA__c();
        //salesKRA2.Name = 'TestSales';
        salesKRA2.Month__c = String.valueOf(monthToConsider);
        salesKRA2.Year__c = String.valueOf(yearToConsider);
        salesKRA2.Remarks__c = 'test sales kra';
        salesKRA2.Product__c = 'SUR EXPRESS';
        salesKRA2.Account_Type__c = 'MSME';
        salesKRA2.KAM_KAE__c = UserInfo.getUserId();
        salesKRA2.Zone__c = 'BOMZ';
        salesKRA2.Target__c = 0;
        salesKRA2.Staff_Code__c = [SELECT Staff_Code__c FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1].Staff_Code__c;
        insert salesKRA2;

        Incentive__c incentive = new Incentive__c();
        incentive.AccountType__c = 'Strategic & MSME';
        incentive.SalesExecutive__c = UserInfo.getUserId();
        incentive.Quarter__c = 'Q3';
        incentive.Year__c = '2024-2025';
        insert incentive;
    }

    @IsTest
    static void SalesKRARollupUpdateBatchRunMonthlyFalseTest(){
        Test.startTest();
        SalesKRARollupUpdateBatch b = new SalesKRARollupUpdateBatch();
        b.runMonthly = false;
        Database.executeBatch(b);
        Test.stopTest();
    }

    @IsTest
    static void SalesKRARollupUpdateBatchRunMonthlyTrueTest(){
        Test.startTest();
        SalesKRARollupUpdateBatch b = new SalesKRARollupUpdateBatch();
        Database.executeBatch(b);
        Test.stopTest();
    }

    @IsTest
    static void IncentiveUtilityGetMonthNameTest(){    
        Test.startTest();
        for (Integer i = 1; i <=13; i++ ) {
            IncentiveUtility.getMonthName(i);
        }
        Test.stopTest();   
    }

    @IsTest
    static void IncentiveUtilityRollupCalculationsTest(){    
        Test.startTest();
        IncentiveUtility.rollupCalculations(new List<Sales_KRA__c>());
        Test.stopTest();   
    }

    @IsTest
    static void Customer360AccountOwnerUpdateBatchTest(){
        Test.startTest();
        Customer360AccountOwnerUpdateBatch b = new Customer360AccountOwnerUpdateBatch();
        b.execute(null);
        Test.stopTest();
    }

    @IsTest
    static void getCurrentQuarterTest(){
        Test.startTest();
        IncentiveRollupBatch irb = new IncentiveRollupBatch();
        for (Integer i = 0; i < 13; i++) {
            irb.getCurrentQuarter(i);
        }
        Test.stopTest();
    }
}