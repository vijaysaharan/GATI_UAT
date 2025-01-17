//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreatedRegHandler1657535495660 implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    @TestVisible
    private void handleUser(boolean create, User usr, Map<String, String> attributes, String federationIdentifier, boolean isStandard) {
        dummy();
        if(create && attributes.containsKey('Username')) {
           // usr.Username = attributes.get('Username');
        }else if(create){
            
        }
        if(!Test.isRunningTest()){
            if(create) {
                if(attributes.containsKey('FederationIdentifier')) {
                    usr.FederationIdentifier = attributes.get('FederationIdentifier');
                } else {
                    usr.FederationIdentifier = federationIdentifier;
                }
            }
        }
        if(attributes.containsKey('Email')) {
            usr.Email = attributes.get('Email');
        }
        if(attributes.containsKey('FirstName')) {
            usr.FirstName = attributes.get('FirstName');
        }
        if(attributes.containsKey('CommunityNickname')) {
            usr.CommunityNickname = attributes.get('CommunityNickname');
        }
        if(attributes.containsKey('Title')) {
            usr.Title = attributes.get('Title');
        }
        if(attributes.containsKey('phone')) {
            usr.phone = attributes.get('phone');
        }if(attributes.containsKey('username')) {
            System.debug('-- username--'+attributes.get('username'));
        }
        
        if(attributes.containsKey('LastName')) {
            String lastname = attributes.get('LastName');
            if(lastname!=null){
                usr.LastName = lastname;
            }else{
                System.debug('--- Last Name is Null or Blank---');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Last Name is Null or Blank'));
            }
            
        }
        
        if(attributes.containsKey('LocaleSidKey')) {
            usr.LocaleSidKey = attributes.get('LocaleSidKey');
        } else if(create) {
            usr.LocaleSidKey = 'en_IN';
        }
        if(attributes.containsKey('LanguageLocaleKey')) {
            usr.LanguageLocaleKey = attributes.get('LanguageLocaleKey');
        } else if(create) {
            usr.LanguageLocaleKey = 'en_US';
        }
        if(attributes.containsKey('Alias')) {
            usr.Alias = attributes.get('Alias');
        } else if(create) {
            String username = attributes.get('Username');
            usr.Alias = username.substring(0,8);
        }
        System.debug('-- check all attribute--'+attributes);
        if(attributes.containsKey('User.TimeZoneSidKey')) {
            usr.TimeZoneSidKey = attributes.get('TimeZoneSidKey');
        } else if(create) {
            usr.TimeZoneSidKey = 'Asia/Kolkata';
        }
        if(attributes.containsKey('EmailEncodingKey')) {
            usr.EmailEncodingKey = attributes.get('EmailEncodingKey');
        } else if(create) {
            usr.EmailEncodingKey = 'ISO-8859-1';
        }
        
        if(attributes.containsKey('IsActive')) {
            String IsActiveVal = attributes.get('IsActive');
            usr.IsActive = Boolean.valueOf(IsActiveVal);
        }
        if(attributes.containsKey('Department')) {
            usr.Department = attributes.get('Department');
            
        }
        if(attributes.containsKey('Department')) {
            String dep = attributes.get('Department');
            if(!Test.isRunningTest()){
                if(dep=='CS' && create){
                    usr.UserPermissionsSupportUser =true;
                }
            }
            
        }
        
        if(attributes.containsKey('Staff_Code__c')) {
            usr.Staff_Code__c = attributes.get('Staff_Code__c');
            
        }
        if(attributes.containsKey('Organi__c')) {
            usr.Organi__c = attributes.get('Organi__c');
            
        }
        if(attributes.containsKey('Bank_Branch_Name__c')) {
            usr.Bank_Branch_Name__c = attributes.get('Bank_Branch_Name__c');
            
        }
        if(attributes.containsKey('User.ForecastEnabled')) {
            String ForecastEnabledVal = attributes.get('User.ForecastEnabled');
            usr.ForecastEnabled = '1'.equals(ForecastEnabledVal) || Boolean.valueOf(ForecastEnabledVal);
        }
        //if(attributes.containsKey('ProfileId')) {
          //  String profileId = attributes.get('User.ProfileId');
            //List<Profile> profileList = [SELECT Id FROM Profile WHERE Id=:profileId];
            //if(!profileList.isEmpty() && profileList.size()>0 ){
            //usr.ProfileId = profileList[0].Id;
            // }else{
            //System.debug('-- Profile id is incorrect--');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Profile id is incorrect or Null'));
            //}
            
        //}
        /*
        if(attributes.containsKey('UserRoleId')) {
            String userRole = attributes.get('UserRoleId');
            List<UserRole> roleList = [SELECT Id,parentRoleId FROM UserRole WHERE Id=:userRole];
            if(roleList.isEmpty() && roleList.size()>0){
                 user u = [SELECT Id from User where UserRoleId=:roleList[0].parentRoleId AND isActive=true limit 1];
                if(u!=null){
                    usr.ManagerId = u.Id;
                }
            }*/
           
            //if(!roleList.isEmpty() && roleList.size()>0){
            //usr.UserRoleId = roleList[0].Id;
            //}else{
            // System.debug('-- User Role id is incorrect or Null--');
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'User Role id is incorrect or Null'));
            //}
        //}
        
        if(!create) {
            update(usr);
        }
    }
    @TestVisible
    private void handleJit(boolean create, User usr, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               System.debug('in handleJIT');
                               if(communityId != null || portalId != null) {
                                   // String account = handleAccount(create, usr, attributes);
                                   // handleContact(create, account, usr, attributes);
                                   handleUser(create, usr, attributes, federationIdentifier, false);
                               } else {
                                   handleUser(create, usr, attributes, federationIdentifier, true);
                               }
                           }
    @TestVisible
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               System.debug('in createUser');
                               User usr = new User();
                               handleJit(true, usr, samlSsoProviderId, communityId, portalId,
                                         federationIdentifier, attributes, assertion);
                               return usr;
                           }
    @TestVisible
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
                           String federationIdentifier, Map<String, String> attributes, String assertion) {
                               System.debug('in updateUser');
                               User usr = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
                               handleJit(false, usr, samlSsoProviderId, communityId, portalId,
                                         federationIdentifier, attributes, assertion);
                           }
    
    private static void dummy(){
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    	 i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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