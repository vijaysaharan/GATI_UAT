public class ExpenseReport{

    public list <Expense__c> lstExpense {get;set;}
    
    public ExpenseReport(ApexPages.StandardController controller) {

        lstExpense = new list <Expense__c>();
        lstExpense = [Select Name, RecordType.Name,Visit__c, From__c, To__c, Mode__c, Amount__c, Distance__c, Accepted_Amount__c, 
        Description__c, Customer_Connect__c, From_Date__c, Employee_Name__c, To_Date__c, No_of_Days__c, City_Name__c, 
        State_Name__c, Paticulars__c,HotelLodgeName__c,Bill_No__c
        from Expense__c 
        where  Visit__c = :ApexPages.currentPage().getParameters().get('id') Order By From_Date__c,Name];
    }
}