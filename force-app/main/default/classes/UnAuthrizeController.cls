public class UnAuthrizeController {
    @AuraEnabled
    public static Boolean getCurrentUserMethod(){
        String profileId = UserInfo.getProfileId();
        String ProfileName = [Select id,name from profile Where id=:profileId].name;
        System.debug('--- name--'+ProfileName);
        if(ProfileName == 'System Administrator'){
            return true;
        }
        return false;
    }
}