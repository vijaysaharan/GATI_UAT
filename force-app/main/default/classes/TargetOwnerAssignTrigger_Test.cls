@isTest
public class TargetOwnerAssignTrigger_Test {
    @isTest
    private static void CreateSalesKRATestData(){
        Sales_KRA__c sla = new Sales_KRA__c();
        sla.Name = 'Test Sales KRA';
        sla.Month__c = '1';
        sla.Year__c = '2022';
        sla.Product__c = '	SUR EXPRESS';
        sla.Target__c = 20000;
        sla.Remarks__c= 'test';
        sla.Account_Type__c = 'KEA';
        sla.Staff_Code__c = '21163';
        insert sla;
        
        update sla;
    }
}