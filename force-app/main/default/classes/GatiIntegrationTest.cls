@istest
public class GatiIntegrationTest {

    static testmethod void testAPI(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Account acc = TestFactory.getAccount('Test'+datetime.now(), 'Retail','110011', true);
        Invoice__c inv = TestFactory.getInvoice('test'+datetime.now(),acc.id,'123456');
        req.requestURI = '/services/apexrest/SendRecord/*';
        req.httpMethod = 'POST';
        String Body = '{"gatiEID":"1100100"}';
        req.requestBody = Blob.valueOf(Body);
        RestContext.request = req;
        RestContext.response = res;
        GatiIntegration.doPost();
        Body = '{"gatiEID":"11001001","invoiceNumber":"'+inv.Name+'"}';
        req.requestBody = Blob.valueOf(Body);
        RestContext.request = req;
        RestContext.response = res;
        GatiIntegration.doPost();
    }
}