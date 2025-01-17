public with sharing class MCM_EmailSchedule implements Schedulable {
    
    public void execute(SchedulableContext sc)
    {
        MCM_ReminderEmailOnAccount m = new MCM_ReminderEmailOnAccount();
        Database.executeBatch(m);
    }

}