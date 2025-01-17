@istest
public class TestProspectPickup {
     @testSetup static void setup() {
        Case case1=new case();
        case1.Origin='CRM';
        //case1.AccountId=accountId;
        case1.Docket_Validation__c = 'Valid';
        case1.Type='Prospect Pickup';
        case1.Case_Name__c='Testprospectpickup';
        case1.Mobile__c='9923010657';
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Query').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        insert case1;
    }   
public static String CaseId;    
    public class MockHttpResponseGenerator2 implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31014","result":"successful", "sErrMsg":"","response":[{"PROD_CODE":"1","PROD_DESC":"Surface Express","CHARGE_DESC":"ROV","CHARGED_WT":"8000","CHARGE_CODE":"2","CHARGE_AMT":"480"}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testprospectpickup(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        Case cse= [Select Id from Case where Case_Name__c='Testprospectpickup'];
        Test.startTest();
		 ProspectivePickupGetRates_Outbound.proCallOut(cse.id);
        Test.stopTest();
    }

}