public class AmountRollupHandler {
    public static Map<Id,AccountTeamMember> AccountTeamMap = New Map<Id,AccountTeamMember>();
    
    /*
* Author : Ashish(akumar4@kloudrac.com)
* Description : Roll up Amount and update to the parent
* Trigger Name : AmountRollup
*  Test Class Name : AmountRollupTest(88%)
* Created Date : 02-05-2022
*  Modified Date : 16-06-2022
*/
    
    public static void accountAmountRollup(List<Account> accList){
        map<id,Account> updateMap =new map<id,Account>(); 
        set<ID> accountParentIDs = new set<ID>(); 
        for(Account acc: accList){
            if(acc.ParentId!=null){
                accountParentIDs.add(acc.ParentId);
            } 
        }
        
        
        List<AggregateResult> AggregateResultList = [SELECT ParentId,SUM(Amount__c)amount from Account where ParentId IN:accountParentIDs AND (RecordType.Name = 'Customer Code' OR RecordType.Name = 'Contract') Group By ParentId]; 
        if(AggregateResultList != null && AggregateResultList.size() > 0){ 
            for(AggregateResult aggr:AggregateResultList){      
                Account acc=new Account(); 
                acc.Id=(id)aggr.get('ParentId');        
                acc.Amount__c=(decimal)aggr.get('amount');
                updateMap.put(acc.Id, acc); 
            } 
        }else { 
            for(id idSet:accountParentIDs){ 
                Account acc=new Account(); 
                acc.Id=idSet; 
                acc.Amount__c=0;
                updateMap.put(acc.Id, acc); 
            } 
        } 
        update updateMap.values();
    }
    
    //Update Risk Coverage field
    public static void riskCoverageByChange(List<Account> acList){
        for(Account ac : acList){
            if(ac.Risk_Covered_By__c != null){
                ac.Risk_Coverage__c = ac.Risk_Covered_By__c;
            }  
        }
    }
    
    //Account Owner change when Account owner is Api user
    public static void customerUserOwnerChange(List<Account> accountList){
        Set<Id> customerCodeParentIds = new Set<Id>();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Code').getRecordTypeId();

        for(Account acc : accountList){
            if(acc.ParentId != null && acc.RecordTypeId == devRecordTypeId){
                customerCodeParentIds.add(acc.ParentId);                
            }
        }
        
        Map<Id, Account> parentAccounts = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id IN :customerCodeParentIds]);
                
        for(Account acc : accountList){
            if(acc.ParentId != null && parentAccounts.containsKey(acc.ParentId)){
                acc.OwnerId = parentAccounts.get(acc.ParentId).OwnerId;
            }
        }
    }
    
    // Account type update  Customer code from Contract Account
    public static void updateAccountType(List<Account> accList){
        Set<Id> paretIds = new Set<Id>();
        Map<Id, Account> updateCusomerCode = new Map<Id,Account>();
        List<Account> accountListParent = new List<Account>();
        for(Account acc: accList){
            System.debug('-- type--'+acc.Record_Type__c);
            if(acc.Record_Type__c == 'Contract'){
                paretIds.add(acc.Id);
                accountListParent.add(acc);
            }
        }
        
        List<Account> accountParentList = [SELECT Id, ParentId, Name, OwnerId, Record_Type__c, Customer_Category__c FROM Account WHERE ParentId IN:paretIds AND Record_Type__c='Customer Code'];
        System.debug('-- check1--'+accountParentList);
        if(!accountParentList.isEmpty() && accountParentList.size()>0){
            for(Account parentAccount : accountListParent){
                for(Account customerAccount : accountParentList){
                    customerAccount.Customer_Category__c = parentAccount.Customer_Category__c;
                    if(!updateCusomerCode.containsKey(customerAccount.Id)){
                        updateCusomerCode.put(customerAccount.Id, customerAccount);
                    }
                    
                }
            }
        }
        
        if(!updateCusomerCode.isEmpty() && updateCusomerCode.size()>0){
            database.update(updateCusomerCode.values());
            System.debug('----check2--'+updateCusomerCode);
        }
    }
    
    //Get Account Team For Owner Change 
    public static void getAccountTeamForOwnerChange(List<Account> accList){
        if(accList != null && accList.size()>0){
            List<AccountTeamMember> AccountTeamList = [Select Id,UserId,AccountId,OpportunityAccessLevel,AccountAccessLevel,CaseAccessLevel,TeamMemberRole From AccountTeamMember Where AccountId IN:accList];
            if(AccountTeamList != null && AccountTeamList.size()>0){
                for(AccountTeamMember acm : AccountTeamList){
                    System.debug('acm'+acm);
                    if(acm.AccountId != null)
                        AccountTeamMap.put(acm.AccountId,acm);
                }
            }
        }
        System.debug('AccountTeamMap'+AccountTeamMap.size());
    }
    
    //Get Account Team For Owner Change 
    public static void setAccountTeamForAccount(List<Account> accList){
        if(accList != null && accList.size()>0){
            List<AccountTeamMember> insertAccountTeamList = New List<AccountTeamMember>();
            Map<Id,AccountTeamMember> CurrentAccountTeamMap = New Map<Id,AccountTeamMember>();
            List<AccountTeamMember> AccountTeamList = [Select Id,UserId,AccountId,OpportunityAccessLevel,AccountAccessLevel,CaseAccessLevel,TeamMemberRole From AccountTeamMember Where AccountId IN:accList];
            if(AccountTeamList != null && AccountTeamList.size()>0){
                for(AccountTeamMember acm : AccountTeamList){
                    CurrentAccountTeamMap.put(acm.AccountId,acm);
                }
            }
            for(Account acc : accList){
                if(!CurrentAccountTeamMap.containsKey(acc.Id) && AccountTeamMap.containsKey(acc.Id)){
                    insertAccountTeamList.add(AccountTeamMap.get(acc.Id));
                }
            }
            if(insertAccountTeamList != null && insertAccountTeamList.size()>0){
                for(AccountTeamMember acMember : insertAccountTeamList){
                    acMember.Id = null;
                }
                System.debug(insertAccountTeamList);
                insert insertAccountTeamList;
            }
        }
    }
}