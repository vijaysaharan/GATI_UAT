@isTest
public class TestAddServiceResourceBatch {
    @isTest
    static void testGetAccount() { 
        String mockApiResponse ='{"accessToken":"ObBlttxHTM2ivOvWQXRTZy4=","tokenType":"EBX"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        
        Id complaintRecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Complaint' AND SObjectType = 'Case' LIMIT 1].Id;        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User']; 
        
        User user = new User(Alias = 'testStd',
                             Email='standarduser@testorg.com',
                             EmailEncodingKey='UTF-8', 
                             Username='testuser20012025@testorg.com', 
                             LastName='testuser1',  
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', 
                             ProfileId = p.Id,
                             Staff_Code__c = '60245',
                             TimeZoneSidKey='America/Los_Angeles',
                             isActive = true
                            );
        insert user;          
        
        Account testAccount = new Account();
        testAccount.Name = 'Test';
        testAccount.Customer_Code__c = 45071002.102;
        testAccount.GATI_Customer_Code__c = '45071002';
        testAccount.BillingPostalCode = '201301';
        testAccount.ShippingPostalCode = '201307';
        insert testAccount;
        
        AccountTeamMember testAccountTeamMember = new AccountTeamMember();
        testAccountTeamMember.AccountId = testAccount.Id;
        testAccountTeamMember.UserId = user.Id;
        testAccountTeamMember.AccountAccessLevel = 'Read';
        testAccountTeamMember.CaseAccessLevel = 'None';
        testAccountTeamMember.OpportunityAccessLevel = 'None';
        testAccountTeamMember.TeamMemberRole = 'Service Resource';
        insert testAccountTeamMember;
        
        Case testCase = new Case();
        testCase.AccountId = testAccount.Id;
        testCase.RecordTypeId = complaintRecordTypeId;
        testCase.Origin = 'Web';
        testCase.Status = 'Open'; 
        testCase.Type = 'Delayed Connection'; 
        testCase.Sub_Type__c = 'MISROUTE'; 
        testCase.Docket_Number__c = '123456789';
        testCase.OwnerId = user.Id;
        insert testCase;
        
        String recordId = testAccount.Id;
        String userId = user.Id;
        
        test.startTest();
        AddServiceResourceBatch batch = new AddServiceResourceBatch();
        batch.recordId = recordId;
        batch.userId = userId;
        Database.executeBatch(batch,1);
        test.stopTest();        
    }  
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private String mockResponse;

        public MockHttpResponseGenerator(String mockResponse) {
            this.mockResponse = mockResponse;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    }
}