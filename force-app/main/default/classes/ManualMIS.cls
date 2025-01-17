public with sharing class ManualMIS implements Schedulable {
   
    public void execute(SchedulableContext sc)
    {
        BatchMIS reviewobj=new BatchMIS();       
        Database.executeBatch(reviewobj);
    }
    public static void reviewmethod()
    {
    ManualMIS m = new ManualMIS();
    String sch = '0 0 0 1 * ? *';
    String jobID = system.schedule('Task Creation', sch, m);
    }
}