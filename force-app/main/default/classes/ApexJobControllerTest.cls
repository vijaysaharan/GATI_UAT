@isTest
public class ApexJobControllerTest {
    
    @isTest
    public static void testGetAllUsers() {
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 5; i++) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName=i +'Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName= i +'standarduser@testorg.com', Isactive=true);
        }
        insert testUsers;
        List<User> result = ApexJobController.getAllUsers();
    }
    
    @isTest
    public static void testMassBatchCallForTransfer() {
        List<String> jobIds = ApexJobController.MassBatchCallForTransfer(new Map<String, Object>(), new Map<String, Boolean>(),'Customer Code');
        System.assertEquals(0, jobIds.size());
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 2; i++) {
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName=i +'Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName= i +'standarduser@testorg.com', Isactive=true);
            testUsers.add(u);
        }
        insert testUsers;
        
        Map<String, Object> ownerData = new Map<String, Object>();
        ownerData.put('1standarduser@testorg.com', new List<Object>());
        ownerData.put('2standarduser@testorg.com', new List<Object>());
        ownerData.put('3standarduser@testorg.com', new List<Object>());
        
        Map<String, Boolean> wrapp = new Map<String, Boolean>();
        wrapp.put('key', true);
        Test.startTest();
        List<String> result = ApexJobController.MassBatchCallForTransfer(ownerData, wrapp,'Customer Code');
        Test.stopTest();
    }
    
    @isTest
    public static void testApexJobsTableData() {
        List<String> jobIds = new List<String> {'jobId1', 'jobId2'};
            List<AsyncApexJob> jobs = ApexJobController.ApexJobsTableData(jobIds);
    }
    
    @isTest
    static void testAbortApexJob() {
        String jobId = 'jobId1';
        Test.startTest();
        ApexJobController.abortApexJob(jobId);
        Test.stopTest();
    }
    
    @isTest
    static void testGetApexJobStatus() {
        AsyncApexJobMock mockJob = new AsyncApexJobMock('TestJobId', 'Processing', 100, 50);
        Test.startTest();
        try{
            ApexJobController.getApexJobStatus('TestJobId');
        }catch(Exception e){}
        Test.stopTest();
    }
    
    private class AsyncApexJobMock {
        public String Id { get; set; }
        public String Status { get; set; }
        public Integer TotalJobItems { get; set; }
        public Integer JobItemsProcessed { get; set; }
        
        public AsyncApexJobMock(String id, String status, Integer totalJobItems, Integer jobItemsProcessed) {
            this.Id = id;
            this.Status = status;
            this.TotalJobItems = totalJobItems;
            this.JobItemsProcessed = jobItemsProcessed;
        }
    }
    
    @isTest
    static void testFetchRecords() {
        Account testAccount = new Account(Name = 'Test Account',GATI_Customer_Code__c='200300');
        insert testAccount;
        ApexJobController.SearchWrapper inputWrapper = new ApexJobController.SearchWrapper();
        inputWrapper.objectApiName = 'Account';
        inputWrapper.otherFieldApiName = 'Name';
        inputWrapper.fieldApiName = 'GATI_Customer_Code__c';
        inputWrapper.searchString = '200300';
        List<ApexJobController.ResultWrapper> resultWrapperList = ApexJobController.fetchRecords(inputWrapper);
    }
}