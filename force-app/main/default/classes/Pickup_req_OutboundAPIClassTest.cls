@isTest
public class Pickup_req_OutboundAPIClassTest implements HttpCalloutMock{
    //public class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals(API_credential__mdt.getInstance('CCECRecords').Endpoint__c, req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"requid":"GS21002","product":"2""customerCode":,result":"successful","status":{"desc":"NA"}, "sErrMsg":"","response":[{"contractNo":"HYD/CON/02/2019/1020001","result":"Contract Successfully Extended upto 26-06-2020 20:42:26"}]}');
        res.setStatusCode(200);
        return res;
    }
    //}
    
    @istest
    static void Createdata(){
        List<String> lstCase = new List<String>();
        Contact con1 = TestFactory.getContact('TestName', 'test@gmail.com');
        Account acc1 = TestFactory.getAccount('testt', 'New','201301' , True);
        Case case1=new case();
        
        case1.Docket_Number__c='12534';
        case1.Pick_Up_Ref_No__c ='23498';
        case1.Docket_Validation__c = 'Valid';
        case1.Type= 'Delayed Connection';
        case1.Sub_Type__c= 'INTERCHANGED/WRONG';
        Id crecordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        case1.RecordTypeId=crecordtypeid;
        case1.Pick_Up_Instructions__c='ngfdfghj11';
        case1.No_Of_Packages__c = 2;
        
        case1.Origin='CRM';
        insert case1;
        Integration_Log__c ic = new Integration_Log__c();
        
        ic.Component_Name__c='PickUp log';
        ic.IsIntegration__c=true;
        case1.Mobile__c='9090909090';
        case1.Shipper_Name__c='Manish';
        case1.Pickup_Address1__c='flat 101';
        case1.Pickup_Address2__c='RTC Coloy';
        case1.Pickup_Address3__c='Tirmulgirri';
        Organization_Master__c orgm = TestFactory.getOrganizationMasterextid('test2','500038');//new Organization_Master__c(name ='500003');
        case1.Pick_Up_Pincode__r = orgm;
        case1.Pickup_City__c='Hyderabad';
        case1.Receiver_Pincode__c='500038';
        case1.Company_of__c='102';
        case1.Product__c='2';
        case1.ContactId = con1.Id;
        case1.Actual_Weight__c=100;
        case1.Assured_Delivery_Date__c=date.today()-2;
        case1.COD_Amt__c=555;
        case1.Docket_Number__c='171834841';  
        case1.Docket_Status__c='ergh';
        case1.Volume__c=120;
        case1.No_Of_Packages__c=5;
        case1.Pickup_Date__c=date.today();
        case1.Type_of_Package__c='Carton box';
        insert ic;
        
        
        
        lstCase.add(case1.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Pickup_req_OutboundAPIClassTest());
        Pickup_req_OutboundAPIClass picc = new Pickup_req_OutboundAPIClass();
        Pickup_req_OutboundAPI p = new Pickup_req_OutboundAPI();
        //p.case1.id = lstCase;
        System.enqueueJob(p);
        //picc.PickupPayload();
        Test.stopTest();
    }
}