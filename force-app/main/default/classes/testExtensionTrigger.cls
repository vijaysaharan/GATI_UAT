@istest
public class testExtensionTrigger {
    @istest
    public static void testmethod1(){
        cvHelper.getFileExtension('filename.pdf');
    }
    @istest
    public static void testmethod2(){
        cvHelper.getFileExtension('filename.jpg');
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            // System.assertEquals(API_credential__mdt.getInstance('CCECRecords').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful", "sErrMsg":"","response":["contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    @istest static void upload(){
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        // Case cc1 = ServiceTestFactory.getCase1('CRM');
        Contact co1 = TestFactory.getContact('shri','abc@gmail.com');
        Case cc1 = ServiceTestFactory.getCase9('abc');
        //CCEC__c ccec1 =  ServiceTestFactory.getCCEC(cc1.id);
        
        
        ContentVersion cv = ServiceTestFactory.getContentVersion('Docket Copy','TestDocument.pdf',Blob.valueOf('Test Content'),true,'H');
        
        //Get Content Documents
        Id conDocId = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id LIMIT 1].ContentDocumentId;
        
        
        //Create ContentDocumentLink
        ContentDocumentLink cdl = ServiceTestFactory.getContentDocumentLink(cc1.Id , conDocId , 'V' );
        
        
        
        ContentVersion cv1 = ServiceTestFactory.getContentVersion('claim letter','TestDocument.jpg',Blob.valueOf('Test Content'),true,'H');
        
        //Get Content Documents
        Id conDocId2 = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id LIMIT 1].ContentDocumentId;
        
        //Create ContentDocumentLink
        
        ContentDocumentLink cdl1 = ServiceTestFactory.getContentDocumentLink(cc1.Id , conDocId2 , 'V' );
        
        
        
        
        Test.stopTest();
    }
    
}