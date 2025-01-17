@istest
public class WeeklyEventPlanBatch_Test {
    @testSetUp static void testMethod_2()
    {
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email =  'abc@test.com',
                         Username =  'johngdcuchudh@acme.com', 
                         TimeZoneSidKey = 'America/Los_Angeles',
                         Alias = 'nuser', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id
                        ); 
        
        
        insert uu;
        
        Account ac=new Account();
        ac.Name='Test';
        ac.BillingPostalCode = '201307';
        insert ac;
        
        Customer_Connect__c cc=new Customer_Connect__c();
        //cc.Name='abc';
        cc.Visit_Start_Date__c=datetime.now();
        cc.Visit_End_Date__c=datetime.now()+1;
        cc.Customer_Code__c=ac.id;
        cc.OwnerId=uu.id;
        
        insert cc; 
    }
    
    @isTest static void executeTest(){
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        List<User> us=[Select id from User where firstname = 'ABC' LIMIT 1];
        List<Account>ac=[select id,Name,Customer_Code__c from Account where Name='Test' LIMIT 1];          
        List<Customer_Connect__c> cc1=[Select id,Visit_Start_Date__c,Visit_End_Date__c,Customer_Code__c from Customer_Connect__c where Customer_Code__c=:ac[0].id LIMIT 1 ];
         
        Customer_Connect__c cc2=new Customer_Connect__c();
        //cc.Name='abc';
        cc2.Visit_Start_Date__c=datetime.now();
        cc2.Visit_End_Date__c=datetime.now();
        cc2.Customer_Code__c=ac[0].id;
        //cc2.OwnerId=us[0].id;
        
        insert cc2; 
         
        Test.startTest();
        WeeklyEventPlanBatch wepb= new WeeklyEventPlanBatch();
        Database.executeBatch(wepb);
        WeeklyEventPlanBatchSchedular weeklySchedular = new WeeklyEventPlanBatchSchedular();
        weeklySchedular.execute(null);
        Test.stopTest();
    }
    
}