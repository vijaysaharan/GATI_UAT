@isTest
public class ArchiveCaseDeleteTest {
	@isTest
    public static void testDeleteAll(){
        
         Case c = new Case();
        //enter details
        c.Type = 'My Type';
        c.Origin = 'My Origin';
        c.Status = 'Open'; 
        c.Type = 'Pending Pickup'; 
        c.Sub_Type__c = 'MISSED PICKUP'; 
        c.Docket_Number__c = '1111';
        c.OwnerId = UserInfo.getUserId();
        //  c.Pick_Up_Ref_ID__c = '5000sddfdg';   
        insert c;
        ArchiveCaseDelete a = new ArchiveCaseDelete();
        a.index = 'AccountID__c';
        a.objectname = 'Dummy__b';
        Database.executeBatch(a,1);
    }
}