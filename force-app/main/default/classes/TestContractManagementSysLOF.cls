@istest
public class TestContractManagementSysLOF {
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
       //     System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
       //     System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21001","result":"successful", "sErrMsg":"","response":[{"lofNo":"HYDN/LOF/06/2021/1020001","lofDate":"2021-06-07","lofValidityDate":"2021-07-07","lofAmendmentVersion":1}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    @istest static void testLOF(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Account acc = TestFactory.getAccount('test'+datetime.now(), 'Retail', '110011', true);
       // Account a1 = TestFactory.insertAccount2('term'+Datetime.now(),'101',Date.newInstance(2021,08,13),Date.newInstance(2021,08,16),12,'110011');
 		Opportunity op = TestFactory.insertOpty2('opty'+datetime.now(), date.today(), 'Qualified', acc.id);
        test.startTest();
        Contract_Management_Sys_LOF.payHistoryData(op.Id);
        Test.stopTest();
    }
   
}