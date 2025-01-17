@isTest
public class LeadTriggerHelperForCrossSell_Test {
    
    private class MockCalloutTest implements HttpCalloutMock {
        public Boolean isSuccess;
        public MockCalloutTest(Boolean isSuccess){
            this.isSuccess = isSuccess;
        }
        public HttpResponse respond(HttpRequest req) {
            String jsonData = '{\"compositeResponse\":[{\"body\":{\"id\":\"00QBl00000ASOCvMAP\",\"success\":true,\"errors\":[]},\"httpHeaders\":{\"Location\":\"/services/data/v53.0/sobjects/Lead/00QBl00000ASOCvMAP\"},\"httpStatusCode\":201,\"referenceId\":\"refAccount\"}]}';
            String errorJSON = '{\"compositeResponse\":[{\"body\":[{\"message\":\"LeadAlreadyGenerated..!\",\"errorCode\":\"FIELD_CUSTOM_VALIDATION_EXCEPTION\",\"fields\":[]}],\"httpHeaders\":{},\"httpStatusCode\":400,\"referenceId\":\"refAccount\"}]}';
            HttpResponse res = new HttpResponse();
            if(isSuccess){
             	res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody(jsonData);   
            }else{
                res.setStatus('NOT OK');
                res.setStatusCode(400);
                res.setBody(errorJSON);
            }
            return res;
        }
    }
    
    @isTest
    public static void CreateLeadData(){
        Test.setMock(HttpCalloutMock.class, new MockCalloutTest(false));
        List<Organization_Master__c> oMasterList = New List<Organization_Master__c>();
        List<User> uListForInsert = New List<User>();
        List<Lead> leadList = new List<Lead>();
        
        Organization_Master__c o1 = new Organization_Master__c(Name='201301');
        oMasterList.add(o1);
        Organization_Master__c o2 = new Organization_Master__c(Name='842003');
        oMasterList.add(o2);
        Organization_Master__c o3 = new Organization_Master__c(Name='201307');
        oMasterList.add(o3);
        insert oMasterList;

        User u1 = new User(
            Alias = 'iamsyed',
            Email = 'iamsyed@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'iamsyed@gamil.com',
            ProfileId = UserInfo.getProfileId(),
            UserRole = [SELECT Id FROM UserRole WHERE Name = 'INSIDE SALES' LIMIT 1]
        );
        uListForInsert.add(u1);
        User u2 = new User(
            Alias = 'iamsyed1',
            Email = 'iamsyed1@gmail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'iamsyed1@gamil.com',
            ProfileId = UserInfo.getProfileId(),
            UserRole = [SELECT Id FROM UserRole WHERE Name = 'INSIDE SALES' LIMIT 1]
        );
        uListForInsert.add(u2);
        insert uListForInsert;
        
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Lead';
        ld.LeadSource = 'Cross Sell';
        ld.Company = 'kloudracc Software';
        ld.Email= 'akumar4@kloudrac1.com';
        ld.MobilePhone = '8052124482';
        ld.Turnover_of_the_Company__c =200000000;
        ld.Expected_Business_Per_Month__c =100000;
        ld.Customer_Potential__c = 200000;
        ld.Monthly_Spent_on_express_Logistic__c = 'Less Than and Equal To 1 Lakh';
        ld.PostalCode = '201301';
        ld.GATI_Company_Code__c = '103';
        ld.Product__c = 'Express';
        ld.Lead_Data__c = 'Customer';
        ld.Cross_Sell_Receiver_Email_Id__c='simam@klodtest.com';
        ld.Cross_Sell_Sender_Name__c='Imam';
        ld.Cross_Sell_Receiver_Name__c='kyadav';
        ld.Description__c = 'Cross Sell Description test';
        ld.OwnerId = u1.Id;
        insert ld;
        leadList.add(ld);
        
        Lead ld1 = new Lead();
        ld1.FirstName = 'Test1';
        ld1.LastName = 'Lead1';
        ld1.LeadSource = 'Cross Sell';
        ld1.GATI_Company_Code__c = '103';
        ld1.Turnover_of_the_Company__c =200000000;
        ld1.Expected_Business_Per_Month__c =100000;
        ld1.Product__c = 'Express';
        ld1.Company = 'kloudraccc Software';
        ld1.Email= 'akumar78844@kloudraccc.com';
        ld1.MobilePhone = '8707053042';
        ld1.PostalCode ='842003';
        ld1.Customer_Potential__c = 200000;
        ld1.Monthly_Spent_on_express_Logistic__c = 'Less Than and Equal To 5 Lakh';
        ld1.Lead_Data__c = 'Customer';
        ld1.Status = 'Converted';
        ld1.Description__c = 'Cross Sell Description test';
        ld1.OwnerId = u1.Id;
        insert ld1;
        leadList.add(ld1);
        
        Lead ld2 = new Lead();
        ld2.FirstName = 'Test1';
        ld2.LastName = 'Lead1';
        ld2.LeadSource = 'Cross Sell';
        ld2.GATI_Company_Code__c = '103';
        ld2.Turnover_of_the_Company__c =200000000;
        ld2.Expected_Business_Per_Month__c =100000;
        ld2.Product__c = 'Express';
        ld2.Company = 'kloudraccc Software';
        ld2.Email= 'akumar788445@kloudraccc.com';
        ld2.MobilePhone = '8707053042';
        ld2.Customer_Potential__c = 200000;
        ld2.Monthly_Spent_on_express_Logistic__c = 'Less Than and Equal To 5 Lakh';
        ld2.PostalCode = '201307';
        ld2.Lead_Data__c = 'Customer';
        ld2.Status = 'Revisit';
        ld2.Reason_for_Revisit__c = 'Testing';
        ld2.Revisit_Date__c = System.today()+1;
        ld2.CreatedDate = System.today();
        ld2.Description__c = 'Cross Sell Description test';
        ld2.OwnerId = u1.Id;
        insert ld2;
        leadList.add(ld2);
        
        //insert leadList;
        
        LeadEmailNotificationBatch obj = new LeadEmailNotificationBatch();
        database.executeBatch(obj);
        obj.execute(null, leadList);
        
        Date revisitDate = Date.today();
        String reasonRevisit = 'Test Reason';
        List<String> toEmail = new List<String>{ 'test@example.com' };
            String ccEmail = 'cc@example.com';
        String fromEmailId = 'kyadav@kloudrac.com';
        Test.startTest();
        ld1.OwnerId = u2.Id;
        update ld1;
        ld2.Reason_for_Revisit__c = 'Testing update';
        update ld2;
        LeadTriggerHelperForCrossSell.sendEmailNotification(leadList);
        Test.stopTest();
    }
}