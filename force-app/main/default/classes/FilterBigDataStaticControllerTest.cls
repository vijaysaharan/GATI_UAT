@isTest
public class FilterBigDataStaticControllerTest {
    @testSetup
    public static void setup(){
        ContentVersion cvSuccess = new ContentVersion();
        cvSuccess.ContentLocation = 'S'; 
        cvSuccess.Title = 'dummy.csv'; 
        cvSuccess.PathOnClient = 'dummy.csv';
        cvSuccess.VersionData = Blob.valueOf('hlo');
        cvSuccess.isMajorVersion = false;
        Insert cvSuccess;
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
        bc.Object_Name__c = 'Case';
        bc.Big_Object_Index__c = 'AccountID__c,CreatedDate__c';
        bc.Big_Object_Name__c = 'Dummy__b';
        bc.Mapping_S2B__c = '{"Id":"Id"}';
        bc.Child_To_Backup__c = 'Case:AccountId__c';
        insert bc;
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
    }
    
    
    @isTest
    public static void getDataInRangetest(){
        FilterBigDataStaticController.getDataInRange(date.today(), date.today()-1);
        FilterBigDataStaticController.getCsvFlag();
    }
    
    @isTest
    public static void createCsvtest(){
        List<sobject> a = [Select id from Account];
        List<ContentVersion> c = [select id from ContentVersion where Title = 'dummy.csv' limit 1];
        List<Backup_Configuration__c> b = [Select id,Mapping_S2B__c,Object_Name__c from Backup_Configuration__c limit 1];
        ProcessCsvByList p = new ProcessCsvByList();
       // p.createCsv(JSON.serialize(a),JSON.serialize(new Map<String,String>{'Id'=>'Id'}),c[0].Id,'Id\n');
       
        try{
            p.createCsv(JSON.serialize(a),JSON.serialize(new Map<String,String>{'Id'=>'Id'}),
                        'Id\r\n');
            p.execute(null, new List<String>{JSON.serialize(a)});
            
        }catch(Exception e){}
        
        try{
            p.toItrerate = new List<String>{JSON.serialize(a)};
            p.header = 'Id\r\n';
            p.objConfig = b[0];
            Database.executeBatch(p,1);
        }catch(Exception e){}
    }
}