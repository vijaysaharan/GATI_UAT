public with sharing class SanityCheckEmailOnAccount_Scheduler implements Schedulable {
    public static final String CRON_EXPR = '0 0 0 1 1/3 ? *';
   
    public static String scheduleIt()
    {
    SanityCheckEmailOnAccount_Scheduler job = new SanityCheckEmailOnAccount_Scheduler();
    return System.schedule('Sanity check email', CRON_EXPR, job);
    }
    public void execute (SchedulableContext sc)
    {
        SanityCheckEmailOnAccount c = new  SanityCheckEmailOnAccount();
        database.executeBatch(c,2000);
    }
}