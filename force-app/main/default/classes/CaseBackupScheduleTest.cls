@isTest
public class CaseBackupScheduleTest {
	@isTest
    public static void scheduleTest(){
        Account acct = new Account();
        acct.Name = 'Test';
        acct.Customer_Code__c = 45071002.102;
        acct.BillingPostalCode = '201301';
        acct.ShippingPostalCode = '201307';
        acct.CreatedDate = Datetime.now()-1;
        insert acct;
        Account acct1 = new Account();
        acct1.Name = 'Test1';
        //acct1.Customer_Code__c = 45071002.102;
        acct1.BillingPostalCode = '201301';
        acct1.ShippingPostalCode = '201307';
        acct1.CreatedDate = Datetime.now()-1;
        insert acct1;
        
        Backup_Configuration__c bc = new Backup_Configuration__c();
        bc.Object_Name__c = 'Account';
        bc.Big_Object_Index__c = 'AccountID__c';
        bc.Big_Object_Name__c = 'Dummy__b';
        bc.Mapping_S2B__c = '{"Id":"AccountID__c"}';
        insert bc;
        
        Backup_Ploicy__c bp = new Backup_Ploicy__c();
        bp.Backup_after_DAYS__c = 0;
        bp.Backup_Type__c = 'Initialize';
        bp.Object_Name__c = 'Account';
        insert bp;
        
        Daily_Backup_Log__c d = new Daily_Backup_Log__c();
        d.Timestamp__c = DateTime.now();
        d.Type__c = 'Backup';
        insert d;
        
        test.startTest();
        CaseBackupScheduleClass cbs = new CaseBackupScheduleClass();
        cbs.execute(null);
        
        
        CreateBackUpToBigObject cbb = new CreateBackUpToBigObject('','',new List<String>{''},null);
        cbb.errorCount = 1;
        cbb.dailyBackUpId = d.Id;
        cbb.backUpLogItemID = null;
        cbb.finalLogic();
        test.stopTest();
    }
}