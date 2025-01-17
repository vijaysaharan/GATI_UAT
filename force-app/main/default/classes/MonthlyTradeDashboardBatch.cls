public class MonthlyTradeDashboardBatch implements Database.Batchable<sObject>, Schedulable {
    public static String monthName(Integer monthIndex) {
        switch on monthIndex {
            when 1 {
                return 'JAN';
            }
            when 2 {
                return 'FEB';
            }
            when 3 {
                return 'MAR';
            }
            when 4 {
                return 'APR';
            }
            when 5 {
                return 'MAY';
            }
            when 6 {
                return 'JUN';
            }
            when 7 {
                return 'JUL';
            }
            when 8 {
                return 'AUG';
            }
            when 9 {
                return 'SEP';
            }
            when 10 {
                return 'OCT';
            }
            when 11 {
                return 'NOV';
            }
            when 12 {
                return 'DEC';
            }
            when else {
                return '';
            }
        }
    }
    
    public static String getMonthName(Date dateValue) {
        if(dateValue != null) {
            return monthName(dateValue.month()) + '-' + String.valueOf(dateValue.year());            
        }
        else{
            return '';
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date lastMonthDate = System.today().addMonths(-1);
        String monthYear = getMonthName(lastMonthDate);
        String query = 'SELECT ContractName__c FROM MonthlyTradeDashboard__c WHERE MonthYear__c = :monthYear';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<MonthlyTradeDashboard__c> scope){
        List<MonthlyTradeDashboard__c> monthlyTradesToInsert = new List<MonthlyTradeDashboard__c>();
        String currMonthYear = getMonthName(System.today());
        
        for(MonthlyTradeDashboard__c mtd : scope){
            MonthlyTradeDashboard__c newTrade = new MonthlyTradeDashboard__c();
            newTrade.ContractName__c = mtd.ContractName__c;
            newTrade.MonthYear__c = currMonthYear;
            monthlyTradesToInsert.add(newTrade);
        }
        
        if(monthlyTradesToInsert.size() > 0){
            Database.insert(monthlyTradesToInsert, false);
        }
    }
    
    public void finish(Database.BatchableContext BC){}
    
    public void execute(SchedulableContext SC) {
      Database.executeBatch(new MonthlyTradeDashboardBatch());
   }
}