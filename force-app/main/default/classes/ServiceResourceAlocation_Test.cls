@IsTest
public class ServiceResourceAlocation_Test {
    @isTest static  void testa(){  
        Account acc = new Account();
        acc.name='testdemo';    
        acc.BillingPostalCode='noida';
        insert acc;
        Profile prof1 = [Select Id from Profile where name = 'System Administrator'];
        user u = new user();
        u.ProfileId = prof1.Id;
        u.LastName = 'last';
        u.Email = 'test@test.com';
        u.Username = 'test@tes.com' + System.currentTimeMillis();
        u.CompanyName = 'TEST';
        u.Title = 'title';
        u.Alias = 'alias';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';     
        insert u;  
        AccountTeamMember act = new AccountTeamMember();
        act.userid=u.id;
        act.TeamMemberRole='Service Resource';
        act.AccountId=acc.id; 
        insert act;
    }
     @isTest static  void testa2(){  
        Account acc = new Account();
        acc.name='testdemo';    
        acc.BillingPostalCode='noida';
        insert acc;
        Profile prof1 = [Select Id from Profile where name = 'System Administrator'];
        user u = new user();
        u.ProfileId = prof1.Id;
        u.LastName = 'last';
        u.Email = 'test@test.com';
        u.Username = 'test@tes.com' + System.currentTimeMillis();
        u.CompanyName = 'TEST';
        u.Title = 'title';
        u.Alias = 'alias';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';     
        insert u;  
        AccountTeamMember act = new AccountTeamMember();
        act.userid=u.id;
        act.TeamMemberRole='In Plant Resource';
        act.AccountId=acc.id; 
        insert act;
    }
}