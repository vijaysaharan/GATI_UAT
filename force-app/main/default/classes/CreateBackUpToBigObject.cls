global with sharing class CreateBackUpToBigObject implements Database.Batchable<SObject>, Database.Stateful {
    
    global string objectApiName;
    global List<String> listOfId = null;
    global Map<String,String> mapping;
    global String mappingParent = null;
    global String backUpto;
    global String childToBackUp;
    global string relatedField;
    global String whereClause = null;
    global List<String> idList = new List<String>();
    global List<Backup_Configuration__c> getconfig;
    global Integer successCount = 0;  
    global Integer errorCount = 0;  
    global string dailyBackUpId;
   // global string successCsvString = '';
    global string errorCsvString = '';
    global string backupType;
    global string backUpLogItemID = null;
    global string fieldToshowInError;
    global string errorLogId;

    global CreateBackUpToBigObject(String objectApiName, String whereClause, List<String> listOfId, String fieldToshowInError) {
        this.objectApiName = objectApiName;
        if(listOfId != null){
            this.listOfId = listOfId;
        }
        if(whereClause != null){
            this.whereClause = whereClause;
        }

        this.fieldToshowInError = fieldToshowInError;
       // this.successCsvString = '"Id","Success Message"\n';
        if(fieldToshowInError == null){
            this.errorCsvString = '"Id","Error Message"\n"';
        }else{
            this.errorCsvString = '"Id",'+fieldToshowInError+',"Error Message"\n';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        List<Backup_Configuration__c> getMapping = this.getconfig;
        if(!getMapping.isEmpty()){
            Map<String,String> fieldToBigFieldMap = (Map<String,String>)JSON.deserialize(getMapping[0].Mapping_S2B__c, Map<String,String>.class);
            this.mapping = fieldToBigFieldMap;
          
            this.backUpto = getMapping[0].Big_Object_Name__c;
           
            String query = 'Select ';
           

            query += String.join( new List<String>(fieldToBigFieldMap.keySet()), ',');
            query += ' from '+ this.objectApiName + whereClause ;
               
            return Database.getQueryLocator(query);

            
            // if(this.listOfId == null || this.listOfId.isEmpty()){
                
            //     query += ' from '+ this.objectApiName + whereClause ;
               
            //     return Database.getQueryLocator(query);
            // }else{
              
            //     query += ' from '+ this.objectApiName +' where '+this.relatedField + ' IN : listOfId';
              
            //     return Database.getQueryLocator(query);
            // }
        }
        return null;
    }

    global void execute (Database.BatchableContext bc, List<Sobject> listToBackup){
        SObjectType objectType = Schema.getGlobalDescribe().get(this.backUpto);
        List<SObject> listToInsert = new List<Sobject>();
        List<String> fieldNameList = new List<String>(this.mapping.keySet());
        Integer noOfFields = fieldNameList.size();
        Integer noOfRecords = listToBackup.size();
        Integer i = 0;
        Integer j = 0;
        if(objectType.newSObject()!=null){
            SObject backObj = objectType.newSObject();
            while (j<noOfFields){
                Object o;
                if(fieldNameList[j].contains('.')){
                    o = listToBackup[i].getSobject(fieldNameList[j].split('\\.')[0])!=null?listToBackup[i].getSobject(fieldNameList[j].split('\\.')[0]).get(fieldNameList[j].split('\\.')[1]):null;  
                }else{
                    o = listToBackup[i].get(fieldNameList[j]);
                }
                if(o != null){
                    if(o instanceOf Boolean){
                        backObj.put(this.mapping.get(fieldNameList[j]),String.valueOf(o));
                    }else{
                        backObj.put(this.mapping.get(fieldNameList[j]), o );
                    }
                }
                if(j == noOfFields-1){
                    if(i!=noOfRecords-1){

                        listToInsert.add(backObj);
                        backObj = objectType.newSObject();

                        j = 0;
                        i++;
                        continue;
                    }else{
                        listToInsert.add(backObj);
                    }
                }

            j++; 
            }
        }

        // need to insert the record here and get the id.

        if(!listToInsert.isEmpty()){
            if(!Test.isRunningTest()){
                Integer index = 0;
                List<Database.SaveResult> resList = Database.insertImmediate(listToInsert);
                listToInsert.clear();
                for(Database.SaveResult s : resList){
                     if(s.isSuccess()){
                         this.successCount += 1;
                         // we can remove the success csv to process more records.
                        // this.successCsvString += '"'+ listToBackup[index].Id +'","Record is successfully BackedUp"\n';
                     }else{
                         this.errorCount += 1;
                         this.errorCsvString += '"'+ listToBackup[index].Id +'",';
                         if(fieldToshowInError != null){
                            for(String field : fieldToshowInError.split(',')){
                                this.errorCsvString += '"' + (listToBackup[index].get(field)==null?'':listToBackup[index].get(field)) + '",';
                            }
                         } 
                         this.errorCsvString += '"'+ s.getErrors()[0].getMessage() +'"\n';
                     }
                     index++;
                }
            }
                // heap check
                if (Limits.getHeapSize() > 11500000) {
                    // implement logic to reduce
                    this.finalLogic();
                   // this.successCsvString = '"Id","Success Message"\n';
                    if(fieldToshowInError == null){
                        this.errorCsvString = '"Id","Error Message"\n"';
                    }else{
                        this.errorCsvString = '"Id",'+fieldToshowInError+',"Error Message"\n';
                    }
               }else{
                    Backup_Log__c backup = new Backup_Log__c();
                    if(this.backUpLogItemID == null){
                        backup.Object_Name__c = this.objectApiName;
                        backup.Record_fail_count__c = this.errorCount;
                        backup.Record_success_count__c = this.successCount;
                        backup.Backup_Log__c = this.dailyBackUpId;
                        backup.Timestamp__c = Datetime.now();
                        backup.Backup_Object_Name__c = this.backUpto;
                        backup.Type__c = this.backupType;
                        if(this.errorLogId != null)
                        backup.Retry_Log__c = this.errorLogId;
                        insert backup;
                        this.backUpLogItemID = backup.id;
                    }
                    backup.Record_fail_count__c = this.errorCount;
                    backup.Record_success_count__c = this.successCount;
                    backup.id = this.backUpLogItemID;
                    update backup;
               }
        }
       
    }
    
    global void finish(Database.BatchableContext bc){
        this.finalLogic();
    }


    global void finalLogic(){
        Backup_Log__c backup = new Backup_Log__c();
        if(this.backUpLogItemID == null){
            backup.Object_Name__c = this.objectApiName;
            backup.Record_fail_count__c = this.errorCount;
            backup.Record_success_count__c = this.successCount;
            backup.Backup_Log__c = this.dailyBackUpId;
            backup.Timestamp__c = Datetime.now();
            backup.Backup_Object_Name__c = this.backUpto;
            backup.Type__c = this.backupType;
            insert backup;
            this.backUpLogItemID = backup.id;
        }

        if(this.errorCount > 0){
            ContentVersion cvError = new ContentVersion();
            cvError.ContentLocation = 'S'; 
            cvError.Title = 'Error Record'+String.valueOf(this.errorCount)+'.csv'; 
            cvError.PathOnClient = 'Error Record'+String.valueOf(this.errorCount)+'.csv'; 
            cvError.VersionData = Blob.valueOf(this.errorCsvString); 
            cvError.FirstPublishLocationId = this.backUpLogItemID;
            insert cvError;
        }

        backup.Record_fail_count__c = this.errorCount;
        backup.Record_success_count__c = this.successCount;
        backup.id = this.backUpLogItemID;
        update backup;
    }
}