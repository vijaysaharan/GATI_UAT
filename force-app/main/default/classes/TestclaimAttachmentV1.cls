@isTest
public class TestclaimAttachmentV1 { 
    private class MyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String jsonData = '{ "requid": "GS21004", "result": "successful", "sErrMsg": "", "response": [ { "docketNo": "104656420", "companyId": "GKE", "result": [ { "DOCKET_NO": 104656420, "BKG_DT": "2021-01-02", "CUSTOMER_CODE": "48481001", "BOOKING_STN": "HYDG", "DELIVERY_STN": "HYDG", "CONSIGNOR_PINCODE": "500081", "CONSIGNEE_PINCODE": "500036", "DOCKET_TYPE": "OWNERS RISK", "PROD_SERV_CODE": "18", "ASSURED_DLY_DT": "2021-01-04", "DOCKET_STATUS": "DELIVERED", "APPROVED_DLY_DT": "2021-01-02", "NO_OF_PKGS": 9, "NO_OF_PKGS_DELIVERED": 9, "ACTUAL_WT": 10.23, "CHARGED_WT": 11, "COD_AMT": 0, "COD_TYPE": "G", "DECL_CARGO_VAL": 2882, "CONTRACT_NO": "HYDN/CON/08/2019/0000004", "CONSIGNOR_NAME": "IKEA INDIA PVT LTD(PARCEL SERVICES)", "CONSIGNEE_NAME": "Mani Chandra Rudrangi", "CONSIGNEE_MOBILE_NO": "9000187177", "PDC_BLOCK": "N", "POD_TYPE": "GOOD", "LAST_ATTEMPT_DATE": "2021-01-02 09:53:34", "DEBIT_STATUS": "YES", "OBN_ISS_TVAL": 5000 } ], "sErrMsg": "" } ] }';
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody(jsonData);
            return res;
        }
    }
    
    static testmethod void test_InsertCaseandAttachment(){
        Test.setMock(HttpCalloutMock.class, new MyMock());
        Organization_Master__c o1=TestFactory.getOrganizationMasterextid('1231','12012');
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"12345","Stock_OU__c": "HYDN", "Stock_Receiving_OU__c":"HYDN", "Delivery_OU__c": "HYDN","Pick_Up_Ref_No__c":"12345678"},"RecordType":"Service request","callrecievedOU":"12012","callforwardedOU":"12012","ccecActionOU":"12012","PickUpPincode":"12012","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }],"complaintActionOU":"HYDN","Companyof":"HYDN","Gemrefno":"HYDN"}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();
    }
    
    static testmethod void test_Invaliddata(){
        Organization_Master__c o1=TestFactory.getOrganizationMasterextid('1231','120172');
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"104656420"},"callrecievedOU":"12012","callforwardedOU":"12012","customercode":"567813","ccecActionOU":"12012","PickUpPincode":"12012","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();   
    }
    
    static testmethod void testUpdateAttachments(){
        Contact cc = TestFactory.getContact('abc','a@a.com');
        Case c = ServiceTestFactory.getCaseServiceRequestType2('Claim','NEW',cc.Id);
        Case c1 = [select CaseNumber from case where id=:c.Id ];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"CaseNumber":"'+c1.casenumber+'"},"attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();
    }
    
    static testmethod void testInvalidCaseNumber(){
        String casenumber= '67698';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"CaseNumber":"'+casenumber+'"},"attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost(); 
    }
    
    static testmethod void testRecordTypeComplaint(){
        Test.setMock(HttpCalloutMock.class, new MyMock());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"104656420"},"RecordType":"Complaint","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost(); 
    }
    
    static testmethod void testRecordTypeQuery(){
        Test.setMock(HttpCalloutMock.class, new MyMock());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"104656420"},"RecordType":"Query","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost(); 
    }
    
    static testmethod void testRecordTypeServiceReq(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ClaimAttachmentv1/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"caseObj": {"status":"New","Origin":"Phone","Priority":"Low","Subject":"Damage Product got","Description":"Recieved an damaged product after delivery","Reason":"New problem","Docket_Number__c":"45247","Type":"Pick Up"},"RecordType":"Service Request","attachments": [{"Body": "d29ybGQ=","ContentType": "text/plain","Name": "hello.txt" }]}');
        RestContext.request = req;
        RestContext.response= res;
        ClaimAttachmentAPIVersion1.doPost();
    }
}