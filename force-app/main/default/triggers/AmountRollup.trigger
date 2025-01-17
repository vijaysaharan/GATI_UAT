trigger AmountRollup on Account (after insert,after update,after unDelete,after delete,before update,before insert) {
/*
* Author : Ashish(akumar4@kloudrac.com)
* Description : Roll up Amount and update to the parent
* Trigger Handler Name : AmountRollupHandler
* Test Class Name : AmountRollupTest(100%)
* Created Date : 02-05-2022
* Modified Date : 09-Dec-2024
*/
    Trigger_Rule__mdt mdt = [select Id,Account_Rollup__c,customerUserOwnerChange__c,riskCoverageByChange__c,Contract_Account_Change__c from Trigger_Rule__mdt];
    if(mdt.Account_Rollup__c==false){
        if((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate) ){
            AmountRollupHandler.accountAmountRollup(Trigger.new);
        }
        
        if(Trigger.isDelete && CheckRecursive.runAfterDelete){ 
            CheckRecursive.runAfterDelete = false;
            AmountRollupHandler.accountAmountRollup(Trigger.old);
        }
    }
    if(mdt.riskCoverageByChange__c==false){
        if(Trigger.isBefore && Trigger.isInsert && CheckRecursive.runBeforeInsert){
            CheckRecursive.runBeforeInsert = false;
            AmountRollupHandler.customerUserOwnerChange(Trigger.new);
            AmountRollupHandler.riskCoverageByChange(Trigger.new);
        }
    }
    
    if(mdt.riskCoverageByChange__c==false){
        if(Trigger.isBefore && Trigger.isUpdate && CheckRecursive.runBeforeUpdate){
            CheckRecursive.runBeforeUpdate = false;
            AmountRollupHandler.riskCoverageByChange(Trigger.new);
            
        }
    }
    
    if(mdt.Contract_Account_Change__c==false){
        if(Trigger.isAfter && Trigger.isUpdate && CheckRecursive.runAfterUpdate){
            CheckRecursive.runAfterUpdate = false;
            //AmountRollupHandler.updateAccountType(Trigger.new);
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Account acc : Trigger.new){
            if(acc.OwnerId!=Trigger.oldmap.get(acc.Id).OwnerId){
                acc.Previous_Owner__c =  Trigger.oldmap.get(acc.Id).OwnerId;
            }
        }
    } 
    
    //Before Account Owner Change Getting List Of Account Team
    If(Trigger.isBefore && Trigger.isUpdate){
        List<Account> accList = New List<Account>();
        for(Account ac : Trigger.New){
            if(ac.OwnerId != Trigger.oldMap.get(ac.Id).OwnerId){
                accList.add(ac);
            }
        }
        If(accList != null && accList.size()>0){
            AmountRollupHandler.getAccountTeamForOwnerChange(accList);
        }
    }
    //After Account Owner Change Setting Account Team
    If(Trigger.isAfter && Trigger.isUpdate){
        List<Account> accList = New List<Account>();
        for(Account ac : Trigger.New){
            if(ac.OwnerId != Trigger.oldMap.get(ac.Id).OwnerId){
                accList.add(ac);
            }
        }
        If(accList != null && accList.size()>0){
            AmountRollupHandler.setAccountTeamForAccount(accList);
        }
    }
}