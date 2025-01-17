public with sharing class DeletesobjectByPolicyScheduler implements Schedulable {
    public void execute(SchedulableContext sc){
        List<Backup_Ploicy__c> plociyList = [select Object_Name__c,Remove_original_after_Backup_DAYS__c,Where_Clause__c,Backup_after_DAYS__c from Backup_Ploicy__c];
        if(!plociyList.isEmpty()){
            Daily_Backup_Log__c d = new Daily_Backup_Log__c();
            d.Timestamp__c = DateTime.now();
            d.Type__c = 'Delete Original';
            insert d;
            for(Backup_Ploicy__c b : plociyList){
                DeleteSobjectByPolicy db = new DeleteSobjectByPolicy();
                db.deleteDays = Integer.valueOf(b.Remove_original_after_Backup_DAYS__c) + Integer.valueOf(b.Backup_after_DAYS__c);
                db.objectName = b.Object_Name__c;
                db.dailyBackUpId = d.id; 
                db.whereClause = b.Where_Clause__c;
                Database.executeBatch(db, 200);
            } 
        }
    }
}