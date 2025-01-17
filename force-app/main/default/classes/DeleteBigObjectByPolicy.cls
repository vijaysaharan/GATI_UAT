public without sharing class DeleteBigObjectByPolicy implements Database.Batchable<SObject>,Database.Stateful {
    public String dailyBackupId; 
    public Integer deleteCount = 0;
    public Integer deleteErrorCount = 0;
    public List<String> parentIdList = null;
    boolean currentObjectFinished = true;
    List<String> recordDeletedThisBatch;
    public Integer dayCount;
    public Backup_Configuration__c forConfig;
    String deleteQuery;
    String fetchIdQuery;
    public Boolean isChildBatch = false;
    Map<String,String> sToB;
    public String backupLogItemId;
    List<String> parentListTopass = new List<String>();
    datetime dt;

    


    public Database.QueryLocator start(Database.BatchableContext bc){
        try{
           List<String> indexList = this.forConfig.Big_Object_Index__c.split(',');
            this.sToB = (Map<String,String>)JSON.deserialize(forConfig.Mapping_S2B__c , Map<String,String>.class);
            if(!indexList.isEmpty() && indexList.size() >= 2 ){
                if(!this.isChildBatch){
                    this.dt = Datetime.now() - this.dayCount;
                    this.deleteQuery = 'Select ' + this.forConfig.Big_Object_Index__c + ' from ' + this.forConfig.Big_Object_Name__c + ' where '+ indexList[0] + ' In : parentIdList ' + 'AND ' + indexList[1] + ' <= :dt limit 10000';  
                    this.fetchIdQuery = 'Select ' + this.sToB.get('Id') + ' from ' + forConfig.Big_Object_Name__c + ' where '+ indexList[0] + ' In : parentIdList '+ 'AND ' + indexList[1] + ' <= :dt limit 10000' ;
                }else{
                    this.deleteQuery = 'Select ' + this.forConfig.Big_Object_Index__c + ' from ' + this.forConfig.Big_Object_Name__c + ' where '+ indexList[0] + ' In : parentIdList ';  
                    this.fetchIdQuery = 'Select ' + this.sToB.get('Id') + ' from ' + forConfig.Big_Object_Name__c + ' where '+ indexList[0] + ' In : parentIdList ';
                }
                return Database.getQueryLocator('Select Id from case limit 1');
            }else{
               return null;
            } 
        }catch(Exception e){
            return Database.getQueryLocator('Select Id from case where CreatedDate = TODAY and CreatedDate != TODAY ');
        }  
       
    }

    public void execute(Database.BatchableContext bc, List<Sobject> dummy){
        List<SObject> parentIdList1 = Database.query(this.fetchIdQuery);
        if(!parentIdList1.isEmpty()){
            for(SObject sobj : parentIdList1){
                this.parentListTopass.add((String) sobj.get(this.sToB.get('Id')));
            }
        }
        List<SObject> deleteList = Database.query(this.deleteQuery);
        if(!deleteList.isEmpty()){
            this.currentObjectFinished = false;
            if(!Test.isRunningTest()){
                Database.deleteImmediate(deleteList);
                List<Database.DeleteResult> resList =  Database.deleteImmediate(deleteList);
                for(Database.DeleteResult res: resList){
                    if(res.isSuccess()){
                        this.deleteCount++;
                    }else{
                        this.deleteErrorCount++;
                    }
                }
            }
        }
            Backup_Log__c backup = new Backup_Log__c();
            if(this.backupLogItemId == null){
                backup.Object_Name__c = this.forConfig.Object_Name__c;
                //backup.Record_fail_count__c = this.deleteErrorCount;
                backup.Record_success_count__c = deleteList.size();
                backup.Backup_Log__c = this.dailyBackUpId;
                backup.Timestamp__c = Datetime.now();
                backup.Backup_Object_Name__c = this.forConfig.Big_Object_Name__c;
                backup.Type__c = 'Delete Backup';
                insert backup;
                this.backUpLogItemID = backup.id;
            }else{
                backup.Record_fail_count__c = this.deleteErrorCount;
                backup.Record_success_count__c = this.deleteCount;
                backup.Id = this.backupLogItemId;
                update backup;
            }  
        
    }

    public void finish(Database.BatchableContext bc){
        if(!this.currentObjectFinished || Test.isRunningTest()){
            DeleteBigObjectByPolicy deleteBatch = new DeleteBigObjectByPolicy();
            deleteBatch.backupLogItemId = this.backupLogItemId;
            deleteBatch.dailyBackupId = this.dailyBackupId;
            deleteBatch.deleteCount = this.deleteCount;
            deleteBatch.deleteErrorCount = this.deleteErrorCount;
            deleteBatch.forConfig = this.forConfig;
            deleteBatch.isChildBatch = false;
            deleteBatch.parentIdList = this.parentIdList;
           // deleteBatch.parentListTopass = this.parentListTopass;
            deleteBatch.dayCount = this.dayCount;
            if(!Test.isRunningTest())
            Database.executeBatch(deleteBatch,1);
        }
        if(this.forConfig.Child_To_Backup__c != null && this.forConfig.Child_To_Backup__c !=''){

            List<String> childString = this.forConfig.Child_To_Backup__c.split(',');
            List<String> childObjectName = new List<String>();

            if(!childString.isEmpty()){
                for(String s : childString){
                    List<String> objAndRelatedName = s.split(':');
                    childObjectName.add(objAndRelatedName[0]);
                }
            }

            if(!childObjectName.isEmpty()){
                List<Backup_Configuration__c> childConfig = [select Big_Object_Index__c, Big_Object_Name__c,Object_Name__c,Mapping_S2B__c ,Child_To_Backup__c from Backup_Configuration__c where Object_Name__c In :childObjectName];
                if(!childConfig.isEmpty()){
                    for(Backup_Configuration__c bConfig : childConfig){
                        DeleteBigObjectByPolicy deleteBatch = new DeleteBigObjectByPolicy();
                        deleteBatch.backupLogItemId = null;
                        deleteBatch.dailyBackupId = this.dailyBackupId;
                        deleteBatch.forConfig = bConfig;
                        deleteBatch.isChildBatch = true;
                        deleteBatch.parentIdList = this.parentListTopass;
                        Database.executeBatch(deleteBatch,1);
                    }
                }
            }
        }
    }
}