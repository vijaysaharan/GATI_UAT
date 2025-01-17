@isTest
public class SendMOMControllerTest {
    @testSetup static void createData(){        
        Account testAcc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', GATI_Contract_Number__c = 'CON/1234', Customer_Category__c = 'KEA');
        insert testAcc;
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', 
                                              StageName = 'qualified',
                                              CloseDate = System.today().addDays(2)
                                             );
        insert testOpp;
        Customer_Connect__c testConnect = new Customer_Connect__c(Key_Discussion_Description__c = 'Testing discussion',
                                                                  Visit_Start_Date__c = System.now(),
                                                                  Visit_End_Date__c = System.now().addHours(1),
                                                                  Call_Type__c = 'General Price Increase',
                                                                  Sub_Type__c = 'Agreed Full Price Increase',
                                                                  Opportunity__c = testOpp.Id,
                                                                  Closure_Remarks__c = 'Closer Remark',
                                                                  Customer_Code__c = testAcc.Id
                                                                 );
        insert testConnect;
		Attendee__c attendee = new Attendee__c(Customer_Connect__c = testConnect.Id);
		insert attendee;
        Actionable__c testAction = new Actionable__c(Include_in_MOM__c = true,
                                                     Customer_Connect__c= testConnect.Id
                                                    );
        insert testAction;
        Contact testCon = new Contact(LastName = 'Test Contact',
                                      AccountId = testAcc.Id
                                     );
        insert testCon;
    }
    
    @isTest
    public static void getSubjectAndBodyTest(){
        EmailTemplate testTemp = new EmailTemplate(Name = 'Email Template', 
                                                   DeveloperName = 'TestTemplate', 
                                                   TemplateType = 'custom', 
                                                   HtmlValue = 'Hi<br/>Test', 
                                                   Subject = 'Testing',
                                                   isActive = true,
                                                   FolderId = UserInfo.getUserId()
                                                  );
        insert testTemp;
        test.startTest();
        List<SendMOMController.wrapperClass> results = SendMOMController.getSubjectAndBody(testTemp.Id, null, null);
        SendMOMController.getDefaultTemplateId(testTemp.DeveloperName);
    	test.stopTest();
    }
    
    @isTest
    public static void sendMailToSelectedContactTest(){
        Customer_Connect__c testConnect = [SELECT Id FROM Customer_Connect__c LIMIT 1];
        List<String> toAddress = new List<String>{'test@gmail.com'};
        test.startTest();
        SendMOMController.sendMailToSelectedContact(toAddress, null, null, '', 'Test Subject', 'Hi<br/>Tester.', testConnect.Id, new List<String>{}, new List<String>{}, new List<String>{}, 'Test');
    	SendMOMController.excelData excel = SendMOMController.getCustomerConnectData(testConnect.Id);
        SendMOMController.getDefaultEmailIds(testConnect.Id);
        test.stopTest();
    }
    
    @isTest
    public static void fetchLookUpValuesTest(){
        test.startTest();
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('Test','Contact',null);
        test.stopTest();
    }
    
    @isTest
    public static void ContactDetailTest(){
        Contact testCon = [SELECT Id FROM Contact LIMIT 1];
        test.startTest();
        reUsableMultiSelectLookupCtrl.ContactDetail(testCon.Id);
        test.stopTest();
    }
    
    @isTest
    public static void searchDBTest(){
        EmailTemplate testTemp = new EmailTemplate(Name = 'Email Template', 
                                                   DeveloperName = 'TestTemplate', 
                                                   TemplateType = 'custom', 
                                                   HtmlValue = 'Hi<br/>Test', 
                                                   Subject = 'Testing',
                                                   isActive = true,
                                                   FolderId = UserInfo.getUserId()
                                                  );
        insert testTemp;
        test.startTest();
        DynamicReUseableLookUp_crt.searchDB('EmailTemplate','HtmlValue','Subject',1,'DeveloperName','Test');
        test.stopTest();
    }
}