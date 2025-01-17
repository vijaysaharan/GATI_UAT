@isTest
public with sharing class AmeyoVBTest {
	public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals(AmeyoVoiceBlast__mdt.getInstance('Ameyovoiceblast').endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"callbackProperties":null,"callbackTime":null,"campaignId":null,"id":null,"isSelfCallback":null,"userId":null,"crmIntegrated":false,"crmTypeString":null,"crmSuccess":false,"customerId":36995068,"isInserted":true,"resultTypeString":"UPDATED","message":null,"inputCustomerRecord":null}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Account acc1=TestFactory.getAccount('TestAccount' , 'KEA', '521180', True);
        Contact con1 = TestFactory.getContact('TestAccount', 'a@a.com');
        Case c1 = ServiceTestFactory.getCase10('CRM',con1.id);
        Ameyo_Voice_Blast_Detail__c amvb = ServiceTestFactory.getvbRecord(c1);
        Test.startTest();
        AmeyoVoiceBlastAPI.voiceBlast(amvb.id);
        test.stopTest();
    }
}