@isTest 
public class MCM_ReminderEmailOnAccountTest {
     
    @isTest  static void testMCMReminderEmailOnAccountBatch(){
        TestFactory.getAccountsMCM(10,True);
        test.startTest();
        //integer before=Limits.getEmailInvocations();
        MCM_ReminderEmailOnAccount obj =new MCM_ReminderEmailOnAccount();
        Id jobid= Database.executeBatch(obj);
        test.stopTest();
       // System.assertEquals(10,Limits.getEmailInvocations()); 
       // System.assert(Limits.getEmailInvocations()>before); 
        
        }
    
}