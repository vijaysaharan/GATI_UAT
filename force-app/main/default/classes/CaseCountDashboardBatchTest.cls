@isTest
private class CaseCountDashboardBatchTest {

    @isTest
    static void testBatchExecution() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Case cs = new Case(AccountId = testAccount.Id);
        insert cs;
        CustomerDashboard__c customerDashboards = new CustomerDashboard__c(AccountName__c = testAccount.Id);
        insert customerDashboards;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        CaseCountCustomerConnectDashboardBatch batchClass = new CaseCountCustomerConnectDashboardBatch();
        Database.executeBatch(batchClass);
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