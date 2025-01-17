public class BulkAccountTeamMember {
    @AuraEnabled
    public static List<DatatoReturn> csvData(List<Map<String, String>> data) {
        Set<String> gatiCustomerCodes = new Set<String>();
        Map<String, Account> accountsByCustomerCode = new Map<String, Account>();
        
        Set<Id> setAccounts = new Set<Id>();
        Set<String> setUsername = new Set<String>();
        Map<String, String> mapCustomerCodeUsername = new Map<String, String>();
        Map<ID, String> mapAccountIdUsername = new Map<ID, String>();
        Map<String, String> mapUserIdUsername = new Map<String, String>();
        Map<Id, Id> mapAccountIdUserId = new Map<Id, Id>();
        
        for (Map<String, String> cusmCode : data) {
            gatiCustomerCodes.add(cusmCode.get('CUSTOMER CODE'));
            System.debug('CUSTOMER CODE ==>' + cusmCode.get('CUSTOMER CODE'));
            setUsername.add(cusmCode.get('NEWUSER'));
            System.debug('NEWUSER ==>' + cusmCode.get('NEWUSER'));
            mapCustomerCodeUsername.put(cusmCode.get('CUSTOMER CODE'), cusmCode.get('NEWUSER'));
        }
        
        if (!gatiCustomerCodes.isEmpty()) {
            List<Account> accounts = [SELECT Id, Name, GATI_Customer_Code__c, Service_Resource__c FROM Account WHERE GATI_Customer_Code__c IN :gatiCustomerCodes];
            if (!accounts.isEmpty()) {
                for (Account acc : accounts) {
                    setAccounts.add(acc.Id);
                    accountsByCustomerCode.put(acc.GATI_Customer_Code__c, acc);
                    mapAccountIdUsername.put(acc.Id, mapCustomerCodeUsername.get(acc.GATI_Customer_Code__c));
                }
            }
        }
        
        system.debug('mapAccountIdUsername = ' + mapAccountIdUsername);
        
        if (!setUsername.isEmpty()) {
            List<User> lstUser = [SELECT Id, Username from User WHERE Username IN :setUsername];
            system.debug('lstUser = ' + lstUser);
            if (!lstUser.isEmpty()) {
                for (User eachUser : lstUser) {
                    mapUserIdUsername.put(eachUser.Username, eachUser.Id);
                }
            }
        }
        system.debug('mapUserIdUsername = ' + mapUserIdUsername);
        for (Id accountId : mapAccountIdUsername.keySet()) {
            mapAccountIdUserId.put(accountId, mapUserIdUsername.get(mapAccountIdUsername.get(accountId)));
        }
        System.debug('mapAccountIdUserId ' + mapAccountIdUserId);
        
        if (!setAccounts.isEmpty()) {
            List<AccountTeamMember> accountTeamMembersToAdd = [SELECT Id from AccountTeamMember WHERE TeamMemberRole = 'Service Resource' AND AccountId IN :setAccounts];
            if (!accountTeamMembersToAdd.isEmpty()) {
                delete accountTeamMembersToAdd;
            }
        }
        
        List<Account> updatedAccounts = new List<Account>();
        List<DatatoReturn> exceptionList = new List<DatatoReturn>();
        List<AccountTeamMember> insertLstAccountTeamMember = new List<AccountTeamMember>();
        List<Case> relatedCasesToUpdate = new List<Case>();
        
        for (Map<String, String> row : data) {
            System.debug('data22' + data);
            
            String gatiCustomerCode = row.get('CUSTOMER CODE');
            System.debug('gatiCustomerCode ' + gatiCustomerCode);
            System.debug('accountsByCustomerCode.containsKey(gatiCustomerCode)' + accountsByCustomerCode.containsKey(gatiCustomerCode));
            
            if (gatiCustomerCode != null && accountsByCustomerCode.containsKey(gatiCustomerCode)) {
                System.debug('message');
                Account account = accountsByCustomerCode.get(gatiCustomerCode);
                account.Service_Resource__c = row.get('NEWUSER');
                updatedAccounts.add(account);
                
                if (!setAccounts.isEmpty()) {
                    for (Id accountId : setAccounts) {
                        AccountTeamMember eachAccountMember = new AccountTeamMember();
                        eachAccountMember.AccountId = accountId;
                        eachAccountMember.UserId = mapAccountIdUserId.get(accountId);
                        eachAccountMember.TeamMemberRole = 'Service Resource';
                        eachAccountMember.CaseAccessLevel = 'Edit';
                        eachAccountMember.AccountAccessLevel = 'Read';
                        eachAccountMember.OpportunityAccessLevel = 'None';
                        insertLstAccountTeamMember.add(eachAccountMember);
                    }
                }
                
                // Update related Cases' owner
                /*List<Case> relatedCases = [SELECT Id, AccountId FROM Case WHERE AccountId = :account.Id AND Status != 'Closed'];
                for (Case c : relatedCases) {
                    c.OwnerId = mapAccountIdUserId.get(c.AccountId);
                    relatedCasesToUpdate.add(c);
                }*/

                String query = 'Select Id, AccountId from Case where Status != \'Closed\' AND AccountId IN :setAccounts';
                
                BulkAccountTeamMemberBatch batch = new BulkAccountTeamMemberBatch(query,mapAccountIdUserId,setAccounts);  
                Database.executeBatch(batch, 1);
                //System.enqueueJob(new BulkAccountTeamMemberQueueable(query,mapAccountIdUserId,setAccounts));
                
            } else {
                Account account = accountsByCustomerCode.get(gatiCustomerCode);// Modified
                // Add handling for records with missing or invalid Gati Customer Code
                DatatoReturn ret = new DatatoReturn();
                ret.done = false;
                ret.Id = account.Id;
                ret.title = 'Invalid Gati Customer Code: ' + gatiCustomerCode;
                ret.obj = account;
                exceptionList.add(ret);
            }
        }
        
        if (!updatedAccounts.isEmpty()) {
            update updatedAccounts;
        }
        
        if (!insertLstAccountTeamMember.isEmpty()) {
            insert insertLstAccountTeamMember;
        }
        
        if (!relatedCasesToUpdate.isEmpty()) {
            update relatedCasesToUpdate;
        }
        
        List<DatatoReturn> resultList = new List<DatatoReturn>();
        for (Account acc : updatedAccounts) {
            DatatoReturn ret = new DatatoReturn();
            ret.done = true;
            ret.Id = acc.Id;
            ret.title = acc.Id + ' Success';
            ret.obj = acc;
            resultList.add(ret);
        }
        resultList.addAll(exceptionList);
        
        return resultList.isEmpty() ? null : resultList;
    }
    
    public class DatatoReturn {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public SObject obj;
        @AuraEnabled
        public Boolean done;
    }
}