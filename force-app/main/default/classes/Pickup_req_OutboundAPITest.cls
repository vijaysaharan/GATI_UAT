@isTest
public class Pickup_req_OutboundAPITest {
     public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            
            //System.assertEquals('https://pg-uat.gati.com/G2S/SFDC2Gati.jsp', req.getEndpoint());
            System.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"requid":"SG31006","result":"successful", "sErrMsg":"","response":[{"complaintRefNo":"00439524","result":"Posted Successfully "}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    private static void CreateData(){
         List<Case> lstCase = new List<Case>();
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
       
        Integration_Log__c ic = new Integration_Log__c();
        
        ic.Component_Name__c='PickUp log';
        ic.IsIntegration__c=true;
        case1.Mobile__c='9090909090';
        case1.Shipper_Name__c='Manish';
        case1.Pickup_Address1__c='flat 101';
        case1.Pickup_Address2__c='RTC Coloy';
        case1.Pickup_Address3__c='Tirmulgirri';
        Organization_Master__c orgm = TestFactory.getOrganizationMasterextid('test2','500038');//new Organization_Master__c(name ='500003');
        case1.Pick_Up_Pincode__c = orgm.id;
        case1.Pickup_City__c='Hyderabad';
        case1.Receiver_Pincode__c='500038';
        case1.Company_of__c='102';
        case1.Product__c='2';
        case1.ContactId = con1.Id;
        case1.Actual_Weight__c=100;
        case1.Assured_Delivery_Date__c=date.today()-2;
        //case1.COD_Amt__c=555;
        case1.Docket_Number__c='171834841';  
        case1.Docket_Status__c='ergh';
        case1.Volume__c=120;
        case1.No_Of_Packages__c=5;
        case1.Pickup_Date__c=date.today();
        case1.Type_of_Package__c='Carton box';
        case case2 = new case();
        case2.CCEC_Action_OU__r= orgm;
        case2.CustomerCode__c = 521180.001;
        case2.AccountId = null;
        case2.Origin='Emial';
        case2.Type='Exception';
        case2.Docket_Number__c='12534';
        case2.Pick_Up_Ref_No__c ='23498';
        case2.Docket_Validation__c = 'Valid';
        case2.Type='Pending Pickup';
        case2.Sub_Type__c= 'LATE PICKUP';
        case2.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        insert case2;
        insert case1;
        
        lstCase.add(case1);
        lstCase.add(case2);
        insert ic;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Pickup_req_OutboundAPI p = new Pickup_req_OutboundAPI();
        p.caseList = lstCase;
        Pickup_req_OutboundAPI.dummy();
        Database.executeBatch(p, 2);

    }
}