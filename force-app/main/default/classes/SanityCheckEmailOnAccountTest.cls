@isTest
public class SanityCheckEmailOnAccountTest {
	 @istest static void sanity()
    {
        
        
        Test.startTest();
      
        Account[] a = new List<Account>();
       
        for(Integer i=0 ; i< 10; i++)
        {
             Account acc = TestFactory.getAccount2('TestAccount1211'+ i , 'KEA', '52118'+i, True, '86748'+i);
			 
             
            
             a.add(acc);
        }
       	
      SanityCheckEmailOnAccount_Scheduler.scheduleIt();
		//SanityCheckEmailOnAccount c = new  SanityCheckEmailOnAccount();
        //database.executeBatch(c,2000);
		
      //SanityCheckEmailOnAccount_Scheduler job = new SanityCheckEmailOnAccount_Scheduler();
     //  String CRON_EXPR = '0 0 1 */3 *';        
     //  String jobid = System.schedule('Sanity check email', CRON_EXPR, job);
        
        
      //  CronTrigger ct = [Select id , CronExpression from CronTrigger where id = :jobId];
      //  System.assertEquals(CRON_EXPR ,ct.CronExpression);
        
    	Test.stopTest();     
    }  
         
}