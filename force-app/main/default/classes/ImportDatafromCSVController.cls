public with sharing class ImportDatafromCSVController
{
    public opportunity acct;
    public string acctid; 
    Public Document doc{get;set;}
    public importDataFromCSVController(ApexPages.StandardController stdController) 
    {
        this.acct = (Opportunity)stdController.getRecord();
        acctid = acct.id;
        doc=[select id,name from Document where name='Sample Lane Upload File' limit 1	];
    } 
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public boolean display{get;set;}
    public List<OpportunityLineItem> acclist{get;set;}
    Set<string> fromEDC= new Set<string>();
    Set<string> toEDC= new Set<string>();
    Set<string> proFamily= new Set<string>();
    Map<string,PriceBookEntry> keyVSProduct= new Map<string,PriceBookEntry>();
    public importDataFromCSVController()
    {
            csvFileLines = new String[]{};
            acclist = New List<OpportunityLineItem>();
        	
    }
    public PageReference onSave()
    {
        return new PageReference('/'+ acctid);
    }
     public void importCSVFile()
        {
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\r\n');
            acclist = New List<OpportunityLineItem>();
            for(Integer i=1;i<csvFileLines.size();i++)
            {   
                string[] csvRecordData = csvFileLines[i].split(',');
                fromEDC.add(csvRecordData[0]);
                toEDC.add(csvRecordData[1]);
                proFamily.add(csvRecordData[2]);    
               
            }
            
            List<PriceBookEntry> productlist = [Select id,Product2ID,Product2.From_EDC__r.name,Product2.To_EDC__r.name, Product2.Family from PricebookEntry where Product2.Family in :proFamily OR Product2.From_EDC__r.name in :fromEDC OR Product2.To_EDC__r.name in :toEDC]; 
            
            if(productlist.size()>0)
            {
               for(PriceBookEntry ppname: productlist)
               {
                  String key= ppname.Product2.From_EDC__r.name + '' + ppname.Product2.To_EDC__r.name + '' + ppname.Product2.Family ;
                  keyVSProduct.put(key,ppname);
                 }
                
                           
                for(Integer i=1;i<csvFileLines.size();i++)
            {   
                string[] csvRecordData = csvFileLines[i].split(',');
                String getKey= csvRecordData[0] + '' + csvRecordData[1] + '' + csvRecordData[2] ;
                
                
                String key = new List<String>(keyVSProduct.keySet()).get(0);
                
                OpportunityLineItem accObj = new OpportunityLineItem() ;
                accObj.PricebookEntryID = keyVSProduct.get(getKey).id;
                accObj.Quantity =Decimal.valueOf(csvRecordData[3]);
                accObj.UnitPrice = Decimal.valueOf(csvRecordData[4]);
                
                accObj.OpportunityId = acctid;
                accObj.Product2Id=keyVSProduct.get(getKey).Product2ID;
                acclist.add(accObj);
            }
                
            insert acclist;
            display= true;
                }
            
            else{
                System.debug('nuklll');
            }
        }
    
    
}