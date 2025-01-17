public class CaseOwnerAssignmentScheduler implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
    /*public Set<Id> caseIds;
    public CaseOwnerAssignmentScheduler(Set<Id> caseIds){
        this.caseIds = caseIds;
    }*/
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> ownerNames = label.CaseOwnerToChange.split(',');
        String query = 'SELECT Id, OwnerId FROM Case WHERE Owner.Name IN :ownerNames';
        /*if(caseIds != null){
            query += ' AND Id IN :caseIds';
        }*/
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Case> scope){
        List<RoundRobinAssigner.RoundRobinAssignment> ListForGroupAndId = New List<RoundRobinAssigner.RoundRobinAssignment>();
        for(Case cs : scope){
            RoundRobinAssigner.RoundRobinAssignment GroupAndIdForRoundRobin = New RoundRobinAssigner.RoundRobinAssignment();
            GroupAndIdForRoundRobin.fieldName = 'OwnerId';
            GroupAndIdForRoundRobin.groupName = 'RetailSupport';
            GroupAndIdForRoundRobin.recordId = cs;
            ListForGroupAndId.add(GroupAndIdForRoundRobin);
        }
        if(ListForGroupAndId != null && ListForGroupAndId.size()>0){
            RoundRobinAssigner.assign(ListForGroupAndId, true);
        }
    }
    public void finish(Database.BatchableContext BC){
        //FINISH
    }
    public void execute(SchedulableContext SC){
        database.executeBatch(new CaseOwnerAssignmentScheduler(),100);
    }
}