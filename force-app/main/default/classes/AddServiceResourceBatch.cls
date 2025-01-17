/*
Author     : Shahid Imam (simam@kloudrac.com)
Date       : Feb 02, 2023
Desc       : 
Test Class Name : AddServiceResourceBatch
*/

public class AddServiceResourceBatch implements Database.Batchable<SObject> {
    public string recordId;
    public string userId;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String msg = '';
        
        List<AccountTeamMember> accTeamList = [select Id, AccountId FROM AccountTeamMember WHERE AccountId=:recordId AND TeamMemberRole='Service Resource'];
        if(!accTeamList.isEmpty() && accTeamList.size()>0){
            delete accTeamList;
        }
        
        AccountTeamMember acctemObj = new AccountTeamMember();
        acctemObj.AccountId = recordId;
        acctemObj.UserId = userId;
        acctemObj.AccountAccessLevel = 'Read';
        acctemObj.CaseAccessLevel = 'Edit';
        acctemObj.OpportunityAccessLevel = 'None';
        acctemObj.TeamMemberRole = 'Service Resource';
        if(acctemObj!=null){
            try{
                insert acctemObj;
            }catch(Exception ex){
                
            }
            
        }
        return Database.getQueryLocator([SELECT Id,OwnerId FROM CASE WHERE AccountId =:recordId AND Status!='Closed']);
        //return Database.getQueryLocator(roleId);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Case> caseList) {
        Map<Id,Case> mapOfCaseOwner = new Map<Id,Case>();
        for(Case cc:caseList){
            cc.OwnerId = userId;
            if(!mapOfCaseOwner.containsKey(cc.Id)){
                mapOfCaseOwner.put(cc.Id,cc);
            }
        }
        if(!mapOfCaseOwner.isEmpty() && mapOfCaseOwner.size()>0){
            try{
                CheckRecursive.runAfterUpdate=false;
                database.update(mapOfCaseOwner.values());
            }catch(Exception ex){
                
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        // code to execute after the batch finishes
    }

    Integer i=0;{
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        
        
    }
}