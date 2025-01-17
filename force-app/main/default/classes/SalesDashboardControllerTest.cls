@isTest
public with sharing class SalesDashboardControllerTest {
    @isTest
    public static void getNBDCustomerData() {
        SalesDashboardController.WhereWrapper inpWrap = new SalesDashboardController.WhereWrapper();
        inpWrap.thisMonthStartDate = System.today().addDays(-1);
        inpWrap.thisMonthEndDate = System.today().addDays(1);
        inpWrap.lastMonthStartDate = System.today().addMonths(-1);
        inpWrap.lastMonthEndDate = System.today().addMonths(-1).addDays(1);
        inpWrap.userSelectedIds = new List<Id>{};
        inpWrap.zoneSelectedList = new List<String>{'BLRZ','BOMZ','CCUZ'};
        inpWrap.accountTypesSelected = new List<String>{'KEA','Strategic'};

        test.StartTest();
        Map<String,Integer> output = SalesDashboardController.getNBDCustomerData(inpWrap);
        test.StopTest();
    }
    @isTest
    public static void getTradeDataTest() {
        SalesDashboardController.WhereWrapperForTrade inpWrap = new SalesDashboardController.WhereWrapperForTrade();
        inpWrap.sortingMethod = 'desc';
        inpWrap.userSelectedIds = new List<Id>{};
        inpWrap.zoneSelectedList = new List<String>{'BLRZ','BOMZ','CCUZ'};
        inpWrap.accountTypesSelected = new List<String>{'KEA','Strategic'};
        inpWrap.monthYear = 'NOV-2024';

        test.StartTest();
        List<MonthlyTradeDashboard__c> output = SalesDashboardController.getTradeData(inpWrap);
        test.StopTest();
    }
    @isTest
    public static void getOpportunityClosedDataTest() {
        SalesDashboardController.WhereWrapperForOpportunity inpWrap = new SalesDashboardController.WhereWrapperForOpportunity();
        inpWrap.thisMonthStartDate = System.today().addDays(-1);
        inpWrap.thisMonthEndDate = System.today().addDays(1);
        inpWrap.lastMonthStartTillDate = System.today().addMonths(-1);
        inpWrap.lastMonthEndTillDate = System.today().addMonths(-1).addDays(1);
        inpWrap.userSelectedIds = new List<Id>{};

        test.StartTest();
        Map<String,Decimal> output = SalesDashboardController.getOpportunityClosedData(inpWrap);
        test.StopTest();
    }

    @isTest
    public static void getTargetsTest(){
        SalesDashboardController.whereWrapperTarget whereClause =  new SalesDashboardController.whereWrapperTarget();
        whereClause.salesKRAStartDate = System.today().addDays(-1);
        whereClause.salesKRAEndDate = System.today().addDays(1);
        whereClause.zoneSelectedList = new List<String>{'BLRZ','BOMZ','CCUZ'};
        whereClause.userSelectedIds = new List<Id>{};
        whereClause.productList = new List<String>{'AIR EXPRESS'};
        whereClause.accountTypes = new List<String>{'Retail','KEA'};

        test.startTest();
        SalesDashboardController.getTargets(whereClause);
        test.stopTest();
    }
}