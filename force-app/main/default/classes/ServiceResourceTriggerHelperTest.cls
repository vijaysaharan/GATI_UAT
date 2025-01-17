@isTest
public class ServiceResourceTriggerHelperTest {
    @testSetup static void makeData(){
        Account testAccount = new Account(Name = 'Test Account',
                                          GATI_Customer_Code__c = 'T-12345'
                                         );
        insert testAccount;
    }
    
    @isTest static void createAccountTeamMember(){
        String mockApiResponse ='{"accessToken":"ObBlttxHTM2ivOvWQXRTZy4=","tokenType":"EBX"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockApiResponse));
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        AccountTeamMember testAccTeamMember_1 = new AccountTeamMember();
        testAccTeamMember_1.AccountId = testAccount.Id;
        testAccTeamMember_1.TeamMemberRole = 'Service Resource';
        testAccTeamMember_1.UserId = Userinfo.getUserId();
        test.startTest();
        insert testAccTeamMember_1;
        delete testAccTeamMember_1;
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