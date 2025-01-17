public class MCAdetails Implements Schedulable, Database.Batchable<sObject> {
    public void execute(SchedulableContext sc) {
    Database.executeBatch(this);
}

//This is the query that is passed to the execute method.  It queries all of the Market_Competitor_Analysis__c who have passed
String query = 'Select Id, OwnerId, Contract__r.id , Contract__r.owner.id FROM Market_Competitor_Analysis__c WHERE Contract__c != null';

public database.queryLocator start(Database.BatchableContext BC) {
    return database.getQueryLocator(query);

} //close start method

public void execute(Database.BatchableContext BC, list <Market_Competitor_Analysis__c> scope) {

    List <Task> taskList = new List<Task>();

    // Iterate through the whole query of Market_Competitor_Analysis
    // Create a Task that's associated with each Market_Competitor_Analysis.
    for(Market_Competitor_Analysis__c c : scope) {
            Task tsk             = new Task();
            tsk.OwnerId          = c.Contract__r.owner.id;
            //tsk.WhoId            = c.Id;
            tsk.WhatId           = c.Contract__r.id;
            tsk.ActivityDate     = System.today();
            tsk.Status           = 'Open';
            tsk.Priority         = 'Normal';
            tsk.Subject          = 'MCA Details Pending';
            tsk.Description      = 'MCA details need to be updated against the account.';
            tsk.Type             = 'Other';
            tsk.IsReminderSet    = true;
            tsk.ReminderDateTime = System.now();

            taskList.add(tsk);
    } //close for-loop

    try {
        insert taskList;
    } catch (system.dmlexception e) {
        System.debug('Tasks not inserted: ' + e);
    }
} //close execute method

public void finish(Database.BatchableContext BC) {


} //close finish method

}