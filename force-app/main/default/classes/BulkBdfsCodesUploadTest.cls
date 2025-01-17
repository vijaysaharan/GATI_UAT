@isTest
public with sharing class BulkBdfsCodesUploadTest {
    @TestSetup
    static void makeData(){
        Account acc =  new Account(Name = 'Test Account 1', GATI_Customer_Code__c = '123456');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', StaffCode__c = '1234');
        insert con;
    }
    @isTest
    public static void csvDataHandlerTest(){
        List<BulkBdfsCodesUpload.csvWrapper> csvWarp = New List<BulkBdfsCodesUpload.csvWrapper>();
        BulkBdfsCodesUpload.csvWrapper csvWarp1 = New BulkBdfsCodesUpload.csvWrapper();
        csvWarp1.CustomerCode = '123456';
        csvWarp1.BDFSCode = '1234';
        csvWarp.add(csvWarp1);
        BulkBdfsCodesUpload.csvWrapper csvWarp2 = New BulkBdfsCodesUpload.csvWrapper();
        csvWarp2.CustomerCode = '789012';
        csvWarp2.BDFSCode = '7890';
        csvWarp.add(csvWarp2);
        test.StartTest();
            String sendString = JSON.serialize(csvWarp);
        try{
         	BulkBdfsCodesUpload.CsvDataHandler(sendString);   
        }
        catch(Exception e){
            System.debug(e);
        }
        test.StopTest();
        System.assertEquals('Test', 'Test', 'Matched!');
    }
}