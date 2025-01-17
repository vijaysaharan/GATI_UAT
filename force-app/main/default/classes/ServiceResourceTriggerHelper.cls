public class ServiceResourceTriggerHelper {    
    public static void serviceResourceAllocation(List<AccountTeamMember> accountTeamMemberList){
        String currentUserProfileId = Userinfo.getProfileId();
        String unauthorizedUserProfiles = label.Sales_Profile_Id;
        if (unauthorizedUserProfiles.Contains(currentUserProfileId)) {
            for (AccountTeamMember atm : accountTeamMemberList) {
                atm.addError('You are not an Authorised Person to Add Account Team Member !!');
            }
        }
        else {
            Set<Id> accountIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Map<String, AccountTeamMember> accountIdToResource = new Map<String, AccountTeamMember>();
            List<Account> accountsToUpdate = new List<Account>();
            
            for(AccountTeamMember atm : accountTeamMemberList){
                if((atm.TeamMemberRole == 'Service Resource' || atm.TeamMemberRole == 'In Plant Resource')  && atm.AccountId!=null){
                    accountIds.add(atm.AccountId);
                    userIds.add(atm.UserId);
                }
            }
            
            Map<Id, User> userMap = new Map<Id, User>([SELECT Id, FirstName, LastName 
                                                       FROM User 
                                                       WHERE Id IN: userIds
                                                      ]);
            
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, Service_Resource__c 
                                                                FROM Account 
                                                                WHERE Id IN: accountIds
                                                               ]);
            
            List<AccountTeamMember> existingAccountTeamMember = [SELECT AccountId, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN: accountIds AND TeamMemberRole IN ('Service Resource','In Plant Resource')];
            
            for(AccountTeamMember atm : existingAccountTeamMember){
                if(atm.AccountId != null && atm.TeamMemberRole != null){
                    accountIdToResource.put(atm.AccountId+atm.TeamMemberRole, atm);
                }
            }
            
            for(AccountTeamMember atm : accountTeamMemberList){
                if(accountIdToResource.containsKey(atm.AccountId+atm.TeamMemberRole)){
                    atm.addError('You can not add multiple '+atm.TeamMemberRole);
                }
                else{
                    if(accountMap.containsKey(atm.AccountId) && userMap.containsKey(atm.UserId)){
                        Account acc = accountMap.get(atm.AccountId);
                        acc.Service_Resource__c = userMap.get(atm.UserId).FirstName != null ? userMap.get(atm.UserId).FirstName +' '+userMap.get(atm.UserId).LastName : userMap.get(atm.UserId).LastName;
                        accountsToUpdate.add(acc);
                    }
                }
            }
            
            if(accountsToUpdate != null && accountsToUpdate.size() > 0){
                database.update(accountsToUpdate,false);
            }
        }
    }
    
    public static void mapCustomerCodeToStaffCode(Set<Id> AccountTeamMemberIds){
        Map<String, String> customerCodeToStaffCode = new Map<String, String>();
        Map<String, String> customerCodeToCompanyCode = new Map<String, String>();
        List<AccountTeamMember> AccountTeamMemberList = [SELECT Account.GATI_Customer_Code__c,User.Staff_Code__c, Account.GATI_Company_Code__c 
                                                         FROM AccountTeamMember 
                                                         WHERE Id IN: AccountTeamMemberIds
                                                        ];
        
        for(AccountTeamMember atm : AccountTeamMemberList){
            if(atm.Account.GATI_Customer_Code__c != null && atm.User.Staff_Code__c != null){
                customerCodeToStaffCode.put(atm.Account.GATI_Customer_Code__c, atm.User.Staff_Code__c);
                customerCodeToCompanyCode.put(atm.Account.GATI_Customer_Code__c, atm.Account.GATI_Customer_Code__c);
            }
        }
        
        if(customerCodeToStaffCode != null && customerCodeToStaffCode.keySet().size() > 0){
            deleteServiceAllocation(customerCodeToStaffCode,customerCodeToCompanyCode);
        }
    }
    
    @future (callout=true)
    public static void deleteServiceAllocation(Map<String, String> customerCodeToStaffCode, Map<String, String> customerCodeToCompanyCode){
        if(customerCodeToStaffCode != null && customerCodeToStaffCode.keySet().size() > 0){            
            String authorizationToken = generateAuthorizationToken();
            for(String cusCode : customerCodeToStaffCode.keySet()){
                GatiMDMUtil.ActionInput input = new GatiMDMUtil.ActionInput();
                input.customerCode = cusCode;
                input.staffCode = customerCodeToStaffCode.get(cusCode);
                input.companyCode = customerCodeToCompanyCode.get(cusCode);
                input.action = 'Delete-CS-Mapping';
                input.authorizationHeader = authorizationToken;
                GatiMDMInvocable.convertJSONToRecordCollection(new List<GatiMDMUtil.ActionInput>{input});
            }
        }
    }
    
    private static String generateAuthorizationToken(){
        Map<String, String> payload = new Map<String, String>();
        payload.put('login', label.MDMAuthorizationUserName);
        payload.put('password', label.MDMAuthorizationPassword);
        HttpRequest request = new Httprequest();
        request.setMethod('POST');
        request.setEndpoint(MDMSetting__mdt.getInstance('Authorization_Token').EndPoint__c);
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(payload));        
        Http http = new Http();
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String tokenType = (String) responseMap.get('tokenType');
            String accessToken = (String) responseMap.get('accessToken');
            return (tokenType + ' ' + accessToken);
        }
        return null;
    }
}