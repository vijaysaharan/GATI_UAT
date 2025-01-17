@isTest
public class CSVUploadTest {
 
    Public Static testMethod void test()
    {
        Test.startTest();
        List<Map<String, String>> data = new List<Map<String, String>>();
        Account ac = testFactory.getAccount1('TestAccount11' , 'KEA', '522180', True, '111134');
        
        For(integer i = 0; i < 5; i ++)
        {
            Map<string, string> map1= new Map<string, string>();
            map1.put('Subject','Test'+i);
            map1.put('Origin','Email');
            map1.put('Status','New');
            map1.put('Type','Pending Pickup');
            map1.put('Sub_Type__c','LATE PICKUP');
        
            
            data.add(map1);
        }
        //csvUploadController.CSVData(data, 'Pick Up');
       
        
       BatchToCreateCases batch= new BatchToCreateCases(data,'Pick Up');
       Database.executeBatch(batch);
        test.stopTest();
        
    }
}