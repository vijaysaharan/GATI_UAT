@isTest
public class CsvUploadControllerTest {
    public static String jsonBody='';
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21004","result":"successful", "sErrMsg":"","response":[{"docketNo":"177697167","companyId":"GKE","result":[{"DOCKET_NO":"177697167","PDC_BLOCK":"N"}]}]}');
            res.setStatusCode(200);
            jsonBody = '{"requid":"GS21004","result":"successful", "sErrMsg":"","response":[{"docketNo":"177697167","companyId":"GKE","result":[{"DOCKET_NO":"177697167"}]}]}';
            return res;
        }
    }
    
    @isTest 
    static void csvDataHandlerTest() {
        Organization_Master__c o = new Organization_Master__c();
        o.Name = 'BOMS';
        o.Operational_Status__c ='O';
        o.Status__c ='V';
        o.recordTypeID = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Operation Unit').getRecordTypeId();
        insert o;

        List<CsvuploadController.CsvWrapper> csv = new List<CsvuploadController.CsvWrapper>();
        CsvuploadController.CsvWrapper csv_1 = new CsvuploadController.CsvWrapper();
        csv_1.Type = 'Pending Pickup';
        csv_1.SubType = 'LATE DELIVERY';
        csv_1.CustomerVendor = '10026020.BHOS.102';
        csv_1.PickupRefNumber = '00600378';
        csv_1.CustomerName = 'Manoj';
        csv_1.CustomerEmail = 'sai@gmail.com';
        csv_1.CustomerMobile = '8770897654';
        csv.add(csv_1);

        CsvuploadController.CsvWrapper csv_2 = new CsvuploadController.CsvWrapper();
        csv_2.Type = 'Undelivered';
        csv_2.SubType = 'LATE DELIVERY';
        csv_2.CustomerVendor = '10026020.BHOS.102';
        csv_2.DocketNumber = '177697167';
        csv_2.CustomerName = 'Manoj';
        csv_2.CustomerEmail = 'sai@gmail.com';
        csv_2.CustomerMobile = '8770897654';
        csv.add(csv_2);

        CsvuploadController.CsvWrapper csv_3 = new CsvuploadController.CsvWrapper();
        csv_3.Type = 'Undelivered';
        csv_3.SubType = 'NON DELIVERED';
        csv_3.CustomerVendor = '10026020.BHOS.102';
        csv_3.DocketNumber = '177697167';
        csv_3.CustomerName = 'Manoj';
        csv_3.CustomerEmail = 'sai@gmail.com';
        csv_3.CustomerMobile = '8770897654';
        csv.add(csv_3);

        CsvuploadController.CsvWrapper csv_4 = new CsvuploadController.CsvWrapper();
        csv_4.Type = 'Delayed Connection';
        csv_4.SubType = 'STC cooling';
        csv_4.CustomerVendor = '10026020.BHOS.102';
        csv_4.DocketNumber = '177697167';
        csv_4.CustomerName = 'Manoj';
        csv_4.CustomerEmail = 'sai@gmail.com';
        csv_4.CustomerMobile = '8770897654';
        csv.add(csv_4);

        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            jsonBody = '{"requid":"GS21004","result":"successful", "sErrMsg":"","response":[{"docketNo":"177697167","companyId":"GKE","result":[{"DOCKET_NO":"177697167"}]}]}';
            DocketJson.parse(jsonBody);
            Test.startTest();
            try {
                CsvuploadController.csvDataHandler(JSON.serialize(csv));
            }catch(Exception e){}
            Test.stopTest();
        }
        catch(exception e){
            System.debug('Error In Test => '+e.getMessage());
        }
    }
}