public with sharing class DeleteSobjectByPolicy implements Database.Batchable<SObject>,Database.Stateful {
    
    public String objectName;
    public Integer deleteDays;
    public String dailyBackUpId;
    Integer deleteCount = 0;
    Integer deleteErrorCount = 0;
    public String whereClause = '';

    public Database.QueryLocator start(Database.BatchableContext bc){
        if(this.whereClause == null || this.whereClause == ''){
            return Database.getQueryLocator('Select ID from ' + this.objectName + ' where CreatedDate !=  LAST_N_DAYS:' + String.valueOf(this.deleteDays));
        }else{
            return Database.getQueryLocator('Select ID from ' + this.objectName + ' where CreatedDate !=  LAST_N_DAYS:' + String.valueOf(this.deleteDays) + ' AND ' + this.whereClause);
        }
        
    }

    public void execute(Database.BatchableContext bc, List<SObject> recordTodelete){
        List<Database.DeleteResult> result = Database.deleteImmediate(recordTodelete);
        // This is log have to made in finish
        for(Database.DeleteResult res : result){
            if(res.isSuccess()){
                this.deleteCount += 1;
            }else{
                this.deleteErrorCount +=1;
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        // log will be made if needed.
        System.debug('All child will be deleted here but for some reason in schedular we will run it for all policy');
        Backup_Log__c backup = new Backup_Log__c();
        backup.Object_Name__c = this.objectName;
        backup.Record_fail_count__c = this.deleteErrorCount;
        backup.Record_success_count__c = this.deleteCount;
        backup.Backup_Log__c = this.dailyBackUpId;
        backup.Timestamp__c = Datetime.now();
        backup.Type__c = 'Delete Original';
        insert backup;

        // List<ContentVersion> listToInsert = new List<ContentVersion>();

        // ContentVersion cvSuccess = new ContentVersion();
        // cvSuccess.ContentLocation = 'S'; 
        // cvSuccess.Title = 'Success Record.csv'; 
        // cvSuccess.PathOnClient = 'Success Record.csv'; 
        // cvSuccess.VersionData = Blob.valueOf(this.dele); 
        // cvSuccess.FirstPublishLocationId = backup.Id;
        // listToInsert.add(cvSuccess);

        // ContentVersion cvError = new ContentVersion();
        // cvError.ContentLocation = 'S'; 
        // cvError.Title = 'Error Record.csv'; 
        // cvError.PathOnClient = 'Error Record.csv'; 
        // cvError.VersionData = Blob.valueOf(this.errorCsvString); 
        // cvError.FirstPublishLocationId = backup.Id;
        // listToInsert.add(cvError);

        // insert listToInsert;
    }

}