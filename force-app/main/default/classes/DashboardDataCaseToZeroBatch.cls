public class DashboardDataCaseToZeroBatch implements Database.Batchable<sObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT AccountName__c,OpenAsOnDate__c,CasesClosedL3M__c,CasesClosedLM__c,CasesClosedMTD__c,CasesClosedYTD__c,CasesOpenL3M__c,CasesOpenLM__c,CasesOpenMTD__c, CasesOpenYTD__c FROM CustomerDashboard__c';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<CustomerDashboard__c> scope){
        List<CustomerDashboard__c> dashboardToUpdate = new List<CustomerDashboard__c>();
        for (CustomerDashboard__c d : scope) {
            d.CasesClosedL3M__c = 0;
            d.CasesClosedLM__c = 0;
            d.CasesClosedMTD__c = 0;
            d.CasesClosedYTD__c = 0;
            d.CasesOpenL3M__c = 0;
            d.CasesOpenLM__c = 0;
            d.CasesOpenMTD__c = 0;
            d.CasesOpenYTD__c = 0;
            d.CasesClosedL12M__c = 0;
            d.CasesOpenL12M__c = 0;
            d.OpenAsOnDate__c = 0;
            d.X030Revenue__c = 0;
            d.X3190Revenue__c = 0;
            d.X91180Revenue__c = 0;
            d.X181365Revenue__c = 0;
            dashboardToUpdate.add(d);  
        }
        if(dashboardToUpdate != null && dashboardToUpdate.size() > 0){
            update dashboardToUpdate;
        }
    }
    public void finish(Database.BatchableContext BC){
        //FINISHED
        database.executeBatch(new CustomerDashboardBatchOnCase(null,true),2000);        
    }
    public void execute(SchedulableContext SC){
        database.executeBatch(new DashboardDataCaseToZeroBatch(),2000);
    }
}