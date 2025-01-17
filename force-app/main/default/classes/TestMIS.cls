@isTest 
public class TestMIS {
    // Test.startTest();
     
@istest static void taskMIS(){
    Account ac = TestFactory.getAccountCC('SiriSirir','KEA','243122',true);
    update ac;
    User uu=TestFactory.getUser1('BDFS','zBDFS','America/Los_Angeles','en_US','UTF-8','en_US','test.bdfshead1@gati.com','standarduser1@testorg.com');
     MIS__c mis =TestFactory.getMIS(ac.Id,true,'SL','BKG','order_no','102');
    //mis.Customer_Code__c=ac.id;
    Task tsk             = new Task();
            tsk.OwnerId          = uu.Id;
            //tsk.WhoId            = mis.Id;
            tsk.WhatId           = mis.Customer_Code__r.Id;
            tsk.ActivityDate     = System.today();
            tsk.Status           = 'Open';
            tsk.Priority         = 'Normal';
            tsk.Subject ='MIS Remainder for '+mis.Customer_Code__r.Name;
            insert tsk;
        test.startTest();
     // Call the Batch Apex method.
     BatchMIS s = new BatchMIS();
     ID batchprocessid = Database.executeBatch(s);
     // Test.stopTest();
     Test.StopTest();
}
}