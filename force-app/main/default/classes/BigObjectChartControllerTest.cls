@isTest
public class BigObjectChartControllerTest {
	@isTest 
    public static void getDataForChartTest(){
       

        Account a = new Account();
        a.Name = 'test';
        insert a;
        
        Opportunity item = new Opportunity(
            Name = 'Test Item',
            CloseDate = System.today().addDays(10),
            Amount = 452100,
            StageName = 'Qualified',
            AccountId = a.Id
        );
        insert item;
        
    
        
        test.startTest();
        BigObjectChartController.getDataForChart(a.id,'Opportunity','AccountId','AccountId');
        try{BigObjectChartController.getDataForChart(a.id,'Opportunity','AccountId','');}
        catch(Exception e){}
        
        test.stopTest();
    }
}