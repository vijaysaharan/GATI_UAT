public class CaseBackupScheduleClass implements Schedulable {
    public void execute(SchedulableContext sc){
        List<Backup_Ploicy__c> casePolicy = [select Object_Name__c, Where_Clause__c, Backup_after_DAYS__c,Backup_Type__c from Backup_Ploicy__c];
        List<Backup_Ploicy__c> policyToUpdate = new List<Backup_Ploicy__c>();
        if(!casePolicy.isEmpty()){
            Daily_Backup_Log__c d = new Daily_Backup_Log__c();
            d.Timestamp__c = DateTime.now();
            d.Type__c = 'Backup';
            insert d;
            for(Backup_Ploicy__c b : casePolicy){
                CallBackUpBatch callBatch = new CallBackUpBatch();
                callBatch.callBatchToBackUp(b.Object_Name__c, b.Where_Clause__c, null, null, d.Id, Integer.valueOf(b.Backup_after_DAYS__c), b.Backup_Type__c);

                // if(b.Backup_Type__c == 'Initialize'){
                //     b.Backup_Type__c = 'Scheduled';
                //     policyToUpdate.add(b);
                // }
            } 
            if(!policyToUpdate.isEmpty())
                update policyToUpdate;
        }
    }
}