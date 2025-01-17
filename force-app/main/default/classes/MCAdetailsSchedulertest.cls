@istest
public class MCAdetailsSchedulertest {
    
    @istest static void schedule(){
    
    Test.StartTest();
	MCAdetailsScheduler sh1 = new MCAdetailsScheduler();

	String sch = '0 0 0 5 * ? *'; 
	String jobID = system.schedule('MCA Details Pending Schedule', sch, sh1); 
    
    Test.stopTest(); 
        
    }



}