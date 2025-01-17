@isTest 
public class CreateEventHandler_Test {
    @testSetUp static void testDataCreate()
    {
        Account acc=new Account();
        acc.Name='testing';
        acc.AccountNumber='74692';
        insert acc; 
        
        String monthYear = System.now().format('MMMM').substring(0,3).toUpperCase()+'-'+System.now().year();
        
        Customer360__c test360 = new Customer360__c(Customer_Code__c = acc.Id,
                                                    Month_Year__c = monthYear,
                                                    Customer360_Id__c = '30166101.102.'+monthYear+'-testing'
                                                   );
        insert test360;
        
        Customer_Connect__c cc=new Customer_Connect__c();
        cc.Customer_Code__c=acc.id;
        cc.Visit_Start_Date__c=datetime.now();
        cc.Visit_End_Date__c=datetime.now();
        cc.Next_Visit_Date_Time__c=datetime.now()+2;
        insert cc;
        
        Event ev=new Event();
        ev.StartDateTime = datetime.now();
        ev.EndDateTime = datetime.now()+1;
        ev.WhatId=acc.id;
        insert ev;
        
    }
    @isTest static void getCustomerConnectTest()
    { 
        List<Account> acct1=[select id,AccountNumber,Name,Customer_Code__c From  Account Where Name='testing' LIMIT 1];
        List<Customer_Connect__c> custConnect1= [SELECT Id,Next_Visit_Date_Time__c ,Visit_Start_Date__c,Visit_End_Date__c,Customer_Code__c FROM Customer_Connect__c where Customer_Code__c=:acct1[0].Id   LIMIT 1];
        List<Event> ev1=[SELECT Id, Subject, StartDateTime, EndDateTime FROM Event];
        
        
        custConnect1[0].Visit_Start_Date__c=datetime.now();
        custConnect1[0].Visit_End_Date__c=datetime.now();
        custConnect1[0].Next_Visit_Date_Time__c=datetime.now()+2;
        
        update custConnect1;
        
        Test.startTest();
        CreateEventHandler.getCustomerConnect(ev1[0].id);
        
        Test.stopTest();
    }
    
    @isTest static void updatEventDataTest()
    { 
        List<Account> acct1=[select id,AccountNumber,Name,Customer_Code__c From  Account Where Name='testing' LIMIT 1];
        
        List<Customer_Connect__c> custConnect1= [SELECT Id,Next_Visit_Date_Time__c ,Visit_Start_Date__c,Visit_End_Date__c,Customer_Code__c FROM Customer_Connect__c WHERE Customer_Code__c=:acct1[0].Id LIMIT 1];
        List<Event> ev1=[SELECT Id, Subject, StartDateTime, EndDateTime FROM Event LIMIT 1];
        custConnect1[0].Visit_Start_Date__c=datetime.now();
        custConnect1[0].Visit_End_Date__c=datetime.now();
        custConnect1[0].Next_Visit_Date_Time__c=datetime.now()+2;
        
        update custConnect1;
        
        Test.startTest();
        CreateEventHandler.updatEventData(ev1[0].id,'Yes');
        
        Test.stopTest();
    }  
    @isTest static void deleteEventHelperTest()
    {
        List<Account> acct1=[select id,AccountNumber,Name,Customer_Code__c From  Account Where Name='testing' LIMIT 1];
        
        List<Customer_Connect__c> custConnect1= [SELECT Id,Next_Visit_Date_Time__c ,Visit_Start_Date__c,Visit_End_Date__c,Customer_Code__c FROM Customer_Connect__c WHERE Customer_Code__c=:acct1[0].Id  LIMIT 1];
        List<Event> ev1=[SELECT Id, Subject, StartDateTime, EndDateTime FROM Event LIMIT 1];
        custConnect1[0].Visit_Start_Date__c=datetime.now();
        custConnect1[0].Visit_End_Date__c=datetime.now()+1;
        custConnect1[0].Next_Visit_Date_Time__c=datetime.now()+2;
        Delete custConnect1;
        
        
        
        ev1[0].StartDateTime = datetime.now();
        ev1[0].EndDateTime = datetime.now()+1;
        
        Test.startTest();
        CreateEventHandler.deleteEventHelper(custConnect1);
        Test.stopTest();
    }
    
    @isTest
    public static void updateCustomer360(){
        List<Customer_Connect__c> cusConnects = [SELECT Id FROM Customer_Connect__c LIMIT 1];
        test.startTest();
        cusConnects[0].Check_In_Time__c = System.now();
        update cusConnects[0];
        test.stopTest();
    }
    
}