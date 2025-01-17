@isTest
public class DashboardDataCaseToZeroBatchTest {
    @testSetup static void makeData(){
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Account> accList = new List<Account>();
        Account testAccount1 = new Account(Name = 'Test Account 1');
        accList.add(testAccount1);
        Account testAccount2 = new Account(Name = 'Test Account 2');
        accList.add(testAccount2);
        insert accList;
        List<CustomerDashboard__c> testDashboards = new List<CustomerDashboard__c>();
        testDashboards.add(new CustomerDashboard__c(
            Contract_Number__c = '1',
            AccountName__c = testAccount1.Id,
            CasesClosedL3M__c = 10,
            CasesClosedLM__c = 20,
            CasesClosedMTD__c = 5,
            CasesClosedYTD__c = 30,
            CasesOpenL3M__c = 15,
            CasesOpenLM__c = 25,
            CasesOpenMTD__c = 8,
            CasesOpenYTD__c = 35,
            LastTradeDate__c = System.Today()
        ));
        testDashboards.add(new CustomerDashboard__c(
            Contract_Number__c = '2',
            AccountName__c = testAccount2.Id,
            CasesClosedL3M__c = 10,
            CasesClosedLM__c = 20,
            CasesClosedMTD__c = 5,
            CasesClosedYTD__c = 30,
            CasesOpenL3M__c = 15,
            CasesOpenLM__c = 25,
            CasesOpenMTD__c = 8,
            CasesOpenYTD__c = 35,
            LastTradeDate__c = System.Today().addDays(-31)
        ));
        insert testDashboards;
        
        List<Customer360__c> cusList = new List<Customer360__c>();
        Customer360__c test360_1 = new Customer360__c(
            Customer_Code__c = testAccount1.Id,
            MTD__c = 200,
            Current_Month_OS__c = 200,
            ABSL_Outbound__c = 20,
            ABSL_Inbound__c = 20,
            DIFOT__c = 30,
            Ch_wt_MTD__c = 200,
            No_of_dkt_MTD__c = 12,
            LM_TD__c = 100,
            COLL_as_on_date__c = 10,
            CYLM_No_of_Dockets__c = 1,
            CYLM_Charged_Wt__c = 1,
            On_time_arrival_Dockets__c = 5,
            ON_time_delivered_with_out_deps__c = 5,
            Total_Assured_Dockets__c = 8,
            As_on_date__c = System.today(),
            Customer360_Id__c = '15226034.102.OCT-2022.SUR EXPRESS'
        );
        cusList.add(test360_1);
        Customer360__c test360_2 = new Customer360__c(
            Customer_Code__c = testAccount2.Id,
            MTD__c = 200,
            Current_Month_OS__c = 200,
            ABSL_Outbound__c = 20,
            ABSL_Inbound__c = 20,
            DIFOT__c = 30,
            Ch_wt_MTD__c = 200,
            No_of_dkt_MTD__c = 12,
            LM_TD__c = 100,
            COLL_as_on_date__c = 10,
            CYLM_No_of_Dockets__c = 1,
            CYLM_Charged_Wt__c = 1,
            On_time_arrival_Dockets__c = 5,
            ON_time_delivered_with_out_deps__c = 5,
            Total_Assured_Dockets__c = 8,
            Customer360_Id__c = '15226035.102.OCT-2022.SUR EXPRESS',
            As_on_date__c = Date.today().addDays(-32)
        );
        cusList.add(test360_2);
        Customer360__c test360_3 = new Customer360__c(
            Customer_Code__c = testAccount1.Id,
            MTD__c = 200,
            Current_Month_OS__c = 200,
            ABSL_Outbound__c = 20,
            ABSL_Inbound__c = 20,
            DIFOT__c = 30,
            Ch_wt_MTD__c = 200,
            No_of_dkt_MTD__c = 12,
            LM_TD__c = 100,
            COLL_as_on_date__c = 10,            
            CYLM_No_of_Dockets__c = 1,
            CYLM_Charged_Wt__c = 1,
            On_time_arrival_Dockets__c = 5,
            ON_time_delivered_with_out_deps__c = 5,
            Total_Assured_Dockets__c = 8,
            Customer360_Id__c = '15226036.102.OCT-2022.SUR EXPRESS',
            As_on_date__c = Date.today().addDays(-92)
        );
        cusList.add(test360_3);
        Customer360__c test360_4 = new Customer360__c(
            Customer_Code__c = testAccount2.Id,
            MTD__c = 200,
            Current_Month_OS__c = 200,
            ABSL_Outbound__c = 20,
            ABSL_Inbound__c = 20,
            DIFOT__c = 30,
            Ch_wt_MTD__c = 200,
            No_of_dkt_MTD__c = 12,
            LM_TD__c = 100,
            COLL_as_on_date__c = 10,
            CYLM_No_of_Dockets__c = 1,
            CYLM_Charged_Wt__c = 1,
            On_time_arrival_Dockets__c = 5,
            ON_time_delivered_with_out_deps__c = 5,
            Total_Assured_Dockets__c = 8,
            Customer360_Id__c = '15226037.102.OCT-2022.SUR EXPRESS',
            As_on_date__c = Date.today().addDays(-182)
        );
        cusList.add(test360_4);
        insert cusList;
    }
    
    @isTest
    static void testBatchUpdatesDashboardRecords() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id complaintRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint').getRecordTypeId();
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        Case cs = new Case(AccountId = testAccount.Id, RecordTypeId = complaintRecordId, Type = 'Delayed Connection', Sub_Type__c = 'MISROUTE', Docket_Number__c = '983456787');
        insert cs;
        List<Case> csList = new List<Case>();
        Case cs1 = new Case(AccountId = testAccount.Id, Pick_Up_Ref_ID__c = cs.Id, RecordTypeId = complaintRecordId, Type = 'Pending Pickup', Sub_Type__c = 'MISSED PICKUP', CreatedDate = Date.newInstance(System.today().year(), System.today().month(), 1).addMonths(-1));
        csList.add(cs1);
        Case cs2 = new Case(AccountId = testAccount.Id, Pick_Up_Ref_ID__c = cs.Id, Complaint_Status__c = 'O', RecordTypeId = complaintRecordId, Type = 'Pending Pickup', Sub_Type__c = 'MISSED PICKUP');
        csList.add(cs2);
        Case cs3 = new Case(AccountId = testAccount.Id, Pick_Up_Ref_ID__c = cs.Id, RecordTypeId = complaintRecordId, Type = 'Pending Pickup', Sub_Type__c = 'MISSED PICKUP');
        csList.add(cs3);
        Case cs4 = new Case(AccountId = testAccount.Id, Pick_Up_Ref_ID__c = cs.Id, Complaint_Status__c = 'O', RecordTypeId = complaintRecordId, Type = 'Pending Pickup', Sub_Type__c = 'MISSED PICKUP');
        csList.add(cs4);
        insert csList;
        
        Customer_Connect__c cc1 = new Customer_Connect__c(Customer_Code__c = testAccount.Id, Visit_Start_Date__c = System.now(), Visit_End_Date__c = System.now().addhours(1));
        insert cc1;
        
        Test.startTest();
        cs2.Complaint_Status__c = 'C';
        cs4.Complaint_Status__c = 'C';
        update csList;
        DashboardDataCaseToZeroBatch batchJob = new DashboardDataCaseToZeroBatch();
        Database.executeBatch(batchJob);
        CustomerDashboardSchedulable batch2Job = new CustomerDashboardSchedulable();
        batch2Job.execute(null); 
        Test.stopTest();
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data":{"uiapi":{"query":{"Case":{"totalCount":5}}}}}');
            res.setStatusCode(200);
            return res;
        }
    }
}