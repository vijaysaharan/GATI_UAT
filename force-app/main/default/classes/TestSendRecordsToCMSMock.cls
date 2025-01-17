@isTest
public class TestSendRecordsToCMSMock implements HttpCalloutMock{
    
    public static HttpResponse respond(HttpRequest request){
        HttpResponse resp = new HttpResponse();
        String body ='{"requid":"GS21005","result":"successful", "sErrMsg":"","response":[{"customerCode":"43053001","companyId":"GATIKWE","result":"Data Inserted"}]}';
		resp.setBody(body);
        resp.setStatusCode(200);
        return resp;
    }

    
}