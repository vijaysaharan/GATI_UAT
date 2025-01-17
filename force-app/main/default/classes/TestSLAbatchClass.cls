@isTest
public class TestSLAbatchClass 
{
    static testMethod void  leadSLA()
    {
     Test.startTest();
    //Lead l=Testfactory.getLeads('test13');
     // Lead l1=Testfactory.getLead('Best1231');
        Lead p = new Lead();
        p.LeadSource='Email';
        p.Email='rishabh@gmail.com';
        p.LastName='LastName';
        p.PostalCode='670987';
        p.Company='company';
        p.Phone='8909876';
        p.MobilePhone='7675436789';
        insert p;        
       LeadSLABatchClassSchedular.scheduleme('Test');
       Test.stopTest(); 
    }
    static testMethod void  leadSLAkea()
    {
     Test.startTest();
        Lead p = new Lead();
        p.LeadSource='Email';
        p.Email='rishabh@gmail.com';
        p.LastName='LastName';
        p.PostalCode='670987';
        p.Company='company';
        p.Phone='8909876';
        p.MobilePhone='7675436789';
        insert p;
        Lead p2 = new Lead();
        p2.LeadSource='Email';
        p2.Email='abc@gmail.com';
        p2.LastName='Last2323Name';
        p2.PostalCode='670987';
        p2.Company='compan2y';
        p2.Phone='89098216';
        p2.MobilePhone='7675456719';
        insert p2;        
       LeadSLABatchClassSchedular.scheduleme('tests2');
       Test.stopTest(); 
    }
}