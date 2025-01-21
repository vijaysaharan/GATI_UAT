/*
Author     : Shahid Imam (simam@kloudrac.com)
Date       : Feb 02, 2023
Test Class Name : AddServiceResourceBatch
Updated By : Vijay Saharan(vijay@kloudrac.com)
Updated Date : 20-JAN-2025
*/
public class AddServiceResourceBatch implements Database.Batchable<SObject> {
    public string recordId;
    public string userId;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String msg = '';
        List<AccountTeamMember> accountTeamMemberList = [SELECT Id, AccountId FROM AccountTeamMember 
                                                         WHERE AccountId = :recordId AND TeamMemberRole = 'Service Resource'
                                                        ];
        if(!accountTeamMemberList.isEmpty() && accountTeamMemberList.size()>0){
            delete accountTeamMemberList;
        }
        
        AccountTeamMember newAccountTeamMember = new AccountTeamMember();
        newAccountTeamMember.AccountId = recordId;
        newAccountTeamMember.UserId = userId;
        newAccountTeamMember.AccountAccessLevel = 'Read';
        newAccountTeamMember.CaseAccessLevel = 'Edit';
        newAccountTeamMember.OpportunityAccessLevel = 'None';
        newAccountTeamMember.TeamMemberRole = 'Service Resource';
        if(newAccountTeamMember!=null){
            try{
                insert newAccountTeamMember;
            }catch(Exception ex){}
            
        }
        return Database.getQueryLocator([SELECT Id,OwnerId FROM CASE WHERE AccountId = :recordId AND Status != 'Closed']);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> caseList) {
        Map<Id,Case> caseToCaseOwner = new Map<Id,Case>();
        for(Case cc : caseList){
            cc.OwnerId = userId;
            if(!caseToCaseOwner.containsKey(cc.Id)){
                caseToCaseOwner.put(cc.Id,cc);
            }
        }
        if(!caseToCaseOwner.isEmpty() && caseToCaseOwner.size() > 0){
            try{
                CheckRecursive.runAfterUpdate=false;
                database.update(caseToCaseOwner.values());
            }catch(Exception ex){}
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        //Batch Finish
    }
}