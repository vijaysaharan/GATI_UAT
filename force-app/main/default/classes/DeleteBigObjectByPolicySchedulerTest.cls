@isTest
public class DeleteBigObjectByPolicySchedulerTest {
	@testSetup
    public static void testSetup(){
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
        
         Case c = new Case();
        //enter details
        c.AccountId = acct.Id;
        c.Type = 'My Type';
        c.Origin = 'My Origin';
        c.Status = 'Open'; 
        c.Type = 'Pending Pickup'; 
        c.Sub_Type__c = 'MISSED PICKUP'; 
        c.Docket_Number__c = '1111';
        c.OwnerId = UserInfo.getUserId();
        //  c.Pick_Up_Ref_ID__c = '5000sddfdg';   
        insert c;
        
        Backup_Configuration__c bc = new Backup_Configuration__c();
        bc.Object_Name__c = 'Case';
        bc.Big_Object_Index__c = 'AccountID__c,CreatedDate__c';
        bc.Big_Object_Name__c = 'Dummy__b';
        bc.Mapping_S2B__c = '{"Id":"AccountID__c"}';
        bc.Child_To_Backup__c = 'Case:AccountId__c';
        insert bc;
        
        Backup_Configuration__c bc1 = new Backup_Configuration__c();
        bc1.Object_Name__c = 'Case';
        bc1.Big_Object_Index__c = 'AccountID__c,CreatedDate__c';
        bc1.Big_Object_Name__c = 'Dummy__b';
        bc1.Mapping_S2B__c = '{"Id":"AccountID__c"}';
        insert bc1;
        
        Backup_Ploicy__c bp = new Backup_Ploicy__c();
        bp.Backup_after_DAYS__c = 0;
        bp.Remove_Backup_after_DAYS__c = 0;
        bp.Backup_Type__c = 'Initialize';
        bp.Object_Name__c = 'Case';
        insert bp;
    }
    
    @isTest
    public static void scheduleTest(){
        try{
             Test.startTest();
            DeleteBigObjectByPolicyScheduler d = new DeleteBigObjectByPolicyScheduler();
            d.execute(null);
            Test.stopTest();
        }catch(Exception e){}
    }
}