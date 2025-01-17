@isTest
public class RelatedListControllerTest {
	@testsetup
    public static void setup(){
        Account acct = new Account();
        acct.Name = 'Test';
        acct.Customer_Code__c = 45071002.102;
        acct.BillingPostalCode = '201301';
        acct.ShippingPostalCode = '201307';
        acct.CreatedDate = Datetime.now()-1;
        insert acct;
        
         Opportunity item = new Opportunity(
            Name = 'Test Item',
            CloseDate = System.today().addDays(10),
            Amount = 452100,
            StageName = 'Qualified',
            AccountId = acct.Id
        );
        insert item;
        
        
        Backup_Configuration__c bc = new Backup_Configuration__c();
        bc.Object_Name__c = 'Account';
        bc.Big_Object_Index__c = 'AccountID__c,';
        bc.Big_Object_Name__c = 'Dummy__b';
        bc.Mapping_S2B__c = '{"Id":"AccountID__c","RecordTypeID":"RecordTypeID__c"}';
        bc.Fields_To_Show__c = 'AccountID__c';
        bc.Child_To_Backup__c = 'Dummyo__b:AccountID__c';
        bc.Layout_Mapping__c = '{"11":"Detail@AccountID__c"}';
        insert bc;
        
        Backup_Configuration__c bc1 = new Backup_Configuration__c();
        bc1.Object_Name__c = 'Opportunity';
        bc1.Big_Object_Index__c = 'AccountID__c';
        bc1.Big_Object_Name__c = 'Dummyo__b';
        bc1.Mapping_S2B__c = '{"AccountId":"AccountID__c"}';
        bc1.Fields_To_Show__c = 'AccountID__c';
        bc.Layout_Mapping__c = '{"11":"Detail@AccountID__c"}';
        insert bc1;
        
       /* Dummy__b db = new Dummy__b();
        db.AccountId__c = acct.Id;
        //database.insertImmediate(db);
        insert db;*/
          
    }
    
    @isTest 
    public static void getConfigDataTest(){
        Account a = [select id from account limit 1];
        RelatedListController.getConfigData('Dummy__b',(String)a.Id,'AccountID__c');
    }
    
    @isTest 
    public static void getColumntest(){
        Account a = [select id from account limit 1];
        RelatedListController.getColumn('Dummy__b',new List<String>{'AccountID__c'});
        
        
    }
    
     @isTest 
    public static void viewRecordtest(){
        try{
            Account a = [select id from account limit 1];
            Opportunity o = [select id from opportunity limit 1];
            RelatedListController.viewRecord('AccountID__c','Dummy__b','{"AccountID__c":"'+a.Id+'"}');
            RelatedListController.viewRecord(null,'opportunity','{"Id":"'+o.Id+'"}');
        }catch(Exception e){}
    }
    
    @isTest
    public static void getChildConfigTest(){
         List<Backup_Configuration__c> b = [select Child_To_Backup__c,Object_Name__c,Big_Object_Index__c,Big_Object_Name__c,Mapping_S2B__c,Fields_To_Show__c from Backup_Configuration__c where Object_Name__c = 'Account'];
         RelatedListController.getChildConfig(JSON.serialize(b[0]));
    }
    
    @isTest 
    public static void deleteRecordTest(){
        try{
            Opportunity o = [select id from opportunity limit 1];
            RelatedListController.deleteRecord('AccountID__c',new Map<String,String>{'AccountId__c' => '65473563736363'},'Dummy__b','AccountId__c');
            RelatedListController.deleteRecord(null,new Map<String,String>{'AccountId__c' => (String)o.Id},'Opportunity',null);
        }catch(Exception e){}
    }
    
    @isTest
    public static void insertSobjectTest(){
        Opportunity item = new Opportunity(
            Name = 'Test Item',
            CloseDate = System.today().addDays(10),
            Amount = 452100,
            StageName = 'Qualified'
        );
        RelatedListController.insertSobject((Sobject)item);
        try{
        	RelatedListController.insertSobject(null);    
        }catch(Exception e){}
        
    }
    
    @isTest
    public static void createCsvTest(){
        try{
            Account a = [select id from account limit 1];
            RelatedListController.createCsv(a.id,'Dummy__b');
        }catch(Exception e){}
    }
}