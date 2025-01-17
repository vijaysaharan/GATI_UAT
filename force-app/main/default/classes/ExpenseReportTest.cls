@isTest
public class ExpenseReportTest {

    static testMethod void setupTestData(){
    
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Expense__c' AND DeveloperName = 'Travel'];
         
        Visit__c v = new Visit__c();
        v.Employee_Name__c = UserInfo.getUserId();
        v.Visit_Start_DateTime__c = Datetime.valueOf('2023-08-15 12:30:00');
        v.Visit_End_DateTime__c = Datetime.valueOf('2023-08-15 17:30:00');
        Insert v;
        
        Expense__c e = new Expense__c();
        e.Visit__c = v.Id;
        e.Employee_Name__c=v.Employee_Name__c;
        e.RecordTypeId =rt.Id; 
        e.From__c= 'A';
        e.To__c= 'B';
        e.Mode__c= 'Two Wheeler';
        e.Amount__c= 1;
        e.Distance__c= 1;
        e.Description__c= 'X';
        e.From_Date__c= Date.today();
        e.To_Date__c= Date.today();
        e.No_of_Days__c= 1;
        e.City_Name__c= 'A';
        e.State_Name__c= 'Uttar Pradesh';
        e.Paticulars__c= 'A';
        e.HotelLodgeName__c= 'A';
        e.Bill_No__c= 'A';      
        Insert e;
                
        Apexpages.Standardcontroller controller = new Apexpages.Standardcontroller(e);
        ExpenseReport obj = new  ExpenseReport(controller);
    
    }

}