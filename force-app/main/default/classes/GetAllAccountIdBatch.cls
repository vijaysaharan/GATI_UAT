public with sharing class GetAllAccountIdBatch implements Database.Batchable<SObject>,Database.Stateful{
    Integer i;
    public Boolean isfilter;
    // Map<Integer,List<String>> accIdLists;
    List<String> allaccId;
    public Date toDate;
    public Date fromDate;
    public GetAllAccountIdBatch(){
        this.i = 0;
        // this.accIdLists = new Map<Integer,List<String>>();
        this.allaccId =  new List<String>();
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('Select Id from Account');
    }
    public void execute (Database.BatchableContext bc, List<Sobject> accList){
        // List<String> tempIdList = new List<String>();
        for(Sobject s : accList){
            this.allaccId.add(s.Id);
        }
        // this.accIdLists.put(this.i, tempIdList);
        // this.i++;
    }

    public void finish(Database.BatchableContext bc){

        if(!this.isfilter){
            List<Backup_Ploicy__c> policyList = [select Object_Name__c, Remove_Backup_after_DAYS__c, Backup_after_DAYS__c from Backup_Ploicy__c where Object_Name__c = 'Case'];
            if(!policyList.isEmpty()){  
                List<Backup_Configuration__c> configList = [select Big_Object_Index__c, Big_Object_Name__c,Object_Name__c,Mapping_S2B__c,Child_To_Backup__c  from Backup_Configuration__c WHERE Object_Name__c = 'Case'];


                Map<String,Integer> mxaDaysMap = new Map<String,Integer>();
                for(Backup_Ploicy__c bp : policyList){
                    if(mxaDaysMap.containsKey(bp.Object_Name__c)){
                        if(mxaDaysMap.get(bp.Object_Name__c) < Integer.valueOf(bp.Remove_Backup_after_DAYS__c + bp.Backup_after_DAYS__c)){
                            mxaDaysMap.put(bp.Object_Name__c,Integer.valueOf(bp.Remove_Backup_after_DAYS__c + bp.Backup_after_DAYS__c));
                        }
                    }else{
                        mxaDaysMap.put(bp.Object_Name__c, Integer.valueOf(bp.Remove_Backup_after_DAYS__c + bp.Backup_after_DAYS__c));
                    }
                }


                if(!configList.isEmpty()){
                    //this is not need when the index is created date
                    // this will be called by batch
                    // Map<id,Account> accMap = new MAp<id,Account>([select id from Account limit 49000]);
                    // List<String> accParentList = new List<String>();
                    // for(id i : accMap.keySet()){
                    //     accParentList.add(i);
                    // }
                    
                    Daily_Backup_Log__c d = new Daily_Backup_Log__c();
                    d.Timestamp__c = DateTime.now();
                    d.Type__c = 'Delete Backup';
                    insert d;
                    for(Backup_Configuration__c config : configList){
                        // for(Integer i : this.accIdLists.keySet()){
                            DeleteBigObjectByPolicy deleteBatch = new DeleteBigObjectByPolicy();
                            deleteBatch.backupLogItemId = null;
                            deleteBatch.dailyBackupId = d.Id;
                            deleteBatch.forConfig = config;
                            deleteBatch.isChildBatch = false;
                            // deleteBatch.parentIdList = this.accIdLists.get(i);
                            deleteBatch.parentIdList = this.allaccId;
                            deleteBatch.dayCount = mxaDaysMap.get(config.Object_Name__c);
                            Database.executeBatch(deleteBatch,1);
                        // }
                    }
                }
            }
        }else{
            List<Backup_Configuration__c> cl = [select Big_Object_Index__c, Big_Object_Name__c, Object_Name__c, Mapping_S2B__c,Mapping_B2S__c from Backup_Configuration__c where Object_Name__c = 'Case' ];
            CreateCsvFromFilter c = new CreateCsvFromFilter(fromDate, (toDate+1),allaccId, cl[0]);
            c.fromDateInQuery = fromDate;
            c.toDateInQuery = ((Datetime)fromDate).addHours(Integer.valueOf(System.Label.queryHours));
            Database.executeBatch(c, 1);
        }
    }
}