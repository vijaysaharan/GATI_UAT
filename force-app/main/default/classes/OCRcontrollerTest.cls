@istest public with sharing class OCRcontrollerTest {
    @istest
    private static void TestMethod1()
    {
         Test.setMock(HttpCalloutMock.class, new EinsteinAPIServiceMock()); 
           Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
                             Test.startTest();
                            OCRcontroller.callserver(contentVersion_2.id, contentVersion_2.ContentDocumentId);
                             Test.stoptest();
        
        
    }
     
}