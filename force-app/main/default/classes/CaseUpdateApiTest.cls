@isTest
public class CaseUpdateApiTest {
    
    
    @istest static void testApi2(){
        Case c = ServiceTestFactory.getCaseServiceRequestType('Exception','New');
        Case c1 = [select CaseNumber from case where id=:c.Id ];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CaseUpdateAPI/*';  
        req.httpMethod = 'POST';
        String Body = '{"caseObj":{"CS_Check__c":"Yes","Claim_Acceptance__c":"Y","Claim_Status__c":"Open","HO_Approval__c":"abc","HO_Comments__c":"Working","OBN_No__c":"1122","OBN_Status__c":"Valid Reason","OBN_Issued_Amount__c":"682","OBN_Issued_date__c":"2021-06-20","Liability_Status__c":"closed","Claim_Setteled_Amount__c":"18901","CMS_No__c":"12","CMS_Paid_Date__c":"2021-06-20","CRN__c":"123","CaseNumber":"'+c1.casenumber+'"}}}]';
        
        req.requestBody = Blob.valueOf(Body);
        RestContext.request = req;
        RestContext.response= res; 
        
        CaseUpdateAPI.doPost();
        
        
        
    }
    
    @istest static void testApi3(){
        Case c = ServiceTestFactory.getCaseServiceRequestType('Exception','New');
        Case c1 = [select CaseNumber from case where id=:c.Id ];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CaseUpdateAPI/*';  
        req.httpMethod = 'POST';
        String Body = '{"caseObj":{"CS_Check__c":"Ye","Claim_Acceptance__c":"Y","Claim_Status__c":"BAD","HO_Approval__c":"abc","HO_Comments__c":"Working","OBN_No__c":"1122","OBN_Status__c":"Valid Reason","OBN_Issued_Amount__c":"682","OBN_Issued_date__c":"2021-06-20","Liability_Status__c":"closed","Claim_Setteled_Amount__c":"18901","CMS_No__c":"12","CMS_Paid_Date__c":"2021-06-20","CRN__c":"123","CaseNumber":"'+c1.casenumber+'"}}}]';
        
        req.requestBody = Blob.valueOf(Body);
        RestContext.request = req;
        RestContext.response= res; 
        
        CaseUpdateAPI.doPost();   
    }
    
   /* @istest static void testApi(){
        Case c2 = ServiceTestFactory.getCaseServiceRequestType('Exception','New');
        Case c3 = [select CaseNumber from case where id=:c2.Id ];
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        req1.requestURI = '/services/apexrest/CaseUpdateAPI/*';  
        req1.httpMethod = 'POST';
        String Body = '{"caseObj":{"CS_Check__c":"Yes","Claim_Acceptance__c":"Y","Claim_Status__c":"BAD Value","HO_Approval__c":"abc","HO_Comments__c":"Working","OBN_No__c":"1122","OBN_Status__c":"Valid Reason","OBN_Issued_Amount__c":"682","OBN_Issued_date__c":"2021-06-20","Liability_Status__c":"closed","Claim_Setteled_Amount__c":"18901","CMS_No__c":"12","CMS_Paid_Date__c":"2021-06-202090","CRN__c":"123","CaseNumber":"'+c3.casenumber+'"}}}]';
        
        req1.requestBody = Blob.valueOf(Body);
        RestContext.request = req1;
        RestContext.response= res1; 
        
        CaseUpdateAPI.doPost();
    }*/
}