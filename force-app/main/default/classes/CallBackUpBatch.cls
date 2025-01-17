global with sharing class CallBackUpBatch {
   
    global void callBatchToBackUp(String objectApiName, String whereClauseFromSchedule, List<String> listOfId, String relatedFields, String dailyBackUpId, Integer days, String backupType){
        List<Backup_Configuration__c> getMapping = [Select Big_Object_Name__c,Mapping_S2B__c,Child_To_Backup__c,Parent_To_Backup__c,Fields_in_Error_Csv__c from Backup_Configuration__c where  Object_Name__c = :objectApiName];
        String whereClause = '';
        if(days !=null){
            if (backupType.equalsIgnoreCase('Scheduled')) {
                whereClause = ' where CreatedDate = N_DAYS_AGO:'+ String.valueOf(days); 
            }
            else{
                whereClause = ' where CreatedDate <> LAST_N_DAYS:'+ String.valueOf(days);
            }
            if(whereClauseFromSchedule != null && whereClauseFromSchedule !=''){
               whereClause += ' and ' + whereClauseFromSchedule;
            }
        }
        for(Backup_Configuration__c b : getMapping){
            CreateBackUpToBigObject c = new CreateBackUpToBigObject( objectApiName, whereClause, listOfId,  b.Fields_in_Error_Csv__c);
            c.getconfig = new List<Backup_Configuration__c>{b};
            if(relatedFields != null){
                c.relatedField = relatedFields;
            }
            c.backupType = 'Backup';
            c.dailyBackUpId = dailyBackUpId;
            Database.executeBatch(c,200);
        }
        
    }
}