public class UserRoleAndSubordinateUser {
    @InvocableMethod(label='Get User on the bases of Role Hierarchy' description='Returns the list of users' category='User')
    public static  List<userWrapper> getRoleSubordinateUsers() {
        Id userId = USERINFO.getUserId();
        List<userWrapper> alluserWrapperList = new List<userWrapper>();
        Id roleId = [SELECT UserRoleId From User Where Id =:userId and isActive=true].UserRoleId;
        Set<Id> allSubRoleIds = getAllSubRoleIds(New Set<ID>{roleId});
        Map<Id, User> users = new Map<Id, User>([SELECT Id, Name From User Where UserRoleId IN :allSubRoleIds]);
        for(User usr : users.values()){
            alluserWrapperList.add(new userWrapper(usr.Name));
        }
        if(!alluserWrapperList.isEmpty() && alluserWrapperList.size()>0){
            return alluserWrapperList;
        }
        return null;
    }
    
    //Get all Parent Roles.
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        
        Set<ID> currentRoleIds = new Set<ID>();
        
        //Get all of the roles below the passed roles
        for(UserRole userRole :[SELECT Id from UserRole Where ParentRoleId IN :roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }
        
        //Fetch more rolls
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        System.debug('--- Role user and Profile--'+currentRoleIds);
        return currentRoleIds;   
    }
    
    public class userWrapper{
        @InvocableVariable
        public String label;
        
        public userWrapper(String label){
            this.label = label;
        }
    }
    
}