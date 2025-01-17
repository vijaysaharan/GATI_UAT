public class ClaimPdfController {
    public list <Visit__c> lstVisit {get;set;}
    public list <Decimal> totalList {get;set;}
    public list <Expense__c> lstExpense {get;set;}
    
    public ClaimPdfController(ApexPages.StandardController controller) {
        lstVisit = new list <Visit__c>();
        lstVisit = [Select Name,Employee_Name__r.Name,Employee_Name__r.Title,Employee_Name__r.Staff_Code__c,
                    Total_Travel__c,Total_Lodging__c,Total_Boarding__c,Total_Miscellaneous__c, Visit_Date__c,Client_Visit__c, 
                    Claim_Amount__c, Distance__c, Accepted_Amount__c 
                    from Visit__c  
                    where  Claim__c = :ApexPages.currentPage().getParameters().get('id') Order By Visit_Date__c,Name];
        System.debug(lstVisit);
        totalList = new List<Decimal>();
        Set<Id> visitIds =  new Set<Id>();
        for(Visit__c visit : lstVisit){
            visitIds.add(visit.Id);
        }
        System.debug(visitIds);
        lstExpense = new list <Expense__c>();
        lstExpense = [Select Name, RecordType.Name,Visit__c, From__c, To__c, Mode__c, Amount__c, Distance__c, 
                      Accepted_Amount__c, Description__c, Customer_Connect__c, From_Date__c, Employee_Name__c, To_Date__c, 
                      No_of_Days__c, City_Name__c, State_Name__c, Paticulars__c,HotelLodgeName__c,Bill_No__c,
                      Customer_Connect__r.Customer_Name__c,Accompanied_With__r.Name
                      from Expense__c 
                      where  Visit__c IN :visitIds];
        
        Decimal travelTotal = 0;
        Decimal LodgingTotal = 0;
        Decimal BoardingTotal = 0;
        Decimal MiscellaneousTotal = 0;
        Decimal Total = 0;
        
        for(Expense__c exp : lstExpense){
            If(exp.Amount__c != null){
                if(exp.RecordType.Name == 'Travel'){
                    travelTotal = travelTotal+exp.Amount__c;
                }
                if(exp.RecordType.Name == 'Lodging'){
                    LodgingTotal = LodgingTotal+exp.Amount__c;
                }
                if(exp.RecordType.Name == 'Boarding'){
                    BoardingTotal = BoardingTotal+exp.Amount__c;
                }
                if(exp.RecordType.Name == 'Miscellaneous'){
                    MiscellaneousTotal = MiscellaneousTotal+exp.Amount__c;
                }
                
            }        }
        
        Total = Total+travelTotal+LodgingTotal+BoardingTotal+MiscellaneousTotal;
        
        totalList.add(travelTotal);
        totalList.add(BoardingTotal);
        totalList.add(BoardingTotal);
        totalList.add(MiscellaneousTotal);
        totalList.add(Total);
    }
}