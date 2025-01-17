public class CalculateAsOnDateCaseDashboardBatch implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    public Id accId;
    public CalculateAsOnDateCaseDashboardBatch(Id AccId){
        this.accId = AccId;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<Id> accIds = new Set<Id>();
        List<CustomerDashboard__c> cusData = [SELECT AccountName__c 
                                              FROM CustomerDashboard__c
                                             ];
        if(cusData != null && cusData.size()>0 && accId == null){
            for(CustomerDashboard__c cdash : cusData){
                accIds.add(cdash.AccountName__c);
            }
        }
        else{
            accIds.add(accId);
        }
        String query =  'SELECT Id,AccountId, Account.ParentId FROM Case WHERE (AccountId IN : accIds OR Account.ParentId IN: accIds) AND IsClosed = false';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Case> scope){
        Map<Id,Integer> accountIdToAsOnDate = new Map<Id,Integer>();
        Set<Id> accountIds = new Set<Id>();
        List<CustomerDashboard__c> dashboardDataToUpdate = new List<CustomerDashboard__c>();
        for(Case cs : scope){
            Id key = null;
            if(cs.Account.ParentId != null){
                key = cs.Account.ParentId;
            }
            else{
                key = cs.AccountId;
            }
            accountIds.add(key);
            if(accountIdToAsOnDate.containsKey(key)){
                accountIdToAsOnDate.put(key, (accountIdToAsOnDate.get(key)+1));
            }else{
                accountIdToAsOnDate.put(key,1);
            }
        }
        List<CustomerDashboard__c> dashboardData = [SELECT AccountName__c,OpenAsOnDate__c 
                                                        FROM CustomerDashboard__c 
                                                        WHERE AccountName__c IN: accountIds
                                                    	FOR UPDATE
                                                        ];
        if(dashboardData != null && dashboardData.size() >0) {
            for(CustomerDashboard__c cd : dashboardData){
                if(accountIdToAsOnDate.containsKey(cd.AccountName__c)){
                    cd.OpenAsOnDate__c += accountIdToAsOnDate.get(cd.AccountName__c);
                }
                dashboardDataToUpdate.add(cd);
            }
        }
        if(dashboardDataToUpdate != null && dashboardDataToUpdate.size()>0){
            update dashboardDataToUpdate;
        }
    }
    public void finish(Database.BatchableContext BC){
        //FINISHED
        database.executeBatch(new InactiveContractBatchCalculator(),2000);
    }
    public void execute(SchedulableContext SC){
	 database.executeBatch(new CalculateAsOnDateCaseDashboardBatch(this.accId),2000);
    }
}