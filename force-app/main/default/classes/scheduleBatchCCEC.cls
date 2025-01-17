public class scheduleBatchCCEC implements Schedulable{ 
    public void execute(SchedulableContext sc)
    {
        BatchTosyncPendingCCEC BC=new BatchTosyncPendingCCEC();        
        Database.executeBatch(BC, 20);
    }
    public static void reviewmethod()
    {
    scheduleBatchCCEC m = new scheduleBatchCCEC();
    String sch = '0 16 14 * * ?'; //'0 01 * * * ?';
    String jobID = system.schedule('BatchCCEC', sch, m);
    }
}