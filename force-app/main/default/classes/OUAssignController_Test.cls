@isTest(SeeAllData=True)
public class OUAssignController_Test {
    @isTest
    private static void CreateLeadData(){
        Organization_Master__c org = [SELECT Id from Organization_Master__c WHERE NAME='HYDN' limit 1];
        Lead ld = new Lead();
        ld.FirstName = 'Test';
        ld.LastName = 'Lead';
        ld.LeadSource = 'Business Partner Referral';
        ld.Company = 'kloudrac Software';
        ld.Email= 'akumar43456@kloudrac.com';
        ld.MobilePhone = '8052124483';
        ld.Customer_Potential__c = 200000;
        ld.Monthly_Spent_on_express_Logistic__c = 'Less Than and Equal To 5 Lakh';
        ld.PostalCode = '201301';
        ld.GATI_Company_Code__c = '103';
        ld.Product__c = '100000005;100000009';
        ld.Lead_Data__c = 'Customer';
        insert ld;
        
        OUAssignController.searchDB('Organization_Master__c','Name','Id',20,'Pincode__c','500055');
        OUAssignController.assignOU(ld.Id,org.Id);
    }

}