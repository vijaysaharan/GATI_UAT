@isTest
public class MISHistoryTriggerTest {
    static testMethod void validateChildCreated() {
        
        MIS__c p = new MIS__c(Email_Id_1__c='abc@gmail.com',Email_Id2__c='abc@gmail.com',Email_Id3__c='abc@gmail.com',Email_Id4__c='abc@gmail.com',Email_Id5__c='abc@gmail.com',Email_Id6__c='abc@gmail.com',Date_Time_of_Email_Sent__c= DateTime.now());
        insert p;
        test.startTest();
        p.Date_Time_of_Email_Sent__c= DateTime.now()+1;
        update p;
        test.stopTest();
    }
    
}