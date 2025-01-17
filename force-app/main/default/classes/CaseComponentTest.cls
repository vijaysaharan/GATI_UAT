@istest
public class CaseComponentTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21004","result":"successful","sErrMsg":"","response":[{"docketNo":"202560616","companyId":"GKE","result":[{"CONSIGNEE_MOBILE_NO":"8976546778","STOCK_OU":"HYDN","DOCKET_NO":"202560616","CONSIGNOR_EMAIL":"nishant@tirupaticolorpens.com","CONSIGNEE_PINCODE":"500002","DOCKET_TYPE":"OWNERS RISK","COD_TYPE":"G","DECL_CARGO_VAL":"5000","CONSIGNOR_NAME":"TESTMATRIX","BOOKING_STN":"HYDN","DOCKET_STATUS":"BOOKED","CONTRACT_NO":"HYDN/CON/08/2021/1020034","ASSURED_DLY_DT":"2021-10-16","CONSIGNOR_MOBILE_NO":"8789098989","ACTUAL_WT":"15","BKG_DT":"2021-10-14","CUSTOMER_CODE":"31023301","DELIVERY_STN":"CHR","CONSIGNOR_PINCODE":"500014","PROD_SERV_CODE":"21","CHARGED_WT":"15","NO_OF_PKGS":"1","CONSIGNEE_NAME":"TESTMATRIX","DEBIT_STATUS":"NO"}],"sErrMsg":""}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    @istest
    static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        caseComponent.docketValidation('202881035');
        Case case1 = new Case();
        case1.CustomerCode__c = 521180.001;
        case1.AccountId = null;
        case1.Origin='Emial';
        case1.Type='Exception';
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        insert case1;
        caseComponent.fetchCaseBasesOnDocket('12534','INTERCHANGED/WRONG');
    }
}