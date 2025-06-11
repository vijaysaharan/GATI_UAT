@isTest
private class DocketChangeControllerTest {
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            System.assertEquals(API_credential__mdt.getInstance('DocketNoVerification').Endpoint__c, req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"GS21004","result":"successful", "sErrMsg":"","response":[{"docketNo":"416857232","companyId":"GKE","result":[{"DOCKET_NO":416857232,"BKG_DT":"2025-05-14","CUSTOMER_CODE":"80226264","CONSIGNOR_EMAIL":"vlr@gmail.com","BOOKING_STN":"VNB","DELIVERY_STN":"HYDE","CONSIGNOR_PINCODE":"632006","CONSIGNEE_PINCODE":"500047","DOCKET_TYPE":"OWNERS RISK","PROD_SERV_CODE":"23","ORIGINAL_ADD":"2025-05-17","ASSURED_DLY_DT":"2025-05-17","DOCKET_STATUS":"DELIVERED","CURRENT_DOCKET_STATUS":"DELIVERED","APPROVED_DLY_DT":"2025-05-22","NO_OF_PKGS":1,"NO_OF_PKGS_DELIVERED":1,"ACTUAL_WT":20,"CHARGED_WT":20,"COD_AMT":0,"COD_TYPE":"S","DECL_CARGO_VAL":5000,"CONSIGNOR_NAME":"STUDENT EXPRESS - NEW","CONSIGNOR_MOBILE_NO":"8919485354","CONSIGNEE_NAME":"NARSIMHA RAO","CONSIGNEE_MOBILE_NO":"8008559817","PDC_BLOCK":"N","POD_TYPE":"GOOD","LAST_ATTEMPT_DATE":"2025-05-22 08:11:39","DEBIT_STATUS":"NO","CLAIM_EXCEP":"N"}],"sErrMsg":""}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    @TestSetup
    static void makeData(){
        Id complaintRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        Id oURecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Operation Unit').getRecordTypeId();
        
        Organization_Master__c testOrgMaster_1 = new Organization_Master__c(
            Operational_Status__c = 'O',
            Name = 'HYDE',
            RecordTypeId = oURecordTypeId
        );
        insert testOrgMaster_1;
        Account testAccount_1 = new Account(
        	Customer_Code__c = 80226264.102,
            Name = 'Test Account'
        );
        insert testAccount_1;
        List<Case> testCaseList = new List<Case>();
        Case testCase_1 = new Case(
            RecordTypeId = complaintRecordTypeId,
            Origin = 'Email',
            Subject = 'Test Docket',
            SuppliedEmail = 'docketTest@test.com',
            Type = 'Delayed Connection',
            Sub_Type__c = 'STC cooling',
            Stock_OU__c = testOrgMaster_1.Id,
            Stock_Receiving_OU__c = testOrgMaster_1.Id,
            Docket_Number__c = '416857231'
        );
        testCaseList.add(testCase_1);
        Case testCase_2 = new Case(
            RecordTypeId = complaintRecordTypeId,
            Origin = 'Email',
            Subject = 'Test Docket',
            SuppliedEmail = 'docketTest@test.com',
            Type = 'Undelivered',
            Docket_Number__c = '416857230',
            Sub_Type__c = 'NON DELIVERED'
        );
        testCaseList.add(testCase_2);
        Case testCase_3 = new Case(
            RecordTypeId = complaintRecordTypeId,
            Origin = 'Email',
            Subject = 'Test Docket',
            SuppliedEmail = 'docketTest@test.com',
            Type = 'Partial Delivery',
            Docket_Number__c = '416857229'
        );
        testCaseList.add(testCase_3);
        Case testCase_4 = new Case(
            RecordTypeId = complaintRecordTypeId,
            Origin = 'Email',
            Subject = 'Test Docket',
            SuppliedEmail = 'docketTest@test.com',
            Type = 'Claims',
            Docket_Number__c = '416857228'
        );
        testCaseList.add(testCase_4);
        Case testCase_5 = new Case(
            RecordTypeId = complaintRecordTypeId,
            Origin = 'Email',
            Subject = 'Test Docket',
            SuppliedEmail = 'docketTest@test.com',
            Type = 'Invoicing and Others',
            Docket_Number__c = '416857227'
        );
        testCaseList.add(testCase_5);
        Case testCase_6 = new Case(
            RecordTypeId = complaintRecordTypeId,
            Origin = 'Email',
            Subject = 'Test Docket',
            SuppliedEmail = 'docketTest@test.com',
            Type = 'Query',
            Docket_Number__c = '416857226'
        );
        testCaseList.add(testCase_6);
        Case testCase_7 = new Case(
            RecordTypeId = complaintRecordTypeId,
            Origin = 'Email',
            Subject = 'Test Docket',
            SuppliedEmail = 'docketTest@test.com',
            Type = 'Delayed Connection',
            Stock_Receiving_OU__c = testOrgMaster_1.Id,
            Docket_Number__c = '416857225'
        );
        testCaseList.add(testCase_7);
        insert testCaseList;
    }

    @isTest static void updateDocketTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Case> testCaseList = [SELECT Id FROM Case];
        test.startTest();
        DocketChangeController.updateDocketNumber('416857230', testCaseList[0].Id);
        DocketChangeController.updateDocketNumber(null, testCaseList[0].Id);
        try{
            DocketChangeController.updateDocketNumber('416857232', null);
        }catch(Exception e){}
		DocketChangeController.updateDocketNumber('416857231', testCaseList[0].Id);        
        DocketChangeController.updateDocketNumber('416857232', testCaseList[0].Id);
        DocketChangeController.updateDocketNumber('416857232', testCaseList[1].Id);
        DocketChangeController.updateDocketNumber('416857232', testCaseList[2].Id);
        DocketChangeController.updateDocketNumber('416857232', testCaseList[3].Id);
        DocketChangeController.updateDocketNumber('416857232', testCaseList[4].Id);
        DocketChangeController.updateDocketNumber('416857232', testCaseList[5].Id);
        DocketChangeController.updateDocketNumber('416857232', testCaseList[6].Id);
        test.stopTest();
    }
}