public class AccountTeamMemberTriggerHelper {
    public static void ServiceResourceAlocation(List<AccountTeamMember> newMembers) {
        String userProfile = [SELECT Profile.Id FROM User WHERE Id = :UserInfo.getUserId()].Profile.Id;
        String customLabelName = Label.Sales_Profile_Id;
        
        // Check if the user's profile is 'Sales'
        if (customLabelName.Contains(userProfile)) {
            for (AccountTeamMember atm : newMembers) {
                atm.addError('You are not an Authorised Person to Add Account Team Member !!');
            }
        } else {
            Set<Id> accountIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Map<Id, String> mapOfUserName = new Map<Id, String>();
            List<Account> accountUpdate = new List<Account>();
            
            for (AccountTeamMember atm : newMembers) {
                if ((atm.TeamMemberRole == 'Service Resource' || atm.TeamMemberRole == 'In Plant Resource') && atm.AccountId != null) {
                    accountIds.add(atm.AccountId);
                    userIds.add(atm.UserId);
                }
            }
            
            List<User> userList = [SELECT Id, FirstName, LastName FROM User WHERE Id IN :userIds];
            for (User usr : userList) {
                if (usr.FirstName != null) {
                    mapOfUserName.put(usr.Id, usr.FirstName + ' ' + usr.LastName);
                } else {
                    mapOfUserName.put(usr.Id, usr.LastName);
                }
            }
            
            List<Account> accountList = [SELECT Id, Name, Service_Resource__c, In_Plant_Resource__c FROM Account WHERE Id IN :accountIds];
            
            for (Account acc : accountList) {
                for (AccountTeamMember acTeam : newMembers) {
                    if (acc.Id == acTeam.AccountId) {
                        Account acObj = new Account();
                        acObj.Id = acc.Id;
                        if (acTeam.TeamMemberRole == 'Service Resource') {
                            if (acc.Service_Resource__c == null) {
                                acObj.Service_Resource__c = mapOfUserName.get(acTeam.UserId);
                            } else {
                                acTeam.addError('You cannot add multiple Service Resources');
                            }
                        } else if (acTeam.TeamMemberRole == 'In Plant Resource') {
                            if (acc.In_Plant_Resource__c == null) {
                                acObj.In_Plant_Resource__c = mapOfUserName.get(acTeam.UserId);
                            } else {
                                acTeam.addError('You cannot add multiple In Plant Resources');
                            }
                        }
                        accountUpdate.add(acObj);
                    }
                }
            }
            
            if (!accountUpdate.isEmpty()) {
                update accountUpdate;
            }
        }
    }
   
    public static void getReportingManagers(List<AccountTeamMember> teamMembers) {
        Set<Id> managerIds = new Set<Id>();
        
        for (AccountTeamMember atm : teamMembers) {
            if (atm.Manager__c != null) {
                managerIds.add(atm.Manager__c);
            }
        }
        
        if (!managerIds.isEmpty()) {
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name,Manager__c FROM User WHERE Id IN :managerIds]);
            
            for (AccountTeamMember atm : teamMembers) {
                if (atm.Manager__c != null && userMap.containsKey(atm.Manager__c)) {
                    atm.Manager_RPO__c = userMap.get(atm.Manager__c).Name;
                }
            }
        }
    }
}