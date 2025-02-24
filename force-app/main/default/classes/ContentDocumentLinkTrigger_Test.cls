@isTest
public class ContentDocumentLinkTrigger_Test {
     @istest static void upload(){
        
       // Case cc1 = ServiceTestFactory.getCase1('CRM');
        Contact co1 = TestFactory.getContact('shri','abc@gmail.com');
        Case cc1 = ServiceTestFactory.getCase10('abc',co1.id);
        
        
        ContentVersion cv = ServiceTestFactory.getContentVersion('Docket Copy','TestDocument.pdf',Blob.valueOf('Test Content'),true,'H');
        
		//Get Content Documents
		Id conDocId = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id LIMIT 1].ContentDocumentId;
        
        
        //Create ContentDocumentLink
        ContentDocumentLink cdl = ServiceTestFactory.getContentDocumentLink(cc1.Id , conDocId , 'V' );
        
		
        
        ContentVersion cv1 = ServiceTestFactory.getContentVersion('claim letter','TestDocument.pdf',Blob.valueOf('Test Content'),true,'H');
        
        //Get Content Documents
		Id conDocId2 = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id LIMIT 1].ContentDocumentId;
        
		//Create ContentDocumentLink
		
        ContentDocumentLink cdl1 = ServiceTestFactory.getContentDocumentLink(cc1.Id , conDocId2 , 'V' );
        
        
       // Case cc  = [Select id,Total_Upload__c from Case where id =: cc1.id ];       
     //   System.assertEquals(0,acc.Uploads__c);
        
        
        
       // ContentDocument documents = [SELECT Id FROM ContentDocument LIMIT 1];        
        //database.delete(documents.id);    
        //delete documents;
       // map<id,contentDocument> testmap = new map<id,contentDocument>();
        //testmap.put(documents.Id, documents);
        //ContentCaseDocument.ondeletecontentDocument(testmap);
        //Case cc3  = [Select id,Total_Upload__c from Case where id =: cc1.id ];        
       // System.assertEquals(0,cc3.Total_Upload__c);  
        
        //Case cc5  = [Select id,Total_Upload__c from Case where id =: cc1.id ];        
       // System.assertEquals(0,cc5.Total_Upload__c);
    }

}