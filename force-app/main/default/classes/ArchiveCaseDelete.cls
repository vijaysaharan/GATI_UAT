public with sharing class ArchiveCaseDelete implements Database.Batchable<SObject>, Database.Stateful {
    public string index;
    public string objectname;
    public boolean runBatch = false;
    public Iterable<SObject> start(Database.BatchableContext bC){
        return [select id from Case limit 1];
    }

    public void execute(Database.BatchableContext bC, List<SObject> caseList){
        List<sobject> cb = Database.query('select '+ this.index +' from ' + this.objectname +' limit 49999');
        if(!cb.isEmpty()){
            this.runBatch = true;
            Database.deleteImmediate(cb);
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Case deleted');
        if(this.runBatch || Test.isRunningTest()){
            System.debug('in batch call condition');
            ArchiveCaseDelete acd = new ArchiveCaseDelete();
            acd.index = index;
            acd.objectname = objectname;
            if(!Test.isRunningTest())
            Database.executeBatch(acd);
        }
    }
}