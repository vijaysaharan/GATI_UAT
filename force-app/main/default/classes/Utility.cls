public with sharing class Utility {
     
    //Get all sub roles.
    public static Set<ID> getRoleSubordinateUsers(Id userId) {
         
        //Get requested user's role Id
        Id roleId = [SELECT UserRoleId From User Where Id = :userId].UserRoleId;
        //Get all of the roles below the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(New Set<ID>{roleId});
        // get all of the ids for the users in those roles
        Map<Id, User> users = new Map<Id, User>([SELECT Id, Name From User Where UserRoleId IN :allSubRoleIds]);
        //Return the ids as a set
        return users.keySet();
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
}