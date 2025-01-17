@isTest
public class ContentDocumentLinkTrigger_Test {
     @istest static void upload(){
        Contact co1 = TestFactory.getContact('shri','abc@gmail.com');
        Case cc1 = ServiceTestFactory.getCase10('abc',co1.id);
        
        ContentVersion cv = ServiceTestFactory.getContentVersion('Docket Copy','TestDocument.pdf',Blob.valueOf('Test Content'),true,'H');
        
		Id conDocId = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink cdl = ServiceTestFactory.getContentDocumentLink(cc1.Id , conDocId , 'V' );
        
        ContentVersion cv1 = ServiceTestFactory.getContentVersion('claim letter','TestDocument.pdf',Blob.valueOf('Test Content'),true,'H');
        
		Id conDocId2 = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink cdl1 = ServiceTestFactory.getContentDocumentLink(cc1.Id , conDocId2 , 'V' );
    }

}