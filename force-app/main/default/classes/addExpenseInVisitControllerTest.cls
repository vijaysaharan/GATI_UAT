@isTest
public class addExpenseInVisitControllerTest {
    @testSetup
    static void setupTestData() { 
        User u = new User(
            Id = UserInfo.getUserId()
        );
        u.Grade__c = 'M1';
        update u;
        Travel_Policy__c tr = new Travel_Policy__c(
            Name = 'M1',
            TwoWheelerEntitlement__c = 3.5,
            FourWheelerEntitlement__c = 10.5
 
        );
        insert tr;
        Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        Organization_Master__c om = new Organization_Master__c();
        om.Name = '335524';
        om.RecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Pincode Location').getRecordTypeId();
        insert om;
        Lead l = new Lead();
        l.Email='test23456543@gmail.com';
        l.LastName ='Test Lead';
        l.Status ='New';
        l.PostalCode =om.Name;
        l.MobilePhone ='9870006578';
        l.Company ='Test Industries';
        l.Working_start_Date__c=system.today()-3;
        insert l;
        Visit__c testVisit = new Visit__c(
            Visit_Date__c = System.today(),
            Employee_Name__c = u.Id,
            Mode__c = 'Two wheeler',
            Visit_Start_DateTime__c = System.now(),
            Source_Geo_Coordinate__Latitude__s = 28.6130176,
            Source_Geo_Coordinate__Longitude__s = 77.3521408,
            Destination_Geo_Coordinate__Latitude__s = 28.603447907914237,
            Destination_Geo_Coordinate__Longitude__s = 77.34438116931993
        );
        insert testVisit;
        String user = u.Id;
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Call_Type__c = 'Sales Call';
        cc.Sub_Type__c = 'Contract Signoff';
        cc.Visit_Start_Date__c = System.now();
        cc.Check_In_Time__c = System.now();
        cc.Check_In_Location__Latitude__s = 28.78456;
        cc.Check_In_Location__Longitude__s = 29.78456;
        cc.Customer_Code__c = acc1.Id;
        cc.Visit_Status__c = 'Planned';
        cc.Visit_Mode__c = 'Virtual Meet';
        cc.Lead__c = l.Id;
        cc.OwnerId = user;
        insert cc;
    }
    @isTest
    public static void getPicklistOptionsTest(){
        Test.startTest();
        addExpenseInVisitController.getPicklistOptions('Opportunity','StageName');
        Test.stopTest();
    }
    
    @isTest
    public static void getExpenseLabelOptionsTest(){
        Test.startTest();
        addExpenseInVisitController.nameOrder result = addExpenseInVisitController.getExpenseLabelOptions();
        Test.stopTest();
    }
    
    @isTest
    public static void upsertExpenseTest(){
        Visit__c testVisit = [Select Id From Visit__c Limit 1];
        Customer_Connect__c cc = [Select Id,Visit_Start_Date__c,OwnerId From Customer_Connect__c limit 1];
        List<Expense__c> lstToUpsert = new List<Expense__c>();
        Expense__c rec = new Expense__c();
        rec.Customer_Connect__c = cc.Id;
        rec.Visit__c = testVisit.Id;
        rec.RecordTypeId =  Schema.SObjectType.Expense__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        rec.From_Date__c = Date.newInstance(cc.Visit_Start_Date__c.year(), cc.Visit_Start_Date__c.month(), cc.Visit_Start_Date__c.day());
        rec.Employee_Name__c = cc.OwnerId;
        lstToUpsert.add(rec);
        Test.startTest();
        addExpenseInVisitController.upsertExpense(null);
        addExpenseInVisitController.upsertExpense(lstToUpsert);
        Test.stopTest();
    }
    
    @isTest
    public static void expenseListForVisitTest(){
        Visit__c testVisit = [Select Id from Visit__c limit 1];
        Customer_connect__c cc = [Select Id,Visit_Start_Date__c,OwnerId From Customer_connect__c limit 1];
        Expense__c rec = new Expense__c();
        rec.Customer_Connect__c = cc.Id;
        rec.Visit__c = testVisit.Id;
        rec.RecordTypeId =  Schema.SObjectType.Expense__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        rec.From_Date__c = Date.newInstance(cc.Visit_Start_Date__c.year(), cc.Visit_Start_Date__c.month(), cc.Visit_Start_Date__c.day());
        rec.Employee_Name__c = cc.OwnerId;
        insert rec;
        
        Test.startTest();
        List<AddExpenseInVisitController.returnMap> result = AddExpenseInVisitController.expenseListForVisit(testVisit.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void deleteExpenseRecordTest(){
        Visit__c testVisit = [Select Id from Visit__c limit 1];
        Customer_connect__c cc = [Select Id,Visit_Start_Date__c,OwnerId From Customer_connect__c limit 1];
        Expense__c rec = new Expense__c();
        rec.Customer_Connect__c = cc.Id;
        rec.Visit__c = testVisit.Id;
        rec.RecordTypeId =  Schema.SObjectType.Expense__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        rec.From_Date__c = Date.newInstance(cc.Visit_Start_Date__c.year(), cc.Visit_Start_Date__c.month(), cc.Visit_Start_Date__c.day());
        rec.Employee_Name__c = cc.OwnerId;
        insert rec;
        
        Test.startTest();
        boolean result = AddExpenseInVisitController.deleteExpenseRecord(rec);
        boolean result1 = AddExpenseInVisitController.deleteExpenseRecord(null);
        Test.stopTest();
        
    }
    
    @isTest
    public static void getPricePolicyDetailTest(){
        Visit__c testVisit = [Select Id From Visit__C limit 1];
        Test.startTest();
        try{
            Travel_Policy__c result = AddExpenseInVisitController.getPricePolicyDetail(testVisit.Id);
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void getFromPlaceAndToPlaceTest(){
        Visit__c testVisit = [Select Id from Visit__c limit 1];
        Customer_connect__c cc = [Select Id From Customer_connect__c limit 1];
        Test.startTest();
        AddExpenseInVisitController.getFromPlaceAndToPlace(testVisit.Id,cc.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void createExpenseDataWithAttachmentTest(){
        Visit__c testVisit = [Select Id From Visit__c Limit 1];
        Customer_Connect__c cc = [Select Id, Visit_Start_Date__c, OwnerId From Customer_Connect__c limit 1];
        Expense__c rec = new Expense__c();
        rec.Customer_Connect__c = cc.Id;
        rec.Visit__c = testVisit.Id;
        rec.RecordTypeId = Schema.SObjectType.Expense__c.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        rec.From_Date__c = Date.newInstance(cc.Visit_Start_Date__c.year(), cc.Visit_Start_Date__c.month(), cc.Visit_Start_Date__c.day());
        rec.Employee_Name__c = cc.OwnerId;
        insert rec;
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Document';
        contentVersion.PathOnClient = 'test.txt';
        contentVersion.VersionData = Blob.valueOf('Test attachment content');
        insert contentVersion;
        List<String> attachmentIds = new List<String>();
        attachmentIds.add(contentVersion.ContentDocumentId);
        Map<String, Expense__c> fakeIdRecordMap = new Map<String, Expense__c>();
        fakeIdRecordMap.put('1', rec);
        Map<String, List<String>> fakeIdsAttachmentMap = new Map<String, List<String>>();
        fakeIdsAttachmentMap.put('1', attachmentIds);
        Test.startTest();
        try{
            Boolean result = AddExpenseInVisitController.createExpenseDataWithAttachment(fakeIdRecordMap, fakeIdsAttachmentMap);
        }catch(Exception e){}        
        Test.stopTest();
    }
}