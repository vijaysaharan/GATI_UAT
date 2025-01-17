@isTest
public class GatiMDMTest {
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Boolean isBodyReturn;        
        public MockHttpResponseGenerator(Boolean isBodyReturn) {
            this.isBodyReturn = isBodyReturn;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String responseBody;
            if (isBodyReturn) {
                responseBody = '{ "rows": [ { "label": "CM0000000927", "content": { "CUST_CONTR_SEQ_NUM": { "content": "CM0000000927" } } } ] }';
            } else {
                responseBody = '{}';
            }
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }   
    }
    
    
    @TestSetup
    static void makeData(){
        Account testAccountChild = TestFactory.getAccount('Test', 'MSME', '301019', TRUE);
        Account testAccountParent = TestFactory.getAccount('Test', 'MSME', '301019', TRUE);
        testAccountChild.ParentId = testAccountParent.Id;
        testAccountChild.LOF_Number__c = '12345.102';
        update testAccountChild;
        TestFactory.getAccountTeamMember(testAccountChild.Id, System.UserInfo.getUserId(), 'Service Resource');
        Opportunity testOpportunity = new Opportunity(AccountId = testAccountChild.Id,
                                                      Name = 'Test Opportunity', 
                                                      StageName = 'qualified',
                                                      CloseDate = System.today().addDays(2)
                                                     );
        insert testOpportunity;
        List<Quote> testQuoteList = new List<Quote>();
        Quote testQuote1 = new Quote(Name = 'Test Quote',
                                     OpportunityId = testOpportunity.Id,
                                     Test_LOF_number__c = 'ABC/LOF/123.102'                                    
                                    );
        testQuoteList.add(testQuote1);
        Quote testQuote2 = new Quote(Name = 'Test Quote',
                                     OpportunityId = testOpportunity.Id,
                                     Test_LOF_number__c = 'ABC/CON/123.102'                                    
                                    );
        testQuoteList.add(testQuote2);
        insert testQuoteList;
    }
    
    @isTest
    static void testConvertCreationResponse(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false));
        GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
        input.action = 'Convert-Creation-Response';
        input.jsonString = '{"Response" : []}';
        Test.startTest();
        List<GatiMDMUtil.ActionOutput> outputs = GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
        Test.stopTest();
        System.assertEquals( 0 , outputs[0].creationResponse.Response.size(), 'The size of response in 0' );
    }
    
    @isTest
    static void testApprovalRequest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false));
        GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
        input.action = 'Approval-Request';
        input.approval_existing_cust_id = 'TEST';
        input.approval_additional_approver_requested_by_user = 'Y';
        input.approval_query_fired = 'Y';
        input.opportunityId = 'TEST';
        input.authorizationHeader = 'test';
        Test.startTest();
        List<GatiMDMUtil.ActionOutput> outputs = GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
        Test.stopTest();
        System.assertEquals( 200 , outputs[0].approvalStatusCode, 'The response status code is 200' );   
    }
    
    @isTest
    static void testCSUpdate(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false));
        GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
        input.action = 'CS-Update';
        input.accountTeamMember = [SELECT AccountId, UserId FROM AccountTeamMember LIMIT 1];
        input.authorizationHeader = 'test';
        Test.startTest();
        List<GatiMDMUtil.ActionOutput> outputs = GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
        Test.stopTest();
        System.assertEquals( 200 , outputs[0].cmStatusCode, 'The response status code is 200' );   
    }
    
    @isTest
    static void testSubCodeCreation(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false));
        GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
        input.action = 'Sub-Code-Creation';
        input.account = [SELECT Id, ParentId FROM Account WHERE ParentId != null LIMIT 1];
        input.authorizationHeader = 'test';
        Test.startTest();
        List<GatiMDMUtil.ActionOutput> outputs = GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
        Test.stopTest();
        System.assertEquals( 200 , outputs[0].subCodeCreationStatusCode, 'The response status code is 200' );   
    }
    
    @isTest
    static void testSendLOFCreateWithAccount(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(false));
        GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
        input.action = 'Create-LOF-Account';
        input.account = [SELECT Id, GATI_Customer_Code__c, LOF_Number__c FROM Account WHERE ParentId != null LIMIT 1];
        input.quoteData = [SELECT Id, LOF_Amendment_Date__c, Test_LOF_number__c, AmendedVersion__c FROM Quote Where Test_LOF_number__c = 'ABC/LOF/123.102' LIMIT 1];
        input.authorizationHeader = 'test';
        Test.startTest();
        List<GatiMDMUtil.ActionOutput> outputs = GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
        Test.stopTest();
        System.assertEquals( 200 , outputs[0].subCodeCreationStatusCode, 'The response status code is 200' );  
    }
    
    @isTest
    static void testSendCONUpdatedAccount(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(true));
        GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
        input.action = 'Update-CON-Account';
        input.account = [SELECT Id, GATI_Customer_Code__c, LOF_Number__c, Contract_Amendment_Date__c, Remarks__c, Contract_Activation_Date__c, GATI_Contract_Number__c, Contract_Status__c FROM Account WHERE ParentId != null LIMIT 1];
        input.authorizationHeader = 'test';
        input.quoteData = [SELECT Id,LOF_Amendment_Date__c, Test_LOF_number__c, OpportunityId, AmendedVersion__c FROM Quote Where Test_LOF_number__c = 'ABC/CON/123.102' LIMIT 1];
        Test.startTest();
        List<GatiMDMUtil.ActionOutput> outputs = GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
        Test.stopTest();  
    }
    
    @isTest
    static void testGatiMDMCreationResponseBodyWrapper(){
        GatiMDMCreationResponseBodyWrapper body = new GatiMDMCreationResponseBodyWrapper();
        GatiMDMCreationResponseItemWrapper item = new GatiMDMCreationResponseItemWrapper();
        item.Oppurtunity = null;
        item.Existing_Customer_Code = null;
        item.Existing_Customer_Contract = null;
        item.Customer_Pan_Number = null;
        item.Customer_Phone_Number = null;
        item.Customer_Email_ID = null;
        item.Customer_Name = null;
        item.Customer_Category = null;
        item.Customer_OU_Code = null;
        body.Response = new List<GatiMDMCreationResponseItemWrapper>{item};
            System.assertEquals(1 , body.Response.size(), 'The response has one item');
    }
    
    @isTest 
    static void testResponseObject(){
                MDMContractCreationResponse.ResponseObject testObj = new MDMContractCreationResponse.ResponseObject();
                testObj.Oppurtunity = 'test';
                testObj.Existing_Customer_Code = 'test';
                testObj.Customer_OU_Code = 'test';
                testObj.Customer_Category = 'test';
                testObj.Customer_Name = 'test';
                testObj.Customer_Email_ID = 'test';
                testObj.Customer_Phone_Number = 'test';
                testObj.Customer_Pan_Number = 'test';
                testObj.Existing_Customer_Contract = new List<String>{'test'};     
            }
}