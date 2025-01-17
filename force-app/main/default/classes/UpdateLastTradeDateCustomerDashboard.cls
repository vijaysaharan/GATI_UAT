public with sharing class UpdateLastTradeDateCustomerDashboard implements Database.Batchable<sObject>,Schedulable, Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT AccountName__c, LastTradeAmount__c, LastTradeDate__c FROM CustomerDashboard__c';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<CustomerDashboard__c> scope){
      List<AggregateResult> aggrigateResult = [SELECT MAX(Last_Trade_Date__c) LastDate FROM Customer360__c 
                                                WHERE (Customer_Code__c =: scope[0].AccountName__c  OR Customer_Code__r.ParentId =: scope[0].AccountName__c)
                                               ];      
      Integer month = Date.valueOf(aggrigateResult[0].get('LastDate')).month();
      Integer year = Date.valueOf(aggrigateResult[0].get('LastDate')).year();
      Date monthStart = Date.newInstance(year, month, 1);
      Date monthEnd = monthStart.addMonths(1).addDays(-1);
      List<AggregateResult> aggrigateResultMTD = [SELECT SUM(MTD__c) MTD__c FROM Customer360__c 
                                                WHERE (Customer_Code__c =: scope[0].AccountName__c  OR Customer_Code__r.ParentId =: scope[0].AccountName__c)
                                                AND As_on_date__c >= :monthStart
                                                AND As_on_date__c <= :monthEnd
                                               ];
      if(aggrigateResult != null && aggrigateResult.size() > 0){
        scope[0].LastTradeDate__c = Date.valueOf(aggrigateResult[0].get('LastDate'));
      }
      if(aggrigateResultMTD != null && aggrigateResultMTD.size() > 0){
        scope[0].LastTradeAmount__c = (Decimal) aggrigateResultMTD[0].get('MTD__c');
      }
      update scope[0];
    }
    public void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            UpdateSalesDashboardUsers sc = new UpdateSalesDashboardUsers();
            sc.execute(null);
        }
    }
    public void execute(SchedulableContext SC){
        database.executeBatch(new UpdateLastTradeDateCustomerDashboard(),1);
    }
}