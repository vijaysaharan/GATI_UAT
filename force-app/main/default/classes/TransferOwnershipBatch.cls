public class TransferOwnershipBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String ownerId;
    
    public TransferOwnershipBatch(String newOwnerId) {
        ownerId = newOwnerId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, OwnerId, (SELECT Id, OwnerId FROM Opportunities WHERE StageName != \'Closed\') FROM Account';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : scope) {
            // Set owner change options
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.assignmentRuleHeader.useDefaultRule = false;
            acc.setOptions(dmlOptions);
            
            // Transfer ownership of account and opportunities
            acc.OwnerId = ownerId;
            Database.update(acc, false);
            
            // Update account team to new owner
            List<AccountTeamMember> accountTeamMembersToUpdate = new List<AccountTeamMember>();
            for (AccountTeamMember atm : acc.AccountTeamMembers) {
                atm.UserId = ownerId;
                accountTeamMembersToUpdate.add(atm);
            }
            Database.update(accountTeamMembersToUpdate, false);
            
            accountsToUpdate.add(acc);
        }
        
        // Update accounts
        Database.update(accountsToUpdate, false);
    }
    
    public void finish(Database.BatchableContext context) {
        // Perform any post-processing or cleanup if needed
    }
}