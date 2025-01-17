public with sharing class Opportunity_Update_Scheduler_Batch implements Schedulable {
    public static final String CRON_EXPR = '0 0 0 1/1 * ? *';
    public static String scheduleIt()
    {
    Opportunity_Update_Scheduler_Batch job = new Opportunity_Update_Scheduler_Batch();
    return System.schedule('Record update', CRON_EXPR, job);
    }
    public void execute (SchedulableContext sc)
    {
        opportunityUpdate c = new  opportunityUpdate();
        database.executeBatch(c);
    }
}