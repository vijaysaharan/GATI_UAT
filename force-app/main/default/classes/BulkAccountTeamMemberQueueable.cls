public class BulkAccountTeamMemberQueueable implements Queueable {
    private String queryString;
    private Map<Id, Id> mapAccountIdUserId;
    private Set<Id> accountIds;

    public BulkAccountTeamMemberQueueable(String queryString, Map<Id, Id> mapAccountIdUserId, Set<Id> accountIds) {
        this.queryString = queryString;
        this.mapAccountIdUserId = mapAccountIdUserId;
        this.accountIds = accountIds;
    }

    public void execute(QueueableContext context) {
        // Enqueue the batch job
        Database.executeBatch(new BulkAccountTeamMemberBatch(queryString, mapAccountIdUserId, accountIds),1);
    }
}