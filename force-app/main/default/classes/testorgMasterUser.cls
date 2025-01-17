@isTest
public class testorgMasterUser 
{
    private static testMethod void myFuture()
    {
        Test.startTest();
        
              Organization_Master__c ou1= TestFactory.getOrgMaster('CREDC');
        User user1=TestFactory.getUser1('BDFS','zBDFS','America/Los_Angeles','en_US','UTF-8','en_US','test.bdfshead1@gati.com','standarduser1@testorg.com');
        Organization_Master__c ou= TestFactory.getOrgMaster('user1.Organi__c');
        Org_Master_User__c omu=TestFactory.getOrgMasterUser(ou.id,user1.id);
        user1.Organi__c='BHD';
        update user1;
       // update ou;
        //update omu;
        
        
        //OrgMasterUser.myFuture();
 
        Test.stopTest();
        
        
        
    }
}