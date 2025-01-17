@isTest
private class CaseCountForCustomerDashboardTest {

    @isTest
    static void testMakeCallout() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        CaseCountForCustomerDashboard.InputWrapper input = new CaseCountForCustomerDashboard.InputWrapper();
        input.accountId = testAccount.Id;
        input.startDate = Date.today().addDays(-30);
        input.endDate = Date.today();
        input.isClosed = true;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        List<Integer> result = CaseCountForCustomerDashboard.makeCallout(new List<CaseCountForCustomerDashboard.InputWrapper>{input});
        Test.stopTest();
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data":{"uiapi":{"query":{"Case":{"totalCount":5}}}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}