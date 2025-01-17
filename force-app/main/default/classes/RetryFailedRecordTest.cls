@isTest
public with sharing class RetryFailedRecordTest {
    @TestSetup
    static void makeData(){
        Daily_Backup_Log__c d = new Daily_Backup_Log__c();
        d.Timestamp__c = DateTime.now();
        d.Type__c = 'Backup';
        insert d;

        Account a = new Account();
        a.Name = 'test';
        insert a;

        Backup_Log__c b = new Backup_Log__c();
        b.Type__c = 'Backup';
        b.Object_Name__c = 'Account';
        b.Backup_Object_Name__c = 'Dummy__b';
        b.Backup_Log__c = d.Id;
        insert b;

        ContentVersion cvError = new ContentVersion();
        cvError.ContentLocation = 'S'; 
        cvError.Title = 'Error Record.csv'; 
        cvError.PathOnClient = 'Error Record.csv'; 
        cvError.VersionData = Blob.valueOf('Hlo '); 
        cvError.FirstPublishLocationId = b.Id;
        insert cvError;

        Backup_Configuration__c bc = new Backup_Configuration__c();
        bc.Object_Name__c = 'Account';
        bc.Big_Object_Index__c = 'AccountID__c';
        bc.Big_Object_Name__c = 'Dummy__b';
        bc.Mapping_S2B__c = '{"Id":"AccountID__c"}';
        insert bc;
    }

    @isTest
    public static void alltest(){
        Backup_Log__c b = [select Id,Backup_Object_Name__c from Backup_Log__c limit 1];
        ContentVersion cv = [Select Id from ContentVersion limit 1];
        Account a = [Select id from Account limit 1];
        try {
            RetryFailedRecord.getBigObjName(b.id);  
            RetryFailedRecord.getBigObjName(null); 
        } catch (Exception e){}
        
        try {
            RetryFailedRecord.callbackupBatch(new List<String>{a.Id} , JSON.serialize(b) );
            RetryFailedRecord.callbackupBatch(null , JSON.serialize(b) );
        } catch (Exception e) {
            
        }

        try {
            RetryFailedRecord.getCsvData(cv.Id);
            RetryFailedRecord.getCsvData(null);
        } catch (Exception e) {
            
        }

        try {
            RetryFailedRecord.getRelatedFileIds(b.Id);
            RetryFailedRecord.getRelatedFileIds(null);
        } catch (Exception e) {
            
        }
    }
}