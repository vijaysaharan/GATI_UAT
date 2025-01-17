@istest
public class MCAdetailsTest {
    
    @istest static void task(){
        
       // Test.startTest();
        
        Account ac = TestFactory.getAccount('React','KEA','243122',True);
        
        User u = TestFactory.getUser('Test Code','Tcode','GMT','en_US','UTF-8','en_US','react@gmail.com','test@test.com');
        
       // ac.OwnerId = u.id;
        
        //update ac;
        
        Market_Competitor_Analysis__c mca = new Market_Competitor_Analysis__c();
        mca.Contract__c = ac.id;
        mca.BLUEDART__c=5;
        mca.MCG_Position_Code__c='test';
        mca.Revnue__c=89.0;
        mca.SAFEX__c=9;
        mca.SPOTON__c=9;
        mca.TCI__c=9;
        mca.DELHIVERY__c=9;
        mca.RIVIGO__c=78;
        insert mca;
        
        Task tsk = new Task();
        tsk.OwnerId          = u.id;
            //tsk.WhoId            = c.Id;
            tsk.WhatId           = ac.id;
            tsk.ActivityDate     = System.today();
            tsk.Status           = 'Open';
            tsk.Priority         = 'Normal';
            tsk.Subject          = 'MCA Details Pending';
            tsk.Description      = 'MCA details need to be updated against the account.';
            tsk.Type             = 'Other';
            tsk.IsReminderSet    = true;
            tsk.ReminderDateTime = System.now();
        
        insert tsk;
        
        Test.StartTest();

	// Call the Batch Apex method.
	MCAdetails m = new MCAdetails();
	ID batchprocessid = Database.executeBatch(m);

Test.StopTest();

        
        
       // Test.stopTest();
        
    }

}