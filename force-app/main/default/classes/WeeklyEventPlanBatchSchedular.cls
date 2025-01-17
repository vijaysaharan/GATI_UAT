global  class WeeklyEventPlanBatchSchedular implements Schedulable{

    global void execute(SchedulableContext sc){
        WeeklyEventPlanBatch sendweeklyEmail  = new WeeklyEventPlanBatch();
        database.executeBatch(sendweeklyEmail);
    }
}