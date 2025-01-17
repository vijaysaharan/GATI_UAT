@istest
public class ContentAccountDocumentTest {
    @istest static void upload(){
        
       
        
        Test.startTest();
        
        Account acc1 = TestFactory.getAccount('acc1','KEA','243122',True);
        
        ContentVersion cv = TestFactory.getContentVersion('Test Extension','TestDocument.pdf',Blob.valueOf('Test Content'),true,'H');
        
		//Get Content Documents
		Id conDocId = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id LIMIT 1].ContentDocumentId;
        
        
        //Create ContentDocumentLink
        ContentDocumentLink cdl = TestFactory.getContentDocumentLink(acc1.Id , conDocId , 'V' );
        
		
        
        ContentVersion cv1 = TestFactory.getContentVersion('Test','TestDocument.pdf',Blob.valueOf('Test Content'),true,'H');
        
        //Get Content Documents
		Id conDocId2 = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id LIMIT 1].ContentDocumentId;
        
		//Create ContentDocumentLink
		
        ContentDocumentLink cdl1 = TestFactory.getContentDocumentLink(acc1.Id , conDocId2 , 'V' );
        
		
        
        
        Test.stopTest();
        
        
        Account acc  = [Select id,Uploads__c from Account where id =: acc1.id ];       
     //   System.assertEquals(0,acc.Uploads__c);
        
        
        
        ContentDocument documents = [SELECT Id FROM ContentDocument LIMIT 1];        
        database.delete(documents.id);        
        Account acc3  = [Select id,Uploads__c from Account where id =: acc1.id ];        
        System.assertEquals(0,acc3.Uploads__c);  
        
        Account acc5  = [Select id,Uploads__c from Account where id =: acc1.id ];        
        System.assertEquals(0,acc5.Uploads__c);
    }
}