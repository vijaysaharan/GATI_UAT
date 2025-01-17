@istest
public class TestOutboundMIS {
public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31016","result":"failed", "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31016","result":"successful", "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testmethod void testOutboundMIS1(){
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        Account ac = TestFactory.getAccountCC('SiriSirir','KEA','243122',true);
        system.debug(ac);
        update ac;
        //Account a = [Select id,RecordType.Name from Account where RecordType.Name = 'Customer_Code'];
        //Id rid =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Code').getRecordTypeId();
        MIS__c a1 = TestFactory.getMIS(ac.id,true,'SL','BKG','order_no','102');
        List<String> misList = new List<String>();
        misList.add(a1.Id);
        MISOutboundAPI.calloutMethod(misList);
    }
    static testmethod void testOutboundMIS2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
         Account ac = TestFactory.getAccountCC('SiriSirir','KEA','243122',true);
        system.debug(ac);
        update ac;
        //Account a = [Select id,RecordType.Name from Account where RecordType.Name = 'Customer_Code'];
        //Id rid =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Code').getRecordTypeId();
        MIS__c a1 = TestFactory.getMIS(ac.id,true,'SL','BKG','order_no','102');
        List<String> misList = new List<String>();
        misList.add(a1.Id);
        MISOutboundAPI.calloutMethod(misList);
    }

}