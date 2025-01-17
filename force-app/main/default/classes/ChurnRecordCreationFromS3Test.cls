@isTest
public class ChurnRecordCreationFromS3Test {   
    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        public MockHttpResponse(Integer statusCode) {
            this.statusCode = statusCode;
        }
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            if(statusCode == 200){
                Blob bodyBlob = Blob.valueOf('EPNQ,CKN/CON/10/2020/1020002,31/08/2024,02/01/2023,11/04/2024,142,3.369565217,42.1,4525420,,,,,,9,No Recent Trends,0,FALSE,,');
                res.setBodyAsBlob(bodyBlob);   
            }
            return res;
        }
    }
    
    @testSetup
    static void makeData(){
        Account testAccount = new Account(Name = 'Test Account',Gati_Contract_Number__c = 'CKN/CON/10/2020/1020002');
       	insert testAccount;
        Churn_Output__c testChurn = new Churn_Output__c(Customer_Name__c = testAccount.Id, Contract_Number__c = 'CKN/CON/10/2020/1020002');
        insert testChurn;
    }
    
    @isTest
    static void testChurnRecordCreationFromS3Success() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200));
        Test.startTest();
        ChurnRecordCreationFromS3 churnJob = new ChurnRecordCreationFromS3();
        System.schedule('Test Job', '0 0 12 * * ?', churnJob);
        Test.stopTest();
    }
    
    @isTest
    static void testChurnRecordCreationFromS3NoFile() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(404));
        Test.startTest();
        ChurnRecordCreationFromS3 churnJob = new ChurnRecordCreationFromS3();
        churnJob.execute(null);
        Test.stopTest();
    }
    
    @isTest
    static void testBlobToStringMethod() {
        Blob testBlob = Blob.valueOf('Test String');        
        String result = UpdateChurnOutputAmazonS3.blobToString(testBlob, 'UTF-8');
    }
    
    @isTest
    static void testUpdateChurnOutputAmazonS3(){
        String allData = 'EDC__c,Contract_Number__c,Calib_End__c,First_Trans__c,Last_Trans__c,Time_Last_Trans_Recency__c,Active_Freq__c,Churn_Factor__c,Category__c,Total_Revenue__c,Last_Month_Revenue__c,Current_Month_Revenue__c,Last_Month_Volume__c,Current_Month_Volume__c,Rank__c,Softchurn_Indicator__c,Days_Till_Churn__c,Code_Blocked__c,SLA__c,Top_3_Default_OU__c\nEPNQ,CKN/CON/10/2020/1020002,2024-08-31,2024-08-31,2024-08-31,142,3.369565217,42.1,Not Churned,4525420,,,,,9,No Recent Trends,0,FALSE,,Test\n';
        test.startTest();
        UpdateChurnOutputAmazonS3 b = new UpdateChurnOutputAmazonS3(allData);
        Database.executeBatch(b,200);
        test.stopTest();
    }
    
    @isTest
    static void testAmazonS3BlobProcessBatch(){
        test.startTest();
        String allData = 'EDC__c,Contract_Number__c,Calib_End__c,First_Trans__c,Last_Trans__c,Time_Last_Trans_Recency__c,Active_Freq__c,Churn_Factor__c,Category__c,Total_Revenue__c,Last_Month_Revenue__c,Current_Month_Revenue__c,Last_Month_Volume__c,Current_Month_Volume__c,Rank__c,Softchurn_Indicator__c,Days_Till_Churn__c,Code_Blocked__c,SLA__c,Top_3_Default_OU__c\nEPNQ,CKN/CON/10/2020/1020002,2024-08-31,2024-08-31,2024-08-31,142,3.369565217,42.1,Not Churned,4525420,,,,,9,No Recent Trends,0,FALSE,,Test\n';
        Blob blobData = blob.valueOf(allData);
        AmazonS3BlobProcessBatch bp = new AmazonS3BlobProcessBatch(blobData);
        Database.executeBatch(bp,1);
        test.stopTest();
    }
}