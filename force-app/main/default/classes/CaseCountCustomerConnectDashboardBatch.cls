global class CaseCountCustomerConnectDashboardBatch implements Database.Batchable<sObject>,Schedulable, Database.AllowsCallouts, Database.Stateful {
    public String access_token;
    public String endpoint;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<CustomerDashboardMetadata__mdt> dashboardAuth = [SELECT Id, DeveloperName, ClientId__c, ClientSecret__c, 
                                                              Username__c, Password__c, Endpoint__c
                                                              FROM CustomerDashboardMetadata__mdt
                                                              WHERE DeveloperName = 'Customer_Dashboard'
                                                             ];
        if(dashboardAuth != null && dashboardAuth.size()>0){
         	access_token = CaseCountForCustomerDashboard.getAccessToken(dashboardAuth[0].ClientId__c,dashboardAuth[0].ClientSecret__c,dashboardAuth[0].Username__c,dashboardAuth[0].Password__c,dashboardAuth[0].Endpoint__c);
           	endpoint = dashboardAuth[0].Endpoint__c;
            System.debug('endpoint'+endpoint);
        }
        String query = 'SELECT AccountName__c,CasesClosedL3M__c,CasesClosedLM__c,CasesClosedMTD__c,CasesClosedYTD__c,CasesOpenL3M__c,CasesOpenLM__c,CasesOpenMTD__c,CasesOpenYTD__c FROM CustomerDashboard__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<CustomerDashboard__c> scope) {
        List<CustomerDashboard__c> updatedCustomerDashboards = new List<CustomerDashboard__c>();
        for(CustomerDashboard__c cd : scope){
            //MTD Closed
         	CaseCountForCustomerDashboard.InputWrapper inptMTDClosed = new CaseCountForCustomerDashboard.InputWrapper();
        	inptMTDClosed.accountId = cd.AccountName__c;
            inptMTDClosed.isClosed = true;
            inptMTDClosed.startDate = Date.newInstance(System.today().year(), System.today().month(), 1);
            inptMTDClosed.endDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(1).addDays(-1);
            inptMTDClosed.token = access_token;
            inptMTDClosed.Endpoint = endpoint;
            cd.CasesClosedMTD__c = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{inptMTDClosed})[0];
            //MTD Open
            CaseCountForCustomerDashboard.InputWrapper inptMTDOpen = new CaseCountForCustomerDashboard.InputWrapper();
        	inptMTDOpen.accountId = cd.AccountName__c;
            inptMTDOpen.isClosed = false;
            inptMTDOpen.startDate = Date.newInstance(System.today().year(), System.today().month(), 1);
            inptMTDOpen.endDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(1).addDays(-1);
            inptMTDOpen.token = access_token;
            inptMTDOpen.Endpoint = endpoint;
            cd.CasesOpenMTD__c = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{inptMTDOpen})[0];
            //YTD Closed
            CaseCountForCustomerDashboard.InputWrapper inptYTDClosed = new CaseCountForCustomerDashboard.InputWrapper();
        	inptYTDClosed.accountId = cd.AccountName__c;
            inptYTDClosed.isClosed = true;
            inptYTDClosed.startDate = System.today().month() >= 4 ? Date.newInstance(System.today().year(), 4, 1) : Date.newInstance(System.today().year() - 1, 4, 1);
            inptYTDClosed.endDate = System.today().month() >= 4 ? Date.newInstance(System.today().year() + 1, 3, 31) : Date.newInstance(System.today().year(), 3, 31);
            inptYTDClosed.token = access_token;
            inptYTDClosed.Endpoint = endpoint;
            cd.CasesClosedYTD__c = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{inptYTDClosed})[0];
            //YTD Open
            CaseCountForCustomerDashboard.InputWrapper inptYTDOpen = new CaseCountForCustomerDashboard.InputWrapper();
        	inptYTDOpen.accountId = cd.AccountName__c;
            inptYTDOpen.isClosed = false;
            inptYTDOpen.startDate = System.today().month() >= 4 ? Date.newInstance(System.today().year(), 4, 1) : Date.newInstance(System.today().year() - 1, 4, 1);
            inptYTDOpen.endDate = System.today().month() >= 4 ? Date.newInstance(System.today().year() + 1, 3, 31) : Date.newInstance(System.today().year(), 3, 31);
            inptYTDOpen.token = access_token;
            inptYTDOpen.Endpoint = endpoint;
            cd.CasesOpenYTD__c = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{inptYTDOpen})[0];
            //LM Closed
         	CaseCountForCustomerDashboard.InputWrapper inptLMClosed = new CaseCountForCustomerDashboard.InputWrapper();
        	inptLMClosed.accountId = cd.AccountName__c;
            inptLMClosed.isClosed = true;
            inptLMClosed.startDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(-1);
            inptLMClosed.endDate = Date.newInstance(System.today().year(), System.today().month(), 1).addDays(-1);
            inptLMClosed.token = access_token;
            inptLMClosed.Endpoint = endpoint;
            cd.CasesClosedLM__c = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{inptLMClosed})[0];
            //LM Open
            CaseCountForCustomerDashboard.InputWrapper inptLMOpen = new CaseCountForCustomerDashboard.InputWrapper();
        	inptLMOpen.accountId = cd.AccountName__c;
            inptLMOpen.isClosed = false;
            inptLMOpen.startDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(-1);
            inptLMOpen.endDate = Date.newInstance(System.today().year(), System.today().month(), 1).addDays(-1);
            inptLMOpen.token = access_token;
            inptLMOpen.Endpoint = endpoint;
            cd.CasesOpenLM__c = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{inptLMOpen})[0];
            //L3M Closed
            CaseCountForCustomerDashboard.InputWrapper inptL3MClosed = new CaseCountForCustomerDashboard.InputWrapper();
        	inptL3MClosed.accountId = cd.AccountName__c;
            inptL3MClosed.isClosed = true;
            inptL3MClosed.startDate = System.today().addMonths(-3).toStartOfMonth();
            inptL3MClosed.endDate = System.today().toStartOfMonth().addDays(-1);
            inptL3MClosed.token = access_token;
            inptL3MClosed.Endpoint = endpoint;
            cd.CasesClosedL3M__c = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{inptL3MClosed})[0];
            //L3M Open
            CaseCountForCustomerDashboard.InputWrapper inptL3MOpen = new CaseCountForCustomerDashboard.InputWrapper();
        	inptL3MOpen.accountId = cd.AccountName__c;
            inptL3MOpen.isClosed = false;
            inptL3MOpen.startDate = System.today().addMonths(-3).toStartOfMonth();
            inptL3MOpen.endDate = System.today().toStartOfMonth().addDays(-1);
            inptL3MOpen.token = access_token;
            inptL3MOpen.Endpoint = endpoint;
            cd.CasesOpenL3M__c = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{inptL3MOpen})[0];
            
            updatedCustomerDashboards.add(cd);
        }
        if(updatedCustomerDashboards != null && updatedCustomerDashboards.size()>0){
            update updatedCustomerDashboards;
        }
    } 
    global void finish(Database.BatchableContext BC) {
        System.debug('FINISHED');
    }
    global void execute(SchedulableContext SC){
	 database.executeBatch(new CaseCountCustomerConnectDashboardBatch(),6);
    }
}