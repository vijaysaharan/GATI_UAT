public class TestSendRecordsToCMSErrorMock {

    public static HttpResponse respond(HttpRequest request){
        HttpResponse resp = new HttpResponse();
        String body ='{"requid":"GS21005","result":"failed", "sErrMsg":"BOD is Required#@#","response":[]}';
		resp.setBody(body);
        resp.setStatusCode(400);
        return resp;
    }
}