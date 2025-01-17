@isTest
public class TestCCECUpdateApi {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21002","result":"successful", "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    static testmethod void TestMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Case c1 = ServiceTestFactory.getCase8('CRM');
        CCEC__c ccec1 = new CCEC__c();
        ccec1.Case__c = c1.id;
        Insert ccec1;
        ccec1 = [Select Name from CCEC__c where id = :ccec1.id];
        System.debug('CCEC : '+ccec1);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CCECUpdateBulkversion2/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('[{"name": "'+ccec1.Name+'","firstResponsetimeSlab": "8-12Hrs","feedback": "2","cPTadherence": "NO","cCECStatus": "OP","cCECclosureDate": null,"commentsBy": "OU","remarkSeq": 3,"openRemarks": "Testing Hemant to CRM from OU","remarksProvidedBy": "PNQO_20856","remarksDate": "2021-10-27T19:16:52Z","newCcecFlag": null,"newCcecOu": null}]');
        RestContext.request = req;
        RestContext.response= res;
        tempCCECUpdate.doPost();  
        Test.stopTest();     
    }
    static testmethod void TestMethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
            Integration_Log__c log = new Integration_Log__c();
                log.Component_Name__c='CCEC with Remarks Inbound';
                log.Error_Message__c='Test';
                log.IsIntegration__c=true;
                log.Inbound_JSON__c = '{"caseObj":{"Type":"Partial Delivery","Sub_Type__c":"Short at delivery ou","Description":"","Subject":"Complaint Escalation from Mobile App","Origin":"Mobile App","Priority":"High","Customer_Email__c":"harr15.wilson@gmail.com","Customer_Name__c":"Prashant singh","Mobile__c":"9898303627","Complaint_Date__C":" 2022-02-16T17:18:17+05:30","Pick_Up_Ref_No__c":"00202079","Docket_Number__c": "400097001","Delivery_OU__c" : "a0Dp00000060LgGEAU","Pincode__c":"577201"},"RecordType":"Complaint","ccecActionOU":"HYDN","complaintActionOU":"BBI","customercode": "80224588.102","Docket_Validation__c" : "Valid","Type" : "Pick Up","CaseNumber" : null},"customercode":"80224588","recordType":"Complaint","callrecievedOU":"HYDN","callforwardedOU":"HYDN","ccecActionOU":"HYDN","complaintActionOU":"HYDN","pickUpPincode":"577201","Gemrefno":null}';
                log.Outbound_JSON__c = '{"status":"Not Inserted","error":"duplicate value found: Unique_Docket_Subtype__c duplicates value on record with id: 500p00000099I74","caseName":null}';
            try{
                insert log;
        }catch(Exception ex){
            System.debug('---check error--'+ex.getMessage());
        }
        Case c1 = ServiceTestFactory.getCase8('CRM');
        update c1;
        CCEC__c ccec1 = ServiceTestFactory.getCCEC(c1.id);
        ccec1.Proactive_CCEC_Flag__c = false;
        update ccec1;
        System.debug('CCEC : '+ccec1);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CCECUpdateBulkversion2/*';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('[{"name": "'+ccec1.Name+'","firstResponsetimeSlab": "8-12Hrs","feedback": "2","cPTadherence": "NO","cCECStatus": "OP","cCECclosureDate": null,"commentsBy": "OU","remarkSeq": 3,"openRemarks": "Testing Hemant to CRM from OU","remarksProvidedBy": "PNQO_20856","remarksDate": "2021-10-27T19:16:52Z","newCcecFlag": "Y","newCcecOu": "2365414665414"}]');
        RestContext.request = req;
        RestContext.response= res;
        tempCCECUpdate.doPost();  
        Test.stopTest();     
    }
}