@isTest
public class UploadVerificationDocumentsTest {
    @testSetup
    static void makeData(){
        Account testAccount = new Account(
            Name = 'Test Account',
            GATI_Customer_Code__c = '1234'
        );
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'qualified',
            AccountId = testAccount.Id,
            CloseDate = System.today().addDays(2)
        );
        insert testOpportunity;
        //Test.setCreatedDate(testOpportunity.Id, System.now().addDays(-800));
        
        ContentVersion testContentVersion = new ContentVersion(
            contentLocation = 'S',
            PathonClient = 'Test',
            Title = 'Test Title',
            VersionData = Blob.valueof('Test Blob Data')
        );
        insert testContentVersion;
        
        Id testContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId;
        
        ContentDocumentLink testDocumentLink = New ContentDocumentLink(
            LinkedEntityId = testOpportunity.Id, 
            ContentDocumentId = testContentDocumentId,
            shareType = 'V'
        );
        insert testDocumentLink;
    }
    
    @isTest
    public static void sendFileToAWSTest(){
        Opportunity opportunityTest = [SELECT Id FROM Opportunity LIMIT 1];
        test.startTest();
        UploadVerificationDocumentsController.updateOpportunityDetails('documentBase64','PAN.pdf',opportunityTest.Id,'ABCDE1234F','PAN');
        test.stopTest();
    }    
      
    @isTest
    public static void getAllAccountsTest(){
        test.startTest();
        OpportunitySendToAwsController.getAllAccounts();
        test.stopTest();
    }
    
    @isTest
    public static void getContentVersionsTest(){
        Account accountTest = [SELECT Id FROM Account LIMIT 1];
        test.startTest();
        OpportunitySendToAwsController.getContentVersions(new List<Id>{accountTest.Id});
        test.stopTest();
    }
}