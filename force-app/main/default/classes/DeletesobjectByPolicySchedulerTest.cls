@isTest
public class DeletesobjectByPolicySchedulerTest {
	@isTest
    public static void testDeleteSobject(){
        Backup_Ploicy__c bp = new Backup_Ploicy__c();
        bp.Backup_after_DAYS__c = 0;
        bp.Remove_original_after_Backup_DAYS__c = 0;
        bp.Backup_Type__c = 'Initialize';
        bp.Object_Name__c = 'Account';
        insert bp;
        Backup_Ploicy__c bp1 = new Backup_Ploicy__c();
        bp1.Backup_after_DAYS__c = 0;
        bp1.Remove_original_after_Backup_DAYS__c = 0;
        bp1.Backup_Type__c = 'Initialize';
        bp1.Object_Name__c = 'Account';
        bp1.Where_Clause__c = 'Id != null';
        insert bp1;
        Account acct = new Account();
        acct.Name = 'Test';
        acct.Customer_Code__c = 45071002.102;
        acct.BillingPostalCode = '201301';
        acct.ShippingPostalCode = '201307';
        acct.CreatedDate = Datetime.now()-1;
        insert acct;
        
        Test.startTest();
        DeletesobjectByPolicyScheduler d = new DeletesobjectByPolicyScheduler();
        d.execute(null);
        Test.stopTest();
    }
}