@isTest
public with sharing class BeatPlaningDashboardTest {
    @TestSetup
    static void makeData(){
        String contractRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
        Account a = new Account();
        a.Name = 'test';
        a.Monthly_Spend_on_Logistic__c = 'Above 15 Lakh';
        a.Contract_end_date__c = System.today();
        insert a;
        a.recordTypeId = contractRecordTypeId;
        update a;
        Test.setCreatedDate(a.Id, System.today()-100);
        Organization_Master__c om = new Organization_Master__c();
        om.Name = '335524';
        om.RecordTypeId = Schema.SObjectType.Organization_Master__c.getRecordTypeInfosByName().get('Pincode Location').getRecordTypeId();
        insert om;
        Lead l = new Lead();
        l.Email='test23456543@gmail.com';
        l.LastName ='Test Lead';
        l.Status ='New';
        l.PostalCode =om.Name;
        l.MobilePhone ='9870006578';
        l.Company ='Test Industries';
        l.Working_start_Date__c=system.today()-3;
        insert l;
    }

    @IsTest
    static void getAccountDataTest(){
        Test.startTest();
        BeatPlaningDashboard.getAccountData();
        Account a = [Select Id from Account Limit 1];
        Customer_Connect__c cc = new Customer_Connect__c();
        cc.Call_Type__c = 'Sales Call';
        cc.Sub_Type__c = 'Contract Signoff';
        cc.Visit_Start_Date__c = System.now()-70;
        cc.Visit_End_Date__c = System.now()-70;
        cc.Customer_Code__c = a.Id;
        cc.Visit_Status__c = 'Visited';
        cc.Visit_Mode__c = 'Virtual Meet';
        cc.Lead__c = [Select Id from Lead LIMIT 1].Id;
        insert cc;
        List<Customer360__c> customer360List = new List<Customer360__c>();
        Customer360__c cust1 = new Customer360__c();
        cust1.Month_Year__c = 'Oct-22';
        cust1.Customer_Code__c = a.Id;
        cust1.Product__c = 'SUR EXPRESS';
        cust1.Customer360_Id__c = '12345678.102.Oct-22.SUR EXPRESS';
        customer360List.add(cust1);
        Customer360__c cust2 = new Customer360__c();
        cust2.Month_Year__c = 'Oct-22';
        cust2.Customer_Code__c = a.Id;
        cust2.Product__c = 'AIR EXPRESS';
        cust2.Customer360_Id__c = '12345678.102.Oct-22.AIR EXPRESS';
        customer360List.add(cust2);
        insert customer360List;
        BeatPlaningDashboard.getAccountData();
        BeatPlaningDashboard.get360Data(a.Id);
        Test.stopTest();
    }

}