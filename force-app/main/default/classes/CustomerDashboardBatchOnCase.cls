public class CustomerDashboardBatchOnCase implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    public Date MTDStart;
    public Date MTDClose;
    public Date LMStart;
    public Date LMClose;
    public Date L3MStart;
    public Date L3MClose;
    public Date YTDStart;
    public Date YTDClose;
    public Date LAST12Start;
    public Date LAST12Close;
    
    public Id accId;
    public Boolean finishRun;
    
    public CustomerDashboardBatchOnCase(Id AccId,Boolean finishRun){
        this.accId = AccId;
        this.finishRun = finishRun;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        MTDStart = Date.newInstance(System.today().year(), System.today().month(), 1);
        MTDClose = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(1).addDays(-1);
        LMStart = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(-1);
        LMClose = Date.newInstance(System.today().year(), System.today().month(), 1).addDays(-1);
        L3MStart = System.today().addMonths(-3).toStartOfMonth();
        L3MClose = System.today().toStartOfMonth().addDays(-1);
        YTDStart = System.today().month() >= 4 ? Date.newInstance(System.today().year(), 4, 1) : Date.newInstance(System.today().year() - 1, 4, 1);
        YTDClose = System.today().month() >= 4 ? Date.newInstance(System.today().year() + 1, 3, 31) : Date.newInstance(System.today().year(), 3, 31);
        LAST12Start = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(-12);
        LAST12Close = Date.newInstance(System.today().year(), System.today().month(), 1).addDays(-1);
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
        String query = 'SELECT AccountId, Account.ParentId, IsClosed, CreatedDate, ClosedDate FROM Case WHERE RecordType.DeveloperName = \'Complaint\' AND (AccountId IN: accIds OR Account.ParentId IN: accIds) AND (DAY_ONLY(CreatedDate) >=: LAST12Start OR DAY_ONLY(ClosedDate) >=: LAST12Start OR DAY_ONLY(CreatedDate) >=: L3MStart OR DAY_ONLY(ClosedDate) >=: L3MStart)';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Case> scope){
        Map<Id,Integer> accountIdToCloseMTD = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToOpenMTD = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToCloseLM = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToOpenLM = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToCloseL3M = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToOpenL3M = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToCloseYTD = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToOpenYTD = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToCloseLAST12 = new Map<Id,Integer>();
        Map<Id,Integer> accountIdToOpenLAST12 = new Map<Id,Integer>();
        Set<Id> accountIds = new Set<Id>();
        List<CustomerDashboard__c> dashboardDataToUpdate = new List<CustomerDashboard__c>();
        for(Case cs : scope){
            Id key = null;
            if(cs.Account.ParentId != null){
                key = cs.Account.ParentId;
            }else{
                key = cs.AccountId;
            }
            accountIds.add(key);
            if(cs.IsClosed){
                //Closed Cases Count
                if(cs.ClosedDate.date() >= MTDStart && cs.ClosedDate.date() <= MTDClose){
                    //MTD Closed
                    if(accountIdToCloseMTD.containsKey(key)){
                        accountIdToCloseMTD.put(key, (accountIdToCloseMTD.get(key)+1));
                    }else{
                        accountIdToCloseMTD.put(key,1);
                    }
                }
                if(cs.ClosedDate.date() >= LMStart && cs.ClosedDate.date() <= LMClose){
                    //LM Closed
                    if(accountIdToCloseLM.containsKey(key)){
                        accountIdToCloseLM.put(key, (accountIdToCloseLM.get(key)+1));
                    }else{
                        accountIdToCloseLM.put(key,1);
                    }
                }
                if(cs.ClosedDate.date() >= L3MStart && cs.ClosedDate.date() <= L3MClose){
                    //L3M Closed
                    if(accountIdToCloseL3M.containsKey(key)){
                        accountIdToCloseL3M.put(key, (accountIdToCloseL3M.get(key)+1));
                    }else{
                        accountIdToCloseL3M.put(key,1);
                    }
                }
                if(cs.ClosedDate.date() >= YTDStart && cs.ClosedDate.date() <= YTDClose){
                    //YTD Closed 
                    if(accountIdToCloseYTD.containsKey(key)){
                        accountIdToCloseYTD.put(key, (accountIdToCloseYTD.get(key)+1));
                    }else{
                        accountIdToCloseYTD.put(key,1);
                    }
                }
                if(cs.ClosedDate.date() >= LAST12Start && cs.ClosedDate.date() <= LAST12Close){
                    //LAST 12 Months Closed 
                    if(accountIdToCloseLAST12.containsKey(key)){
                        accountIdToCloseLAST12.put(key, (accountIdToCloseLAST12.get(key)+1));
                    }else{
                        accountIdToCloseLAST12.put(key,1);
                    }
                }
            }
            //Open Cases Count
            if(cs.CreatedDate.date() >= MTDStart && cs.CreatedDate.date() <= MTDClose){
                //MTD Open
                if(accountIdToOpenMTD.containsKey(key)){
                    accountIdToOpenMTD.put(key, (accountIdToOpenMTD.get(key)+1));
                }else{
                    accountIdToOpenMTD.put(key,1);
                }
            }
            if(cs.CreatedDate.date() >= LMStart && cs.CreatedDate.date() <= LMClose){
                //LM Open
                if(accountIdToOpenLM.containsKey(key)){
                    accountIdToOpenLM.put(key, (accountIdToOpenLM.get(key)+1));
                }else{
                    accountIdToOpenLM.put(key,1);
                }
            }
            if(cs.CreatedDate.date() >= L3MStart && cs.CreatedDate.date() <= L3MClose){
                //L3M Open
                if(accountIdToOpenL3M.containsKey(key)){
                    accountIdToOpenL3M.put(key, (accountIdToOpenL3M.get(key)+1));
                }else{
                    accountIdToOpenL3M.put(key,1);
                }
            }
            if(cs.CreatedDate.date() >= YTDStart && cs.CreatedDate.date() <= YTDClose){
                //YTD Open 
                if(accountIdToOpenYTD.containsKey(key)){
                    accountIdToOpenYTD.put(key, (accountIdToOpenYTD.get(key)+1));
                }else{
                    accountIdToOpenYTD.put(key,1);
                }
            }
            if(cs.CreatedDate.date() >= LAST12Start && cs.CreatedDate.date() <= LAST12Close){
                //LAST 12 Months Open 
                if(accountIdToOpenLAST12.containsKey(key)){
                    accountIdToOpenLAST12.put(key, (accountIdToOpenLAST12.get(key)+1));
                }else{
                    accountIdToOpenLAST12.put(key,1);
                }
            }
        }
        List<CustomerDashboard__c> dashboardData = [SELECT AccountName__c,CasesClosedL3M__c,CasesClosedLM__c,CasesClosedMTD__c,
                                                    CasesClosedYTD__c,CasesOpenL3M__c,CasesOpenLM__c,CasesOpenMTD__c,
                                                    CasesOpenYTD__c,OpenAsOnDate__c,CasesClosedL12M__c,CasesOpenL12M__c 
                                                    FROM CustomerDashboard__c 
                                                    WHERE AccountName__c IN: accountIds
                                                   ];
        if(dashboardData != null && dashboardData.size() >0) {
            for(CustomerDashboard__c cd : dashboardData){
                if(accountIdToCloseMTD.containsKey(cd.AccountName__c)){
                    cd.CasesClosedMTD__c += accountIdToCloseMTD.get(cd.AccountName__c);
                }
                if(accountIdToCloseLM.containsKey(cd.AccountName__c)){
                    cd.CasesClosedLM__c += accountIdToCloseLM.get(cd.AccountName__c);
                }
                if(accountIdToCloseL3M.containsKey(cd.AccountName__c)){
                    cd.CasesClosedL3M__c += accountIdToCloseL3M.get(cd.AccountName__c);
                }
                if(accountIdToCloseYTD.containsKey(cd.AccountName__c)){
                    cd.CasesClosedYTD__c += accountIdToCloseYTD.get(cd.AccountName__c);
                }
                if(accountIdToOpenMTD.containsKey(cd.AccountName__c)){
                    cd.CasesOpenMTD__c += accountIdToOpenMTD.get(cd.AccountName__c);
                }
                if(accountIdToOpenLM.containsKey(cd.AccountName__c)){
                    cd.CasesOpenLM__c += accountIdToOpenLM.get(cd.AccountName__c);
                }
                if(accountIdToOpenL3M.containsKey(cd.AccountName__c)){
                    cd.CasesOpenL3M__c += accountIdToOpenL3M.get(cd.AccountName__c);
                }
                if(accountIdToOpenYTD.containsKey(cd.AccountName__c)){
                    cd.CasesOpenYTD__c += accountIdToOpenYTD.get(cd.AccountName__c);
                }
                if(accountIdToOpenLAST12.containsKey(cd.AccountName__c)){
                    cd.CasesOpenL12M__c += accountIdToOpenLAST12.get(cd.AccountName__c);
                }
                if(accountIdToCloseLAST12.containsKey(cd.AccountName__c)){
                    cd.CasesClosedL12M__c += accountIdToCloseLAST12.get(cd.AccountName__c);
                }
                dashboardDataToUpdate.add(cd);
            }
        }
        if(dashboardDataToUpdate != null && dashboardDataToUpdate.size()>0){
            update dashboardDataToUpdate;
        }
    }
    public void finish(Database.BatchableContext BC){
        //Batch Finished
        if(this.finishRun){
            database.executeBatch(new CalculateAsOnDateCaseDashboardBatch(null),2000);   
        }
    }
    public void execute(SchedulableContext SC){
        database.executeBatch(new CustomerDashboardBatchOnCase(this.accId,this.finishRun),2000);
    }
}