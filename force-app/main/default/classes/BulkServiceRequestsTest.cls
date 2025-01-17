@isTest
public with sharing class BulkServiceRequestsTest {

    private class MyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String jsonData = '{ "requid": "GS21004", "result": "successful", "sErrMsg": "", "response": [ { "docketNo": "104656420", "companyId": "GKE", "result": [ { "DOCKET_NO": 104656420, "BKG_DT": "2021-01-02", "CUSTOMER_CODE": "48481001", "BOOKING_STN": "HYDG", "DELIVERY_STN": "HYDG", "CONSIGNOR_PINCODE": "500081", "CONSIGNEE_PINCODE": "500036", "DOCKET_TYPE": "OWNERS RISK", "PROD_SERV_CODE": "18", "ASSURED_DLY_DT": "2021-01-04", "DOCKET_STATUS": "DELIVERED", "APPROVED_DLY_DT": "2021-01-02", "NO_OF_PKGS": 9, "NO_OF_PKGS_DELIVERED": 9, "ACTUAL_WT": 10.23, "CHARGED_WT": 11, "COD_AMT": 0, "COD_TYPE": "G", "DECL_CARGO_VAL": 2882, "CONTRACT_NO": "HYDN/CON/08/2019/0000004", "CONSIGNOR_NAME": "IKEA INDIA PVT LTD(PARCEL SERVICES)", "CONSIGNEE_NAME": "Mani Chandra Rudrangi", "CONSIGNEE_MOBILE_NO": "9000187177", "PDC_BLOCK": "N", "POD_TYPE": "GOOD", "LAST_ATTEMPT_DATE": "2021-01-02 09:53:34", "DEBIT_STATUS": "YES", "OBN_ISS_TVAL": 5000 } ], "sErrMsg": "" } ] }';
            //List<DocketResult> docketResults = (List<DocketResult>)JSON.deserialize(jsonData, List<DocketResult>.class);
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody(jsonData);
            return res;
        }
    }

    @isTest
    public static void CsvDataHandlerTest() {
        Test.setMock(HttpCalloutMock.class, new MyMock());
        List<BulkServiceRequests.csvWrapper> csvWarp = New List<BulkServiceRequests.csvWrapper>();
        BulkServiceRequests.csvWrapper csvWarp1 = New BulkServiceRequests.csvWrapper();
        csvWarp1.Type = 'DELIVERY REQUESTED BEFORE ADD';
        csvWarp1.Description = 'TEST 1';
        csvWarp1.DocketNumber = '104656420';
        csvWarp.add(csvWarp1);
        BulkServiceRequests.csvWrapper csvWarp2 = New BulkServiceRequests.csvWrapper();
        csvWarp2.Type = 'ADD Extension';
        csvWarp2.Description = 'TEST 2';
        csvWarp2.DocketNumber = '104656420';
        csvWarp.add(csvWarp2);
        test.StartTest();
            String sendString = JSON.serialize(csvWarp);
        try{
         	BulkServiceRequests.CsvDataHandler(sendString);   
        }catch(Exception e){}
        test.StopTest();
    }
}