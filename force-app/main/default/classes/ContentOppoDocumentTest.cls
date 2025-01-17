@isTest
public class ContentOppoDocumentTest {
    @isTest static void uploadDoc(){
        
        Account acc = TestFactory.getAccount('TestAccount','KEA','243122',True);
        list <opportunity> opp1= TestFactory.getOpportunity(1,acc.Id);
        
      list <opportunity> opp2=TestFactory.getOpportunity(1,acc.Id);
        insert opp1;
        insert opp2;
        ContentVersion cv1 = TestFactory.getContentVersion('Test Customer accept','TestDocument.jpg',Blob.valueOf('Test Content'),true,'H');
        
        
		//Get Content Documents
		Id conDocId1 = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id LIMIT 1].ContentDocumentId;
		//Create ContentDocumentLink
		ContentDocumentLink cdl = TestFactory.getContentDocumentLink(opp1[0].Id , conDocId1 , 'V' );
		
        
        ContentVersion cv2 = TestFactory.getContentVersion('Test2 Customer accept','TestDocument.jpg',Blob.valueOf('Test Content'),true,'H');
       //Get Content Documents
		Id conDocId2 = [SELECT id, title,  ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id LIMIT 1].ContentDocumentId;
		//Create ContentDocumentLink
		ContentDocumentLink cdl1 = TestFactory.getContentDocumentLink(opp2[0].Id , conDocId1 , 'V' );
		 
        Opportunity opp1i  = [Select id,Total__c from Opportunity where id =: opp1[0].id ]; 
       // System.assertEquals(0,opp1i.Total__c); 
        
        
        
            
        
  Opportunity opp1i2  = [Select id,Total__c from Opportunity where id =:opp2[0].id ]; 
        System.assertEquals(1,opp1i2.Total__c); 
        ContentDocument documents = [SELECT Id FROM ContentDocument where id=:conDocId1 LIMIT 1];        
        database.delete(documents.id);        
        Opportunity opp1d  = [Select id,Total__c from Opportunity where id =: opp1[0].id ];        
        System.assertEquals(0,opp1d.Total__c);
        
        ContentDocument documents2 = [SELECT Id FROM ContentDocument where id=:conDocId2 LIMIT 1];
        
        database.delete(documents2.id);        
        Opportunity opp1d2  = [Select id,Total__c from Opportunity where id =: opp2[0].id ];        
        System.assertEquals(0,opp1d2.Total__c);

    }
}