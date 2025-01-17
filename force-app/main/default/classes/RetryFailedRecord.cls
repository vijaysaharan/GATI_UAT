public with sharing class RetryFailedRecord {
    @AuraEnabled
    public static string getRelatedFileIds(String recordId){
        try {
            return JSON.serialize([select  id from ContentVersion  where FirstPublishLocationId = :recordId ]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getBigObjName(String recordId){
        try {
            List<Backup_Log__c> bList = [Select Backup_Object_Name__c, 	Backup_Log__c from Backup_Log__c where Id = :recordId];
            return  JSON.serialize(bList[0]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getCsvData(String csvId){
        try {
            List<ContentVersion> cv = [select VersionData from ContentVersion where Id = :csvId];
            return cv[0].VersionData.toString();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void callbackupBatch(List<String> recordIdList, String backupLog){
        try {
            System.debug(recordIdList.size());
            Backup_Log__c bl = (Backup_Log__c)JSON.deserialize(backupLog, Backup_Log__c.class );
            String whereclause  = ' where Id in ( ' + String.join(recordIdList, ',') + ' )';
            // Daily_Backup_Log__c d = new Daily_Backup_Log__c();
            // d.Timestamp__c = DateTime.now();
            // d.Type__c = 'Backup';
            // insert d;
            List<Backup_Configuration__c> getMapping = [Select Object_Name__c,Big_Object_Name__c,Mapping_S2B__c,Child_To_Backup__c,Parent_To_Backup__c,Fields_in_Error_Csv__c from Backup_Configuration__c where Big_Object_Name__c = : bl.Backup_Object_Name__c ];
            for(Backup_Configuration__c b : getMapping){
                CreateBackUpToBigObject c = new CreateBackUpToBigObject( b.Object_Name__c , whereClause, null,  b.Fields_in_Error_Csv__c);
                c.getconfig = new List<Backup_Configuration__c>{b};
                c.backupType = 'Retry';
                c.dailyBackUpId = bl.Backup_Log__c;
                c.errorLogId = bl.Id;
                if(!test.isRunningTest())
                Database.executeBatch(c,200);
            }
            bl.Retried__c = true;
            update bl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}