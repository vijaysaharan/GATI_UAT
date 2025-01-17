@isTest
public class MonthlyTradeDashboardBatchTest {
    @testSetup static void makeData(){
        Account testAccount = new Account(Name = 'Test Name');
        insert testAccount;
    }
    
    @isTest static void testMonthlyTradeDashboardBatch() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List<MonthlyTradeDashboard__c> testTrades = new List<MonthlyTradeDashboard__c>();
        Date lastMonthDate = System.today().addMonths(-1);
        String lastMonthYear = MonthlyTradeDashboardBatch.getMonthName(lastMonthDate);
        
        testTrades.add(new MonthlyTradeDashboard__c(
            ContractName__c = testAccount.Id,
            MonthYear__c = lastMonthYear
        ));
        insert testTrades;
        
        Test.startTest();
        MonthlyTradeDashboardBatch sc = new MonthlyTradeDashboardBatch();
        sc.execute(null);
        Test.stopTest();
    }
    
    @isTest static void testGetMonthName(){
        test.startTest();
        for(Integer i=1; i<=12 ; i++){
            MonthlyTradeDashboardBatch.monthName(i);
        }
        test.stopTest();
    }
}