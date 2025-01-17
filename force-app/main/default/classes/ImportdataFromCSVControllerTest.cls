@istest
public class ImportdataFromCSVControllerTest {
    
    static String str = 'FromEDC,ToEDC,Type,ProductFamily,RevenueperMonth(INR)\r\nEHYDN,KTM,SurfaceExpress,1,10';       

    public static String[] csvFileLines;
    public static Blob csvFileBody;
    
    
    @istest static void import()
    {
        Test.startTest();
        
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n');
        
        //System.debug(csvFileLines);
        
        
        
        //ImportDataFromCSVController importData = new ImportDataFromCSVController();
        //importData.csvFileBody = csvFileBody;
        //importData.importCSVFile();
        
        
        
        Account acc1 = TestFactory.getAccount('acc1','KEA','243122',True);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //list <Opportunity> op = TestFactory.getOpportunity(1, acc1.id);

		Opportunity op = new Opportunity(Name='op1',StageName='Qualified',CloseDate=System.today().addMonths(1),AccountId=acc1.Id,Pricebook2Id=pricebookId);
        
        insert op;
        
        Organization_Master__c fromEdc = TestFactory.getOrganizationMaster('EHYDN');
        Organization_Master__c toEdc = TestFactory.getOrganizationMaster('KTM');
        

		//Organization_Master__c fromEdc = new Organization_Master__c(Name='EHYDN');
        //Organization_Master__c ToEdc = new Organization_Master__c(Name='KTM');
        
      	//insert fromEdc;
        //insert ToEdc;
        
        
        Product2 p = TestFactory.getProduct2('Air Expre','SurfaceExpress',fromEdc.id,toEdc.Id);
        
		//Product2 p = new Product2(Name='Air Expre',Family='SurfaceExpress' );
        //p.From_EDC__c = fromEdc.id;
        //p.To_EDC__c = ToEdc.Id;
        
        //insert p;
        
        PricebookEntry pbe = TestFactory.getPricebookEntry(pricebookId,p.Id,1.0,true);
        
        
        //PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId , product2id=p.id,unitprice=1.0, isActive=true);
		//insert pbe;
        
        ImportDataFromCSVController importData = new ImportDataFromCSVController();
        importData.csvFileBody = csvFileBody;
        importData.acctid = op.id;

        importData.importCSVFile();
        
        
        
        
        
        
       /* Organization_Master__c fromEdc = new Organization_Master__c(Name='o1');
        Organization_Master__c ToEdc = new Organization_Master__c(Name='o2');
        
      	insert fromEdc;
        insert ToEdc;
        
        
		Product2 p = new Product2(Name='Air Express' );
        p.From_EDC__c = fromEdc.id;
        p.To_EDC__c = ToEdc.Id;
        
        insert p;
        
        
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id = pricebookId , product2id=p.id,unitprice=1.0, isActive=true);
		insert pbe;*/
        
        
        
        
        Test.stopTest();
        
        
        
    }

}