@isTest
private class VoiceBlastCalloutTest {
    private class VoiceBlastCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Callout executed"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testVoiceBlastCallout() {
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 2; i++) {
            Case testCase = new Case(
                Subject = 'Test Case ' + i,
                Status = 'New',
                Mobile__c = '1234567890'
            );
            testCases.add(testCase);
        }
        insert testCases;

        Test.setMock(HttpCalloutMock.class, new VoiceBlastCalloutMock());

        Test.startTest();
        System.enqueueJob(new VoiceBlastCallout(testCases));
        Test.stopTest();
    }
}