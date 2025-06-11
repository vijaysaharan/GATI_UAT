@isTest
private class SendFailedLOFAndCONToMDMTest {
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"tokenType":"Bearer","accessToken":"123456"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Account testAccountChild = TestFactory.getAccount('Test', 'MSME', '301019', TRUE);
        Account testAccountParent = TestFactory.getAccount('Test', 'MSME', '301019', TRUE);
        testAccountParent.Contract_Number__c = 'HBD/TBT/1234.102';
        testAccountParent.GATI_Contract_Number__c = 'HBD/TBT/1234';
        update testAccountParent;
        testAccountChild.ParentId = testAccountParent.Id;
        testAccountChild.LOF_Number__c = '12345.102';
        update testAccountChild;
        TestFactory.getAccountTeamMember(testAccountChild.Id, System.UserInfo.getUserId(), 'Service Resource');
        Opportunity testOpportunity = new Opportunity(
            AccountId = testAccountChild.Id,
            Name = 'Test Opportunity', 
            StageName = 'qualified',
            CloseDate = System.today().addDays(2)
        );
        insert testOpportunity;
        List<Quote> testQuoteList = new List<Quote>();
        Quote testQuote1 = new Quote(
            Name = 'ABC/CON/122.102',
            OpportunityId = testOpportunity.Id,
            Test_LOF_number__c = 'ABC/LOF/123.102',
            IntegrationMessage__c = 'No Response'
        );
        testQuoteList.add(testQuote1);
        Quote testQuote2 = new Quote(
            Name = 'ABC/CON/123.102',
            OpportunityId = testOpportunity.Id,
            Test_LOF_number__c = 'ABC/CON/123.102'                                    
        );
        testQuoteList.add(testQuote2);
        insert testQuoteList;
    }

    @isTest
    static void testBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        SendFailedLOFAndCONToMDM sc = new SendFailedLOFAndCONToMDM();
        sc.execute(null);
        Test.stopTest();
    }
}