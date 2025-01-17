@isTest
public class AutocreatedRegHandler1657535495660_Test {
    @isTest
    private static void createdTestData(){
        Map<String, String> attributes = new Map<String,String>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'stgati', Email='standarduser@gatikwe.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@gatikwe.com');
        insert u;
        attributes.put('Username',u.Username);
        attributes.put('Email',u.Email);
        attributes.put('FirstName',u.FirstName);
        attributes.put('LastName',u.LastName);
        attributes.put('CommunityNickname','nick');
        attributes.put('Title','Dev');
        attributes.put('phone','8052124483');
        attributes.put('LanguageLocaleKey','en_US');
        attributes.put('Alias','kcgati');
        attributes.put('User.TimeZoneSidKey','Asia/Kolkata');
        attributes.put('EmailEncodingKey','ISO-8859-1');
        attributes.put('IsActive','ISO-8859-1');
        attributes.put('Department','CS');
        attributes.put('Staff_Code__c','93961');
        attributes.put('Organi__c','SBD');
        attributes.put('Bank_Branch_Name__c','Functional Manager - GEMS 2.0');
        
        
        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            
            Test.startTest();
            User usr = new user();
            AutocreatedRegHandler1657535495660 handle = new AutocreatedRegHandler1657535495660();
            handle.handleUser(true,usr,attributes,'',false);
            //handle.handleJit(true, usr, null, '', u.ProfileId, '', attributes, '');
            Test.stopTest();
        }
        
    }
    
}