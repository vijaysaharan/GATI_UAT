@isTest(SeeAllData = false)
public class CustomAccountTeamMemberControllerTest {
    static testMethod void myUnitTest(){
        
        Set<ID> setAccountId = new Set<ID>();  
        Account acct = new Account();
        acct.Name = 'Test';
        acct.GATI_Customer_Code__c = '45071002';
        insert acct;
        setAccountId.add(acct.id); 
        
        Contact objContact= new Contact();
        objContact.FirstName='Test';
        objContact.LastName='Test Name';
        objContact.Email='test@gmail.com';
        objContact.AccountId=acct.Id;
        insert objContact;
        
       /* Account_Team_Member__mdt accountTeamMemberMetaData= new Account_Team_Member__mdt();
        accountTeamMemberMetaData.MasterLabel='Account_Team_Member';
        accountTeamMemberMetaData.Batch_Size__c=20;
        insert accountTeamMemberMetaData;*/
           
        
        String csvString = '[{"CustomerCode":"45071002","Username":"son_60497@gatikweuat.com"},{"CustomerCode":"30232801","Username":"mon_97575@gatikwe.com.uat"}]';
        Test.startTest();
        CustomAccountTeamMemberController.insertData(csvString);
        // CustomAccountTeamMemberController.fieldWrapper();
        Test.stopTest();  
    }
    
   
    
}