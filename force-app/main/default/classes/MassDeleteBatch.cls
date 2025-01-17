global class MassDeleteBatch implements Database.Batchable<SObject>, Database.Stateful {
    private String sObjectType;
    private String dateFilter;
    public MassDeleteBatch(String sObjectType, String dateFilter) {
        this.sObjectType = sObjectType;
        this.dateFilter = dateFilter;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM ' + sObjectType + ' WHERE DAY_ONLY(CreatedDate) < '+ dateFilter +' LIMIT 49999999';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        try {
            delete scope;
            Database.emptyRecycleBin(scope);
        } catch (DmlException e) {
            System.debug('Error deleting records: ' + e.getMessage());
        }
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch job finished successfully.');
    }
    
    public static void runBatch(String sObjectType, String dateFilter) {
        MassDeleteBatch batch = new MassDeleteBatch(sObjectType, dateFilter);
        Database.executeBatch(batch, 2000);
    }
}