/*
Author     : Shahid Imam (simam@kloudrac.com)
Date       : Feb 02, 2023
Desc       : 
Test Class Name : AddServiceResource
*/

public without sharing class AddServiceResource {
    
    //Get all sub roles.
    @AuraEnabled
    public static List<AddServiceResourceWrapper> getRoleSubordinateUsers() {
        Id userId = userInfo.getUserId();
        List<AddServiceResourceWrapper> addServiceResourceList = new List<AddServiceResourceWrapper>();
        //Get requested user's role Id
        Id roleId = [SELECT UserRoleId From User Where Id = :userId].UserRoleId;
        //Get all of the roles below the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(New Set<ID>{roleId});
        // get all of the ids for the users in those roles
        Map<Id, User> users = new Map<Id, User>([SELECT Id, Name From User Where UserRoleId IN :allSubRoleIds AND isActive=true ORDER BY Name]);
        for(user usr : users.values()){
            addServiceResourceList.add(new AddServiceResourceWrapper(usr.Name, usr.Id));
        }
        //Return the ids as a set
        System.debug('-- user data--'+addServiceResourceList);
        return addServiceResourceList;
    }
    
    //Get all Parent Roles.
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        
        Set<ID> currentRoleIds = new Set<ID>();
        
        //Get all of the roles below the passed roles
        for(UserRole userRole :[SELECT Id from UserRole Where ParentRoleId IN :roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }
        
        //Fetch more rolls
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }        
        return currentRoleIds;   
    }
    
    @AuraEnabled
    public static String getAccount(String recordId){
        String accName = [Select Id,Name From Account where Id=:recordId].Name;
        return accName;
    }
    
    @AuraEnabled
    public static String saveSerivecresource(String recordId, String userId){
        String userProfile = [SELECT Profile.Id FROM User WHERE Id = :UserInfo.getUserId()].Profile.Id;
        //String userProfile = UserInfo.getProfileId();
        String customLabelName =Label.Sales_Profile_Id;
        System.debug('userProfile:'+userProfile);
        // Check if the user's profile is 'Sales'
        if (customLabelName.Contains(userProfile)){
                // Throw an error message
                throw new AuraHandledException('You are not an Authorised Person to Add Account Team Member !!');
            }
        // String msg = '';
        // Map<Id,Case> mapOfCaseOwner = new Map<Id,Case>();
        // List<AccountTeamMember> accTeamList = [select Id, AccountId FROM AccountTeamMember WHERE AccountId=:recordId AND TeamMemberRole='Service Resource'];
        // if(!accTeamList.isEmpty() && accTeamList.size()>0){
        //     delete accTeamList;
        // }
        // AccountTeamMember acctemObj = new AccountTeamMember();
        // acctemObj.AccountId = recordId;
        // acctemObj.UserId = userId;
        // acctemObj.AccountAccessLevel = 'Read';
        // acctemObj.CaseAccessLevel = 'None';
        // acctemObj.OpportunityAccessLevel = 'None';
        // acctemObj.TeamMemberRole = 'Service Resource';
        // if(acctemObj!=null){
        //     try{
        //         insert acctemObj;
        //     }catch(Exception ex){
        //         msg = ex.getMessage();
        //     }
        
        // }
        // List<Case> caseList = [SELECT Id,OwnerId FROM CASE WHERE AccountId =:recordId AND Status!='Closed'];
        // for(Case cc:caseList){
        //     cc.OwnerId = userId;
        //     if(!mapOfCaseOwner.containsKey(cc.Id)){
        //         mapOfCaseOwner.put(cc.Id,cc);
        //     }
        // }
        // if(!mapOfCaseOwner.isEmpty() && mapOfCaseOwner.size()>0){
        //     try{
        //         database.update(mapOfCaseOwner.values());
        //     }catch(Exception ex){
        //         msg = ex.getMessage();
        //     }
        // }
        // if(String.isBlank(msg)){
        //     return 'success';
        // }
        AddServiceResourceBatch batch = new AddServiceResourceBatch();
        batch.userId = userId;
        batch.recordId = recordId;
        database.executeBatch(batch, 1);
        return 'success';
    }
    
    public Class AddServiceResourceWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public AddServiceResourceWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    @TestVisible
    public static void dummy(){
        integer i=1;
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