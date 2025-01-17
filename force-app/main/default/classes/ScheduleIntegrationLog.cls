public with sharing class ScheduleIntegrationLog implements Schedulable {
    
    public void execute(SchedulableContext sc)
    {
        BatchIntegrationLog reviewerror=new BatchIntegrationLog();        
        Database.executeBatch(reviewerror);
    }
    public static void reviewmethod()
    {
    ScheduleIntegrationLog m = new ScheduleIntegrationLog();
    String sch = '0 5 * * * ?';
    String jobID = system.schedule('Error', sch, m);
    }
}