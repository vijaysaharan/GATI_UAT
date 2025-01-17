global class CustomAccountTeamMemberCaseUpdate implements Database.Batchable<sObject> {
    String query;
    Map<ID,ID> mapAccountIdUserId = new Map<ID,ID>();
    Set<ID> setAccounts = new Set<ID>();
    global CustomAccountTeamMemberCaseUpdate(String queryString,Map<id, ID> getmapAccountIdUserId,Set<Id> getAccountIds) 
    {
        query = queryString;
        mapAccountIdUserId = getmapAccountIdUserId;
        setAccounts = getAccountIds;
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    // Execute method
    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<Case> updateLstOpenCases = new List<Case>();
        if(scope != null && scope.size() > 0){
            for(Case eachCase:scope){
                Case eachUpdateCase = new Case();
                eachUpdateCase.id = eachCase.id;
                eachUpdateCase.OwnerId = mapAccountIdUserId.get(eachCase.AccountId);
                updateLstOpenCases.add(eachUpdateCase);
            }
            system.debug('Update Case List = ' + updateLstOpenCases);
            if(updateLstOpenCases != null && updateLstOpenCases.size() > 0){
                update updateLstOpenCases;
            }
        }
        
    }  
    // Finish Method
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}